//
//  CYLDemoLeanCloudIMProvider.swift
//  ChatKit-OC
//
//  Translated from Objective-C. The LeanCloud implementation of ChatKit's `CYLIMProvider`.
//  ChatKit is UI only; the demo plugs LeanCloud in with:
//
//  ```
//  CYLChatKit.sharedInstance().imProvider = CYLDemoLeanCloudIMProvider()
//  ```
//
//  A stateless adapter. Session state lives in `CYLDemoLeanCloudSessionService` and conversation state in
//  `CYLDemoLeanCloudConversationService`; both are `CYLSingleton` subclasses that ChatKit resets after closing a session.
//

import Foundation
import UIKit
import AVOSCloud
import AVOSCloudIM
import CYLChatKit

// MARK: - Run-time registration

/// Replaces what Objective-C did at load time: registers the custom message class with the SDK and adds the ChatKit
/// protocols to the SDK classes (Swift cannot declare that conformance, see `AVIMTypedMessage+CYLDemoExtension.swift`).
/// `CYLDemoLeanCloudIMProvider.init()` calls it; the app may also call it earlier, for example at launch.
enum CYLDemoLeanCloudRuntime {

    private static var registeredMediaTypes = Set<Int>()

    private static let registration: Bool = {
        // Same as `+load` of `CYLDemoEmotionMessage` in the Objective-C code.
        CYLDemoEmotionMessage.registerSubclass()
        registeredMediaTypes.insert(Int(CYLDemoEmotionMessage.classMediaType().rawValue))
        addProtocol(CYLIMMessageProtocol.self, to: AVIMTypedMessage.self)
        addProtocol(CYLConversationProtocol.self, to: AVIMConversation.self)
        return true
    }()

    static func registerOnce() {
        _ = registration
    }

    /// Whether a custom message class with this media type is registered (the SDK keeps its own private registry).
    static func isCustomMessageTypeRegistered(_ mediaType: AVIMMessageMediaType) -> Bool {
        registerOnce()
        return registeredMediaTypes.contains(Int(mediaType.rawValue))
    }

    private static func addProtocol(_ protocolObject: Protocol, to cls: AnyClass) {
        if !class_conformsToProtocol(cls, protocolObject) {
            _ = class_addProtocol(cls, protocolObject)
        }
    }
}

// MARK: - Provider

@objc(CYLDemoLeanCloudIMProvider)
final class CYLDemoLeanCloudIMProvider: NSObject, CYLIMProvider {

    override init() {
        CYLDemoLeanCloudRuntime.registerOnce()
        super.init()
    }

    private var session: CYLDemoLeanCloudSessionService {
        return CYLDemoLeanCloudSessionService.sharedInstance()
    }

    private var conversations: CYLDemoLeanCloudConversationService {
        return CYLDemoLeanCloudConversationService.sharedInstance()
    }

    // MARK: CYLIMSessionProvider

    func clientId() -> String? {
        return session.clientId
    }

    func isConnected() -> Bool {
        return session.connect
    }

    func isClientOpened() -> Bool {
        return session.isClientOpened()
    }

    func open(withClientId clientId: String, force: Bool, callback: CYLBooleanResultBlock?) {
        session.open(withClientId: clientId, force: force, callback: callback)
    }

    func close(callback: CYLBooleanResultBlock?) {
        session.close(callback: callback)
    }

    func client() -> Any? {
        return session.client
    }

    func setAppId(_ appId: String, appKey: String) {
        AVOSCloud.setApplicationId(appId, clientKey: appKey)
    }

    func setAllLogsEnabled(_ enabled: Bool) {
        // The Objective-C code ignored the argument and always enabled the logs; behavior is kept.
        AVOSCloud.setAllLogsEnabled(true)
    }

    // MARK: CYLIMConversationProvider

    func fetchConversation(withConversationId conversationId: String, callback: CYLIMConversationResultBlock?) {
        conversations.fetchConversation(withConversationId: conversationId, callback: callback)
    }

    func fetchConversations(withConversationIds conversationIds: Set<String>, callback: CYLArrayResultBlock?) {
        conversations.fetchConversations(withConversationIds: conversationIds, callback: callback)
    }

    func fetchConversation(withPeerId peerId: String, callback: CYLIMConversationResultBlock?) {
        conversations.fetchConversation(withPeerId: peerId, callback: callback)
    }

    func createConversation(withMembers members: [String], type: CYLConversationType, unique: Bool, callback: CYLIMConversationResultBlock?) {
        conversations.createConversation(withMembers: members, type: type, unique: unique, callback: callback)
    }

    func joinConversation(_ conversation: CYLConversationProtocol, callback: CYLBooleanResultBlock?) {
        conversations.joinConversation(conversation, callback: callback)
    }

    func markConversation(asRead conversation: CYLConversationProtocol) {
        conversations.markConversationAsRead(conversation)
    }

    func prepareConversation(_ conversation: CYLConversationProtocol) {
        conversations.prepareConversation(conversation)
    }

    // MARK: CYLIMMessageProvider

    func displayMessage(fromIMMessage message: CYLIMMessageProtocol) -> Any? {
        return conversations.displayMessage(fromIMMessage: message)
    }

    func imMessage(fromMessage message: Any) -> CYLIMMessageProtocol? {
        return conversations.imMessage(fromMessage: message)
    }

    func sendMessage(_ message: CYLIMMessageProtocol,
                     conversation: CYLConversationProtocol,
                     mentionList: [String]?,
                     progressBlock: CYLProgressBlock?,
                     callback: CYLBooleanResultBlock?) {
        conversations.sendMessage(message, conversation: conversation, mentionList: mentionList, progressBlock: progressBlock, callback: callback)
    }

    func queryMessages(withConversation conversation: CYLConversationProtocol,
                       messageId: String?,
                       timestamp: Int64,
                       limit: Int,
                       callback: CYLArrayResultBlock?) {
        conversations.queryMessages(withConversation: conversation, messageId: messageId, timestamp: timestamp, limit: limit, callback: callback)
    }

    func updateMessage(_ oldMessage: CYLIMMessageProtocol,
                       withText text: String,
                       conversation: CYLConversationProtocol,
                       callback: CYLIMMessageResultBlock?) {
        conversations.updateMessage(oldMessage, withText: text, conversation: conversation, callback: callback)
    }

    func recallMessage(_ message: CYLIMMessageProtocol,
                       conversation: CYLConversationProtocol,
                       callback: CYLIMMessageResultBlock?) {
        conversations.recallMessage(message, conversation: conversation, callback: callback)
    }

    func downloadAttachment(of message: CYLMessage, completion: @escaping (URL?, Error?) -> Void) {
        conversations.downloadAttachment(of: message, completion: completion)
    }

    // MARK: CYLIMRecentConversationProvider

    func setupDatabase(withUserId userId: String) {
        conversations.setupDatabase(withUserId: userId)
    }

    func allRecentConversations() -> [CYLConversationProtocol] {
        return conversations.allRecentConversations()
    }

    func isRecentConversationExist(withConversationId conversationId: String) -> Bool {
        return conversations.isRecentConversationExist(withConversationId: conversationId)
    }

    func insertRecentConversations(_ conversations: [CYLConversationProtocol], shouldRefreshWhenFinished: Bool) {
        self.conversations.insertRecentConversations(conversations, shouldRefreshWhenFinished: shouldRefreshWhenFinished)
    }

    func updateRecentConversation(_ conversations: [CYLConversationProtocol], shouldRefreshWhenFinished: Bool) {
        self.conversations.updateRecentConversation(conversations, shouldRefreshWhenFinished: shouldRefreshWhenFinished)
    }

    func deleteRecentConversation(withConversationId conversationId: String, shouldRefreshWhenFinished: Bool) {
        conversations.deleteRecentConversation(withConversationId: conversationId, shouldRefreshWhenFinished: shouldRefreshWhenFinished)
    }

    func updateUnreadCountToZero(withConversationId conversationId: String, shouldRefreshWhenFinished: Bool) {
        conversations.updateUnreadCountToZero(withConversationId: conversationId, shouldRefreshWhenFinished: shouldRefreshWhenFinished)
    }

    func increaseUnreadCount(_ increaseUnreadCount: UInt, withConversationId conversationId: String, shouldRefreshWhenFinished: Bool) {
        conversations.increaseUnreadCount(increaseUnreadCount, withConversationId: conversationId, shouldRefreshWhenFinished: shouldRefreshWhenFinished)
    }

    func updateMentioned(_ mentioned: Bool, conversationId: String, shouldRefreshWhenFinished: Bool) {
        conversations.updateMentioned(mentioned, conversationId: conversationId, shouldRefreshWhenFinished: shouldRefreshWhenFinished)
    }

    func updateDraft(_ draft: String?, conversationId: String, shouldRefreshWhenFinished: Bool) {
        conversations.updateDraft(draft, conversationId: conversationId, shouldRefreshWhenFinished: shouldRefreshWhenFinished)
    }

    func draft(withConversationId conversationId: String) -> String? {
        return conversations.draft(withConversationId: conversationId)
    }

    func removeAllCachedRecentConversations() -> Bool {
        return conversations.removeAllCachedRecentConversations()
    }

    func findRecentConversations(block: CYLIMRecentConversationsResultBlock?) {
        conversations.findRecentConversations(withBlock: block)
    }

    func fetchRelationConversations(fromServerCallback block: CYLArrayResultBlock?) {
        conversations.fetchRelationConversationsFromServerCallback(block)
    }

    // MARK: CYLIMFailedMessageProvider

    func insertFailedCYLMessage(_ message: CYLMessage) {
        conversations.insertFailedCYLMessage(message)
    }

    func insertFailedMessage(_ message: CYLIMMessageProtocol) {
        conversations.insertFailedMessage(message)
    }

    func deleteFailedMessage(byRecordId recordId: String) -> Bool {
        return conversations.deleteFailedMessage(byRecordId: recordId)
    }

    func failedMessages(byConversationId conversationId: String) -> [CYLMessage] {
        return conversations.failedMessages(byConversationId: conversationId)
    }

    func failedMessageIds(byConversationId conversationId: String) -> [String] {
        return conversations.failedMessageIds(byConversationId: conversationId)
    }

    func failedMessages(byMessageIds messageIds: [String]) -> [CYLMessage]? {
        return conversations.failedMessages(byMessageIds: messageIds)
    }

    // MARK: CYLIMPushProvider

    func registerForRemoteNotification() {
        AVOSCloud.registerForRemoteNotification()
    }

    func saveInstallation(withDeviceToken deviceToken: Data, userId: String?) {
        let currentInstallation = AVInstallation.current()
        currentInstallation.setDeviceTokenFrom(deviceToken)
        // FIXME: openClient also registers the clientId in the channels, is this redundant?
        if let userId = userId {
            currentInstallation.addUniqueObject(userId, forKey: CYLInstallationKeyChannels)
        }
        currentInstallation.saveInBackground { _, error in
            NSLog("%@", error.map { "\($0)" } ?? "(null)")
        }
    }

    func pushMessage(_ message: String, userIds: [String], block: CYLBooleanResultBlock?) {
        let push = AVPush()
        push.setChannels(userIds)
        push.setMessage(message)
        // Called by selector so the Swift name of `-sendPushInBackgroundWithBlock:` does not matter.
        let sendBlock: @convention(block) (Bool, Error?) -> Void = { succeeded, error in
            block?(succeeded, error)
        }
        _ = push.perform(NSSelectorFromString("sendPushInBackgroundWithBlock:"), with: sendBlock as AnyObject)
    }

    func cleanBadge() {
        let application = UIApplication.shared
        let num = application.applicationIconBadgeNumber
        if num != 0 {
            let currentInstallation = AVInstallation.current()
            currentInstallation.badge = 0
            currentInstallation.saveInBackground { _, error in
                NSLog("%@", error.map { "\($0)" } ?? "succeed")
            }
            application.applicationIconBadgeNumber = 0
        }
        application.cancelAllLocalNotifications()
    }

    func syncBadge() {
        let currentInstallation = AVInstallation.current()
        let applicationBadge = UIApplication.shared.applicationIconBadgeNumber
        if currentInstallation.badge != applicationBadge {
            currentInstallation.badge = applicationBadge
            currentInstallation.saveEventually { _, error in
                NSLog("%@", error.map { "\($0)" } ?? "succeed")
            }
        }
    }

    func setUseDevPushCerticate(_ useDevPushCerticate: Bool) {
        AVPush.setProductionMode(!useDevPushCerticate)
    }
}
