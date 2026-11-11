//
//  CYLDemoLeanCloudSessionService.swift
//  ChatKit-OC
//
//  Translated from Objective-C. Originally moved from ChatKit's CYLSessionService
//  (v2.1.1, created by ElonChan on 16/3/1).
//
//  The LeanCloud IM session: AVIMClient lifecycle, client delegate callbacks, and
//  received-message handling. UI-side logic (reconnect HUD, single sign-on alert)
//  stays in ChatKit's CYLSessionService.
//  It is a `CYLSingleton`, so ChatKit resets it together with its own services after closing a session.

import Foundation
import CYLChatKit
import AVOSCloud
import AVOSCloudIM

private let CYLDemoLeanCloudSessionServiceErrorDomain = "CYLDemoLeanCloudSessionServiceErrorDomain"

/// LeanCloud error code `AVIMErrorCodeSessionConflict`: another device logged in with the same client id.
private let CYLDemoSessionConflictErrorCode = 4111

/// Raw values of `AVIMConversationUpdatedKey...` constants that make the conversation list refresh.
private let CYLDemoUpdatedKeyUnreadMessagesCount = "unreadMessagesCount"
private let CYLDemoUpdatedKeyUnreadMessagesMentioned = "unreadMessagesMentioned"
private let CYLDemoUpdatedKeyLastMessage = "lastMessage"

@objc(CYLDemoLeanCloudSessionService)
final class CYLDemoLeanCloudSessionService: CYLSingleton, AVIMClientDelegate, AVIMSignatureDataSource {

    // MARK: - Public state

    @objc private(set) var clientId: String?

    /// The LeanCloud client of the current session.
    @objc private(set) var client: AVIMClient?

    /// Whether the client is connected to the chat server.
    @objc private(set) var connect: Bool = false

    private var playingSound = false

    // MARK: - Collaborators

    private var chatKit: CYLChatKit { return CYLChatKit.sharedInstance() }
    private var conversationService: CYLDemoLeanCloudConversationService { return CYLDemoLeanCloudConversationService.sharedInstance() }
    private var coreConversationService: CYLConversationService { return CYLConversationService.sharedInstance() }
    private var coreSessionService: CYLSessionService { return CYLSessionService.sharedInstance() }

    override init() {
        super.init()
    }

    // MARK: - Session

    @objc func isClientOpened() -> Bool {
        return client?.status == .opened
    }

    /// ChatKit's CYLSessionService has validated `clientId` and dispatched to the main queue.
    func open(withClientId clientId: String, force: Bool, callback: CYLBooleanResultBlock?) {
        self.clientId = clientId
        conversationService.setupDatabase(withUserId: clientId)
        // Whether this is the first launch with this app id.
        _ = chatKit.cyl_isFirstLaunch(toEvent: chatKit.appId, evenUpdate: true, firstLaunch: { () -> Bool in
            return self.chatKit.removeAllCachedRecentConversations()
        })
        var tag: String?
        if !coreSessionService.disableSingleSignOn {
            tag = clientId
        }
        let newClient = AVIMClient(clientId: clientId, tag: tag)
        client = newClient
        newClient.delegate = self
        // With `generateSignatureBlock`, open, start (create conversation), kick, and invite are signed, which is safer.
        // The signature can come from your server or from cloud code.
        if chatKit.generateSignatureBlock != nil {
            newClient.signatureDataSource = self
        }

        var option: AVIMClientOpenOption = .reopen
        if force {
            option = .forceOpen
        }
        newClient.open(with: option) { succeeded, openError in
            self.updateConnectStatus()
            let isFirstLaunchForClientId = self.chatKit.cyl_isFirstLaunch(toEvent: clientId, evenUpdate: true, firstLaunch: { () -> Bool in
                return true
            })
            if succeeded && isFirstLaunchForClientId {
                self.conversationService.fetchRelationConversationsFromServerCallback({ conversations, fetchError in
                    DispatchQueue.global().async {
                        let typed = ((conversations as? [AVIMConversation]) ?? []).compactMap { cylDemoBridgeConversation($0) }
                        self.conversationService.insertRecentConversations(typed, shouldRefreshWhenFinished: false)
                        DispatchQueue.main.async {
                            callback?(succeeded, fetchError)
                        }
                    }
                })
            } else {
                callback?(succeeded, openError)
            }
            if let code = (openError as NSError?)?.code, code == CYLDemoSessionConflictErrorCode {
                self.handleSingleSignOnError(openError, callback: { ssoSucceeded, ssoError in
                    callback?(ssoSucceeded, ssoError)
                })
            }
        }
    }

    func close(callback: CYLBooleanResultBlock?) {
        client?.close { succeeded, closeError in
            callback?(succeeded, closeError)
        }
    }

    /// Same as `close(callback:)`, named as Objective-C's `-closeWithCallback:` imports.
    func close(withCallback callback: CYLBooleanResultBlock?) {
        close(callback: callback)
    }

    // MARK: - AVIMClientDelegate

    @objc(imClientPaused:)
    func imClientPaused(_ imClient: AVIMClient) {
        updateConnectStatus()
    }

    @objc(imClientResuming:)
    func imClientResuming(_ imClient: AVIMClient) {
        updateConnectStatus()
    }

    @objc(imClientResumed:)
    func imClientResumed(_ imClient: AVIMClient) {
        updateConnectStatus()
        NotificationCenter.default.post(name: Notification.Name(CYLNotificationSessionResumed), object: nil)
    }

    @objc(imClientClosed:error:)
    func imClientClosed(_ imClient: AVIMClient, error: Error?) {
        updateConnectStatus()
    }

    /// Another device logged in with the same client id: let ChatKit ask the user and reconnect.
    private func handleSingleSignOnError(_ aError: Error?, callback aCallback: CYLBooleanResultBlock?) {
        guard let error = aError, (error as NSError).code == CYLDemoSessionConflictErrorCode else {
            return
        }
        coreSessionService.handleSingleSignOnError(error, callback: aCallback)
    }

    @objc(client:didOfflineWithError:)
    func client(_ client: AVIMClient, didOfflineWithError aError: Error?) {
        handleSingleSignOnError(aError, callback: nil)
    }

    // MARK: - Status

    /// Called by the three SDK callbacks above and when opening the client, so the status is handled in one place.
    private func updateConnectStatus() {
        // For better UI presentation.
        if client?.status == .paused || client?.status == .resuming {
            return
        }
        connect = (client?.status == .opened)
        NotificationCenter.default.post(name: Notification.Name(CYLNotificationConnectivityUpdated),
                                        object: NSNumber(value: connect))
    }

    // MARK: - Signature

    @objc(signatureWithClientId:conversationId:action:actionOnClientIds:)
    func signature(withClientId clientId: String,
                   conversationId: String?,
                   action: String?,
                   actionOnClientIds clientIds: [String]?) -> AVIMSignature? {
        var resultSignature: AVIMSignature?
        let completionHandler: CYLGenerateSignatureCompletionHandler = { signature, error in
            if error == nil {
                resultSignature = signature as? AVIMSignature
            } else {
                NSLog("%@", String(describing: error))
            }
        }
        if let generateSignatureBlock = chatKit.generateSignatureBlock {
            generateSignatureBlock(clientId, conversationId, action, clientIds, completionHandler)
        }
        return resultSignature
    }

    // MARK: - AVIMMessageDelegate

    /// A custom message that this client version does not support is delivered here.
    @objc(conversation:didReceiveCommonMessage:)
    func conversation(_ conversation: AVIMConversation, didReceiveCommon message: AVIMMessage) {
        if !message.cylDemoIsValidMessage() {
            return
        }
        guard let typedMessage = message.cylDemoGetValidTypedMessage() else {
            return
        }
        self.conversation(conversation, didReceive: typedMessage)
    }

    @objc(conversation:didReceiveTypedMessage:)
    func conversation(_ conversation: AVIMConversation, didReceive message: AVIMTypedMessage) {
        if !message.cylDemoIsValidMessage() {
            return
        }
        if message.messageId == nil {
            NSLog("%@ [Line %d] Receive Message , but MessageId is nil", #function, #line)
            return
        }
        makeSure(conversation, isAvailableCallback: {
            self.receiveMessage(message, conversation: conversation)
        })
    }

    @objc(conversation:messageDelivered:)
    func conversation(_ conversation: AVIMConversation, messageDelivered message: AVIMMessage) {
        didReceiveStatusMessage(message, conversation: conversation)
    }

    @objc(conversation:messageRead:)
    func conversation(_ conversation: AVIMConversation, messageRead message: AVIMMessage) {
    }

    private func didReceiveStatusMessage(_ message: AVIMMessage, conversation: AVIMConversation) {
        if !message.cylDemoIsValidMessage() {
            return
        }
        let userInfo: [String: Any] = [
            CYLMessageNotifacationUserInfoConversationKey: conversation,
            CYLMessageNotifacationUserInfoMessageKey: message,
        ]
        NotificationCenter.default.post(name: Notification.Name(CYLNotificationMessageDelivered), object: userInfo)
    }

    @objc(conversation:didUpdateForKey:)
    func conversation(_ conversation: AVIMConversation, didUpdateForKey key: AVIMConversationUpdatedKey) {
        let currentConversationId = coreConversationService.currentConversationId
        let conversationId = conversation.conversationId
        let keyString = ((key as AnyObject) as? NSString).map { $0 as String } ?? ""

        let refreshingKeys = [CYLDemoUpdatedKeyUnreadMessagesCount,
                              CYLDemoUpdatedKeyUnreadMessagesMentioned,
                              CYLDemoUpdatedKeyLastMessage]
        guard refreshingKeys.contains(keyString) else {
            return
        }
        if currentConversationId == conversationId {
            // Do nothing: the conversation is open.
        } else {
            insertRecentConversation(conversation, shouldRefreshWhenFinished: true)
        }
    }

    @objc(conversation:messageHasBeenUpdated:)
    func conversation(_ conversation: AVIMConversation, messageHasBeenUpdated message: AVIMMessage) {
        let currentConversationId = coreConversationService.currentConversationId
        let conversationId = conversation.conversationId
        if currentConversationId == conversationId {
            let userInfo: [String: Any] = [
                CYLMessageNotifacationUserInfoConversationKey: conversation,
                CYLMessageNotifacationUserInfoMessageKey: message,
            ]
            NotificationCenter.default.post(name: Notification.Name(CYLNotificationMessageUpdated), object: userInfo)
        }
    }

    @objc(conversation:didMemberInfoUpdateBy:memberId:role:)
    func conversation(_ conversation: AVIMConversation,
                      didMemberInfoUpdateBy byClientId: String?,
                      memberId: String?,
                      role: AVIMConversationMemberRole) {
        let memberInfoChangedBlock = coreSessionService.memberInfoChangedBlock
        memberInfoChangedBlock?(cylDemoBridgeConversation(conversation), byClientId, memberId, UInt(role.rawValue))
    }

    private func makeSure(_ conversation: AVIMConversation, isAvailableCallback callback: CYLVoidBlock?) {
        if conversation.createAt == nil
            && !conversationService.isRecentConversationExist(withConversationId: conversation.conversationId ?? "") {
            conversation.fetch { succeeded, error in
                if succeeded {
                    callback?()
                    return
                }
                NSLog("%@ [Line %d] %@", #function, #line, String(describing: error))
            }
        } else {
            callback?()
        }
    }

    @objc(conversation:kickedByClientId:)
    func conversation(_ conversation: AVIMConversation, kickedByClientId clientId: String?) {
        NotificationCenter.default.post(name: Notification.Name(CYLNotificationConversationInvalided), object: clientId)
        if coreConversationService.currentConversationId == conversation.conversationId {
            NotificationCenter.default.post(name: Notification.Name(CYLNotificationCurrentConversationInvalided), object: clientId)
        }
    }

    // MARK: - Receive message handling

    /// Inserts the conversation into ChatKit's recent conversation list.
    private func insertRecentConversation(_ conversation: AVIMConversation, shouldRefreshWhenFinished: Bool) {
        guard let bridged = cylDemoBridgeConversation(conversation) else {
            return
        }
        coreConversationService.insertRecentConversation(bridged, shouldRefreshWhenFinished: shouldRefreshWhenFinished)
    }

    private func receiveMessage(_ message: AVIMTypedMessage, conversation: AVIMConversation) {
        if message.mediaType.rawValue > 0 {
            let userInfo: [String: Any] = [
                CYLMessageNotifacationUserInfoConversationKey: conversation,
                CYLDidReceiveCustomMessageUserInfoMessageKey: message,
            ]
            NotificationCenter.default.post(name: Notification.Name(CYLNotificationCustomTransientMessageReceived), object: userInfo)
        }
        receiveMessages([message], conversation: conversation, isUnreadMessage: false)
    }

    private func receiveMessages(_ messages: [AVIMTypedMessage],
                                 conversation: AVIMConversation,
                                 isUnreadMessage: Bool) {

        let checkMentionedMessageCallback: ([Any]) -> Void = { filterdMessages in
            // Insert into the recent conversation list.
            // The notification below also refreshes the conversation list.
            self.insertRecentConversation(conversation, shouldRefreshWhenFinished: false)
            // Play the receive sound.
            if !isUnreadMessage {
                self.playLoudReceiveSoundIfNeeded(for: conversation)
            }
            let userInfo: [String: Any] = [
                CYLMessageNotifacationUserInfoConversationKey: conversation,
                CYLDidReceiveMessagesUserInfoMessagesKey: filterdMessages,
            ]
            // Notify the pages that a message arrived: the current conversation and the recent conversations.
            NotificationCenter.default.post(name: Notification.Name(CYLNotificationMessageReceived), object: userInfo)
        }

        let filteredMessageCallback: ([Any]) -> Void = { filterdMessages in
            if filterdMessages.isEmpty { return }
            // Check whether someone mentions me.
            if self.coreConversationService.currentConversationId == conversation.conversationId
                && self.coreConversationService.isChatting
                && isUnreadMessage {
                conversation.readInBackground()
                conversation.unreadMessagesMentioned = false
                checkMentionedMessageCallback(filterdMessages)
            } else {
                // Only when not chatting: increase the unread count and set mentioned.
                let typedMessages = filterdMessages.compactMap { $0 as? AVIMTypedMessage }
                self.isMentioned(byMessages: typedMessages, callback: { succeeded, error in
                    checkMentionedMessageCallback(filterdMessages)
                    if succeeded {
                        self.coreConversationService.updateMentioned(true, conversationId: conversation.conversationId)
                        // The notification above also refreshes the conversation list.
                    }
                })
            }
        }

        if let filterMessagesBlock = coreConversationService.filterMessagesBlock {
            let filterMessagesCompletionHandler: CYLFilterMessagesCompletionHandler = { filteredMessages, error in
                if error == nil {
                    filteredMessageCallback(filteredMessages ?? [])
                }
            }
            filterMessagesBlock(cylDemoBridgeConversation(conversation),
                                messages.compactMap { cylDemoBridgeMessage($0) },
                                filterMessagesCompletionHandler)
        } else {
            filteredMessageCallback(messages)
        }
    }

    /// An unread message plays its sound once when queried, so the sound does not repeat.
    private func playLoudReceiveSoundIfNeeded(for conversation: AVIMConversation) {
        if coreConversationService.isChatting {
            conversation.readInBackground()
            return
        }
        if conversation.muted {
            return
        }
        if playingSound {
            return
        }
        playingSound = true
        CYLSoundManager.default().playLoudReceiveSoundIfNeed()
        CYLSoundManager.default().vibrateIfNeed()
        // Play the sound once within a time window.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.playingSound = false
        }
    }

    // MARK: - Mention

    private func isMentioned(byMessages messages: [AVIMTypedMessage]?, callback: CYLBooleanResultBlock?) {
        guard let messages = messages, !messages.isEmpty else {
            let code = 0
            let errorInfo: [String: Any] = [
                "code": code,
                NSLocalizedDescriptionKey: "no message to check",
            ]
            let error = NSError(domain: CYLDemoLeanCloudSessionServiceErrorDomain, code: code, userInfo: errorInfo)
            callback?(false, error)
            return
        }

        CYLUserSystemService.sharedInstance().fetchCurrentUser(inBackground: { currentUser, _ in
            let queueBaseLabel = "com.chatkit.\(NSStringFromClass(type(of: self)))"
            let queueName = "\(queueBaseLabel).\(UUID().uuidString).ForBarrier"
            let queue = DispatchQueue(label: queueName, attributes: .concurrent)
            let lock = NSLock()
            var isMentioned = false

            for message in messages {
                guard let textMessage = message as? AVIMTextMessage else {
                    continue
                }
                queue.async {
                    lock.lock()
                    let alreadyMentioned = isMentioned
                    lock.unlock()
                    if alreadyMentioned {
                        return
                    }
                    let isMentioned_ = self.isMentioned(byText: textMessage.text, currentUser: currentUser)
                    // One mention is enough.
                    if isMentioned_ {
                        lock.lock()
                        isMentioned = true
                        lock.unlock()
                    }
                }
            }

            queue.async(flags: .barrier) {
                // No mention in the last message either.
                var barrierError: NSError?
                lock.lock()
                let mentioned = isMentioned
                lock.unlock()
                if !mentioned {
                    let code = 0
                    let errorInfo: [String: Any] = [
                        "code": code,
                        NSLocalizedDescriptionKey: "not mentioned",
                    ]
                    barrierError = NSError(domain: CYLDemoLeanCloudSessionServiceErrorDomain, code: code, userInfo: errorInfo)
                }
                DispatchQueue.main.async {
                    callback?(mentioned, barrierError)
                }
            }
        })
    }

    private func isMentioned(byText text: String?, currentUser: CYLUserDelegate?) -> Bool {
        guard let text = text, !text.isEmpty else {
            return false
        }
        let displayName: String? = currentUser?.name ?? currentUser?.clientId
        let patternWithUserName = "@\(displayName ?? "") "
        let patternWithLowercaseAll = "@all "
        let patternWithUppercaseAll = "@All "
        let nsText = text as NSString
        return nsText.range(of: patternWithUserName).location != NSNotFound
            || nsText.range(of: patternWithLowercaseAll).location != NSNotFound
            || nsText.range(of: patternWithUppercaseAll).location != NSNotFound
    }
}
