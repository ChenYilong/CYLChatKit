//
//  CYLDemoLeanCloudConversationService.swift
//  ChatKit-OC
//
//  Translated from Objective-C. Originally moved from ChatKit's CYLConversationService and
//  CYLConversationListService (v2.1.1, created by ElonChan on 16/3/1 and 16/3/22).
//
//  LeanCloud conversations and messages, and the SQLite stores of recent conversations
//  and failed messages. ChatKit keeps the UI state (current conversation, hooks) in its own
//  CYLConversationService and calls this class through `CYLDemoLeanCloudIMProvider`.
//  It is a `CYLSingleton`, so ChatKit resets it together with its own services after closing a session.

import Foundation
import CYLChatKit
import AVOSCloud
import AVOSCloudIM
import FMDB

private let CYLDemoLeanCloudConversationServiceErrorDomain = "CYLDemoLeanCloudConversationServiceErrorDomain"

// MARK: - SQL
// Swift cannot import the compound SQL macros of `CYLChatConstants.h`, so they are spelled out here.
// Keep them identical to the macros (table and column names are part of the stored database).

private let cylDemoConversationTableName = "conversations"
private let cylDemoConversationTableKeyId = "id"
private let cylDemoConversationTableKeyData = "data"
private let cylDemoConversationTableKeyUnreadCount = "unreadCount"
private let cylDemoConversationTableKeyMentioned = "mentioned"
private let cylDemoConversationTableKeyDraft = "draft"

private let cylDemoConversationTableCreateSQL =
    "CREATE TABLE IF NOT EXISTS \(cylDemoConversationTableName) ("
    + "\(cylDemoConversationTableKeyId) VARCHAR(63) PRIMARY KEY, "
    + "\(cylDemoConversationTableKeyData) BLOB NOT NULL, "
    + "\(cylDemoConversationTableKeyUnreadCount) INTEGER DEFAULT 0, "
    + "\(cylDemoConversationTableKeyMentioned) BOOL DEFAULT FALSE, "
    + "\(cylDemoConversationTableKeyDraft) VARCHAR(63))"

private let cylDemoConversationTableInsertSQL =
    "INSERT OR IGNORE INTO \(cylDemoConversationTableName) ("
    + "\(cylDemoConversationTableKeyId), \(cylDemoConversationTableKeyData), "
    + "\(cylDemoConversationTableKeyUnreadCount), \(cylDemoConversationTableKeyMentioned), "
    + "\(cylDemoConversationTableKeyDraft)) VALUES(?, ?, ?, ?, ?)"

private let cylDemoConversationTableWhereClause = " WHERE \(cylDemoConversationTableKeyId) = ?"

private let cylDemoConversationTableDeleteSQL =
    "DELETE FROM \(cylDemoConversationTableName)" + cylDemoConversationTableWhereClause

private let cylDemoDeleteConversationTable = "DELETE FROM \(cylDemoConversationTableName)"

private let cylDemoConversationTableIncreaseUnreadCountSQL =
    "UPDATE \(cylDemoConversationTableName) "
    + "SET \(cylDemoConversationTableKeyUnreadCount) = \(cylDemoConversationTableKeyUnreadCount) + ?"
    + cylDemoConversationTableWhereClause

private let cylDemoConversationTableIncreaseOneUnreadCountSQL =
    "UPDATE \(cylDemoConversationTableName) "
    + "SET \(cylDemoConversationTableKeyUnreadCount) = \(cylDemoConversationTableKeyUnreadCount) + 1 "
    + cylDemoConversationTableWhereClause

private let cylDemoConversationTableUpdateUnreadCountSQL =
    "UPDATE \(cylDemoConversationTableName) SET \(cylDemoConversationTableKeyUnreadCount) = ? "
    + cylDemoConversationTableWhereClause

private let cylDemoConversationTableUpdateMentionedSQL =
    "UPDATE \(cylDemoConversationTableName) SET \(cylDemoConversationTableKeyMentioned) = ? "
    + cylDemoConversationTableWhereClause

private let cylDemoConversationTableUpdateDraftSQL =
    "UPDATE \(cylDemoConversationTableName) SET \(cylDemoConversationTableKeyDraft) = ? "
    + cylDemoConversationTableWhereClause

private let cylDemoConversationTableSelectSQL = "SELECT * FROM \(cylDemoConversationTableName)"

private let cylDemoConversationTableUpdateDataSQL =
    "UPDATE \(cylDemoConversationTableName) SET \(cylDemoConversationTableKeyData) = ? "
    + cylDemoConversationTableWhereClause

private let cylDemoFailedMessageTable = "failed_messages"
private let cylDemoKeyId = "id"
private let cylDemoKeyConversationId = "conversationId"
private let cylDemoKeyMessage = "message"

private let cylDemoCreateTableSQL =
    "CREATE TABLE IF NOT EXISTS \(cylDemoFailedMessageTable)("
    + "\(cylDemoKeyId) VARCHAR(63) PRIMARY KEY, "
    + "\(cylDemoKeyConversationId) VARCHAR(63) NOT NULL,"
    + "\(cylDemoKeyMessage) BLOB NOT NULL)"

private let cylDemoSelectMessagesSQL =
    "SELECT * FROM \(cylDemoFailedMessageTable)" + " WHERE \(cylDemoKeyConversationId) = ? "

private let cylDemoInsertMessageSQL =
    "INSERT OR IGNORE INTO \(cylDemoFailedMessageTable)("
    + "\(cylDemoKeyId),\(cylDemoKeyConversationId),\(cylDemoKeyMessage)) values (?, ?, ?) "

private let cylDemoDeleteMessageSQL =
    "DELETE FROM \(cylDemoFailedMessageTable) WHERE \(cylDemoKeyId) = ? "

/// `SELECT * FROM failed_messages WHERE id IN ('<ids>') `
private func cylDemoSelectMessagesByIDSQL(_ messageIdsString: String) -> String {
    return "SELECT * FROM \(cylDemoFailedMessageTable)" + " WHERE \(cylDemoKeyId) IN ('\(messageIdsString)') "
}

// MARK: - Bridging to the ChatKit protocols
// Swift cannot declare that `AVIMConversation` and `AVIMTypedMessage` conform to `CYLConversationProtocol` and
// `CYLIMMessageProtocol`; `CYLDemoLeanCloudRuntime.registerOnce()` adds the protocols at run time. So the SDK objects
// are handed to ChatKit through a dynamic cast, which succeeds once the protocols are registered.

func cylDemoBridgeConversation(_ conversation: AVIMConversation?) -> CYLConversationProtocol? {
    guard let conversation = conversation else {
        return nil
    }
    CYLDemoLeanCloudRuntime.registerOnce()
    return (conversation as AnyObject) as? CYLConversationProtocol
}

func cylDemoBridgeMessage(_ message: AVIMMessage?) -> CYLIMMessageProtocol? {
    guard let message = message else {
        return nil
    }
    CYLDemoLeanCloudRuntime.registerOnce()
    return (message as AnyObject) as? CYLIMMessageProtocol
}

private func cylDemoLastMessageTimestamp(of conversation: AVIMConversation) -> Int64 {
    return conversation.cylLastMessage?.cylSendTimestamp() ?? 0
}

@objc(CYLDemoLeanCloudConversationService)
final class CYLDemoLeanCloudConversationService: CYLSingleton {

    // MARK: - State

    private var databaseQueue: FMDatabaseQueue?
    private var cachedConversations: [String: AVIMConversation]?
    private let cachedConversationsLock = NSRecursiveLock()
    private lazy var sqliteQueue = DispatchQueue(label: "com.chatkit-oc.sqliteQueue")
    private var refreshedFromServer = false

    override init() {
        super.init()
        refreshedFromServer = false
    }

    // MARK: - Collaborators

    private var session: CYLDemoLeanCloudSessionService { return CYLDemoLeanCloudSessionService.sharedInstance() }
    private var chatKit: CYLChatKit { return CYLChatKit.sharedInstance() }

    private var client: AVIMClient? {
        return session.client
    }

    private func makeError(withReason reason: String?) -> NSError {
        let code = 0
        let errorInfo: [String: Any] = [
            "code": code,
            NSLocalizedDescriptionKey: reason ?? "",
        ]
        return NSError(domain: CYLDemoLeanCloudConversationServiceErrorDomain, code: code, userInfo: errorInfo)
    }

    private func postConversationListUpdated() {
        NotificationCenter.default.post(name: Notification.Name(CYLNotificationConversationListDataSourceUpdated), object: self)
    }

    // MARK: - CYLIMConversationProvider

    /// Gets a conversation by its id.
    func fetchConversation(withConversationId conversationId: String, callback: CYLIMConversationResultBlock?) {
        if let conversation = client?.conversation(forId: conversationId) {
            callback?(cylDemoBridgeConversation(conversation), nil)
            return
        }

        let conversationSet: Set<String> = [conversationId]
        fetchConversations(withConversationIds: conversationSet, callback: { objects, error in
            if error != nil {
                callback?(nil, error)
            } else {
                if objects == nil || objects?.count == 0 {
                    let errorReasonText = "conversation of \(conversationId) are not exists"
                    callback?(nil, self.makeError(withReason: errorReasonText))
                } else {
                    callback?(objects?.first as? CYLConversationProtocol, error)
                }
            }
        })
    }

    func fetchConversations(withConversationIds conversationIds: Set<String>, callback: CYLArrayResultBlock?) {
        guard let client = client else {
            callback?(nil, makeError(withReason: "Session not opened"))
            return
        }
        let query = client.conversationQuery()
        query.whereKey("objectId", containedIn: Array(conversationIds))
        query.limit = conversationIds.count
        query.option = .withMessage
        // `kAVIMCachePolicyIgnoreCache` (value 0) was assigned to the max cache age.
        query.cacheMaxAge = 0
        query.findConversations { objects, error in
            DispatchQueue.global().async {
                // Touch `lastMessage` off the main thread so the SDK loads it from its cache.
                objects?.forEach { _ = $0.lastMessage }
                DispatchQueue.main.async {
                    callback?(objects, error)
                }
            }
        }
    }

    func fetchConversation(withPeerId peerId: String, callback: CYLIMConversationResultBlock?) {
        if !session.connect {
            callback?(nil, makeError(withReason: "Session not opened"))
            return
        }
        if peerId == session.clientId {
            //TODO: add debug model
            NSLog("%@ [Line %d] You cannot chat with yourself", #function, #line)
            return
        }
        guard let myId = session.clientId else {
            return
        }
        let array = [myId, peerId]
        fetchConversation(withMembers: array, type: .single, callback: callback)
    }

    private func checkDuplicateValue(ofArray array: [String]) {
        let set = Set(array)
        if set.count != array.count {
            //TODO: add debug model
            NSLog("%@ [Line %d] The array has duplicate value", #function, #line)
            return
        }
    }

    private func fetchConversation(withMembers members: [String], type: CYLConversationType, callback: CYLIMConversationResultBlock?) {
        if let clientId = session.clientId, members.contains(clientId) == false {
            //TODO: add debug model
            NSLog("%@ [Line %d] members should contain myself", #function, #line)
            return
        }
        checkDuplicateValue(ofArray: members)
        createConversation(withMembers: members, type: type, unique: true, callback: callback)
    }

    func createConversation(withMembers members: [String], type: CYLConversationType, unique: Bool, callback: CYLIMConversationResultBlock?) {
        var name: String?
        if type == .group {
            // Default group name, for example "Tom, Jerry".
            name = groupConversationDefaultName(forUserIds: members)
        }
        // With `unique`, a conversation that already has the same members is returned.
        // Otherwise a new conversation is created.
        let options: AVIMConversationOption = unique ? .unique : []
        let attributes: [String: Any] = [CYL_CONVERSATION_TYPE: NSNumber(value: type.rawValue)]
        client?.createConversation(withName: name, clientIds: members, attributes: attributes, options: options) { conversation, error in
            callback?(cylDemoBridgeConversation(conversation), error)
        }
    }

    private func groupConversationDefaultName(forUserIds userIds: [String]) -> String {
        var allUserIds = userIds
        if let currentClientId = chatKit.clientId {
            allUserIds.append(currentClientId)
        }
        let profiles: [CYLUserDelegate]? = try? CYLUserSystemService.sharedInstance().getCachedProfilesIfExists(allUserIds)
        guard let array = profiles, !array.isEmpty else {
            return allUserIds.joined(separator: ",")
        }
        var names: [String] = []
        for user in array {
            if let name = user.name {
                names.append(name)
            } else if let clientId = user.clientId {
                names.append(clientId)
            }
        }
        return names.joined(separator: ",")
    }

    func joinConversation(_ conversation: CYLConversationProtocol, callback: CYLBooleanResultBlock?) {
        (conversation as? AVIMConversation)?.join { succeeded, error in
            callback?(succeeded, error)
        }
    }

    /// Marks all messages of the conversation as read on the server and clears its mention flag.
    func markConversation(asRead conversation: CYLConversationProtocol) {
        guard let avimConversation = conversation as? AVIMConversation else {
            return
        }
        avimConversation.readInBackground()
        avimConversation.unreadMessagesMentioned = false
    }

    /// Same as `markConversation(asRead:)`, named after the selector, in case the importer keeps the whole name.
    func markConversationAsRead(_ conversation: CYLConversationProtocol) {
        markConversation(asRead: conversation)
    }

    @objc(prepareConversation:)
    func prepareConversation(_ conversation: CYLConversationProtocol) {
        if let avimConversation = conversation as? AVIMConversation {
            pinIMClientToConversationIfNeeded(avimConversation)
        }
    }

    private func pinIMClientToConversationIfNeeded(_ conversation: AVIMConversation) {
        guard let client = client else {
            return
        }
        if conversation.imClient == nil || conversation.imClient?.clientId != client.clientId {
            conversation.setValue(client, forKey: "imClient")
        }
    }

    // MARK: - CYLIMMessageProvider

    func displayMessage(fromIMMessage message: CYLIMMessageProtocol) -> Any? {
        guard let typedMessage = message as? AVIMTypedMessage else {
            return nil
        }
        return CYLMessage.message(withAVIMTypedMessage: typedMessage)
    }

    func imMessage(fromMessage message: Any) -> CYLIMMessageProtocol? {
        if let typedMessage = message as? AVIMTypedMessage {
            return cylDemoBridgeMessage(typedMessage)
        }
        if let cylMessage = message as? CYLMessage {
            return cylDemoBridgeMessage(AVIMTypedMessage.cylDemoMessage(withCYLDemoMessage: cylMessage))
        }
        return nil
    }

    func sendMessage(_ message: CYLIMMessageProtocol,
                     conversation: CYLConversationProtocol,
                     mentionList: [String]?,
                     progressBlock: CYLProgressBlock?,
                     callback block: CYLBooleanResultBlock?) {
        guard let typedMessage = message as? AVIMTypedMessage,
              let avimConversation = conversation as? AVIMConversation else {
            return
        }
        sendMessage(typedMessage,
                    conversation: avimConversation,
                    options: .requestReceipt,
                    mentionList: mentionList,
                    progressBlock: progressBlock,
                    callback: block)
    }

    /// Sends a message with LeanCloud send options. The default options request a receipt.
    func sendMessage(_ message: AVIMTypedMessage,
                     conversation: AVIMConversation,
                     options: AVIMMessageSendOption,
                     mentionList: [String]?,
                     progressBlock: CYLProgressBlock?,
                     callback block: CYLBooleanResultBlock?) {
        let currentUser: CYLUserDelegate? = CYLUserSystemService.sharedInstance().fetchCurrentUser()
        var attributes: [AnyHashable: Any] = [:]
        // The cloud code reads the user name to build the push text, for example "Tom: dinner tonight?".
        if let name = currentUser?.name, name.count > 0 {
            // Avoid a crash on an empty name.
            attributes["username"] = name
        }
        if CYLSettingService.sharedInstance().useDevPushCerticate {
            attributes["dev"] = true
        }
        if let existing = message.attributes {
            attributes.merge(existing) { _, new in new }
        }
        message.attributes = attributes
        if let mentionList = mentionList, mentionList.count > 0 {
            message.mentionList = mentionList
        }
        conversation.send(message, options: options, progressBlock: progressBlock ?? { _ in }) { succeeded, error in
            block?(succeeded, error)
        }
    }

    func queryMessages(withConversation aConversation: CYLConversationProtocol,
                       messageId: String?,
                       timestamp: Int64,
                       limit: Int,
                       callback block: CYLArrayResultBlock?) {
        guard let conversation = aConversation as? AVIMConversation else {
            return
        }
        let callback: ([AVIMMessage]?, Error?) -> Void = { messages, error in
            if messages == nil {
                NSLog("%@ [Line %d] The SDK returned no messages, please contact the SDK maintainer", #function, #line)
            }
            // Keep only `AVIMTypedMessage`, so invalid messages cannot crash the UI.
            var typedMessages: [AVIMTypedMessage] = []
            for message in messages ?? [] {
                if let typedMessage = message.cylDemoGetValidTypedMessage() {
                    typedMessages.append(typedMessage)
                }
            }
            block?(typedMessages, error)
        }
        let unsignedLimit = UInt(max(limit, 0))
        DispatchQueue.global().async {
            if timestamp == 0 {
                // Always fetches the latest messages from the server when online. Use it for the first page.
                // The SDK sets the timestamp.
                conversation.queryMessages(withLimit: unsignedLimit) { messages, error in
                    callback(messages, error)
                }
            } else {
                // Decides from the local cache whether to ask the server. Not for the first page.
                conversation.queryMessages(beforeId: messageId, timestamp: timestamp, limit: unsignedLimit) { messages, error in
                    callback(messages, error)
                }
            }
        }
    }

    func updateMessage(_ oldMessage: CYLIMMessageProtocol,
                       withText text: String,
                       conversation: CYLConversationProtocol,
                       callback: CYLIMMessageResultBlock?) {
        guard let avimConversation = conversation as? AVIMConversation,
              let avimOldMessage = oldMessage as? AVIMMessage else {
            return
        }
        let newTypedMessage = AVIMTextMessage(text: text, attributes: nil)
        avimConversation.update(avimOldMessage, toNewMessage: newTypedMessage) { succeeded, error in
            callback?(succeeded, error, cylDemoBridgeMessage(newTypedMessage))
        }
    }

    func recallMessage(_ message: CYLIMMessageProtocol,
                       conversation: CYLConversationProtocol,
                       callback: CYLIMMessageResultBlock?) {
        guard let avimConversation = conversation as? AVIMConversation,
              let avimMessage = message as? AVIMMessage else {
            return
        }
        avimConversation.recall(avimMessage) { succeeded, error, recalledMessage in
            callback?(succeeded, error, cylDemoBridgeMessage(recalledMessage))
        }
    }

    @objc(downloadAttachmentOfMessage:completion:)
    func downloadAttachment(of message: CYLMessage, completion: @escaping (URL?, Error?) -> Void) {
        guard let typedMessage = message.message as? AVIMTypedMessage, let file = typedMessage.file else {
            completion(nil, nil)
            return
        }
        file.download { filePath, error in
            completion(filePath, error)
        }
    }

    // MARK: - Conversations local data

    private func databasePath(withUserId userId: String) -> String {
        let libPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        let appId = chatKit.appId ?? "(null)"
        return (libPath as NSString).appendingPathComponent("com.leancloud.lcchatkit.\(appId).\(userId).db")
    }

    @objc(setupDatabaseWithUserId:)
    func setupDatabase(withUserId userId: String) {
        let dbPath = databasePath(withUserId: userId)
        setupSucceedMessageDatabase(withPath: dbPath)
        setupFailedMessagesDB(withDatabasePath: dbPath)
    }

    private func setupSucceedMessageDatabase(withPath path: String) {
        databaseQueue = FMDatabaseQueue(path: path)
        databaseQueue?.inDatabase { db in
            db.executeUpdate(cylDemoConversationTableCreateSQL, withArgumentsIn: [])
        }
    }

    private func archivedData(from conversation: AVIMConversation) -> Data {
        let keyedConversation = conversation.keyedConversation()
        return NSKeyedArchiver.archivedData(withRootObject: keyedConversation)
    }

    private func restoreConversation(from data: Data) -> AVIMConversation? {
        guard let keyedConversation = NSKeyedUnarchiver.unarchiveObject(with: data) as? AVIMKeyedConversation else {
            return nil
        }
        return client?.conversation(with: keyedConversation)
    }

    // MARK: - CYLIMRecentConversationProvider

    func updateUnreadCountToZero(withConversationId conversationId: String, shouldRefreshWhenFinished: Bool) {
        let cachedConversation = cachedConversation(forId: conversationId)
        cachedConversation?.readInBackground()
        sqliteQueue.async {
            self.databaseQueue?.inDatabase { db in
                db.executeUpdate(cylDemoConversationTableUpdateUnreadCountSQL, withArgumentsIn: [0, conversationId])
            }
        }
        if shouldRefreshWhenFinished {
            postConversationListUpdated()
        }
    }

    func deleteRecentConversation(withConversationId conversationId: String, shouldRefreshWhenFinished: Bool) {
        removeCachedConversation(forId: conversationId)
        sqliteQueue.async {
            self.databaseQueue?.inDatabase { db in
                db.executeUpdate(cylDemoConversationTableDeleteSQL, withArgumentsIn: [conversationId])
            }
        }
        if shouldRefreshWhenFinished {
            postConversationListUpdated()
        }
    }

    func insertRecentConversations(_ conversations: [CYLConversationProtocol], shouldRefreshWhenFinished: Bool) {
        sqliteQueue.async {
            for aConversation in conversations {
                guard let conversation = aConversation as? AVIMConversation,
                      conversation.createAt != nil,
                      let conversationId = conversation.conversationId else {
                    continue
                }
                if self.cachedConversation(forId: conversationId) == nil {
                    self.setCachedConversation(conversation, forId: conversationId)
                }
                self.databaseQueue?.inDatabase { db in
                    let archived = self.archivedData(from: conversation)
                    db.executeUpdate(cylDemoConversationTableInsertSQL,
                                     withArgumentsIn: [conversationId, archived, 0, false, ""])
                }
            }

            DispatchQueue.main.async {
                if shouldRefreshWhenFinished {
                    self.postConversationListUpdated()
                }
            }
        }
    }

    func isRecentConversationExist(withConversationId conversationId: String) -> Bool {
        return cachedConversation(forId: conversationId) != nil
    }

    func increaseUnreadCount(_ increaseUnreadCount: UInt, withConversationId conversationId: String, shouldRefreshWhenFinished: Bool) {
        sqliteQueue.async {
            self.databaseQueue?.inDatabase { db in
                if increaseUnreadCount == 1 {
                    db.executeUpdate(cylDemoConversationTableIncreaseOneUnreadCountSQL, withArgumentsIn: [conversationId])
                } else {
                    db.executeUpdate(cylDemoConversationTableIncreaseUnreadCountSQL,
                                     withArgumentsIn: [increaseUnreadCount, conversationId])
                }
            }
        }
        if shouldRefreshWhenFinished {
            postConversationListUpdated()
        }
    }

    func updateMentioned(_ mentioned: Bool, conversationId: String, shouldRefreshWhenFinished: Bool) {
        sqliteQueue.async {
            self.databaseQueue?.inDatabase { db in
                db.executeUpdate(cylDemoConversationTableUpdateMentionedSQL, withArgumentsIn: [mentioned, conversationId])
            }
        }
        if shouldRefreshWhenFinished {
            postConversationListUpdated()
        }
    }

    func draft(withConversationId conversationId: String) -> String? {
        guard let cachedConversation = cachedConversation(forId: conversationId) else {
            return nil
        }
        return cachedConversation.cylDraft
    }

    func updateDraft(_ draft: String?, conversationId: String, shouldRefreshWhenFinished: Bool) {
        if let cachedConversation = cachedConversation(forId: conversationId) {
            cachedConversation.cylDraft = draft
        }
        sqliteQueue.async {
            self.databaseQueue?.inDatabase { db in
                db.executeUpdate(cylDemoConversationTableUpdateDraftSQL, withArgumentsIn: [draft ?? "", conversationId])
            }
        }
        if shouldRefreshWhenFinished {
            postConversationListUpdated()
        }
    }

    private func createConversation(from resultSet: FMResultSet) -> AVIMConversation? {
        guard let data = resultSet.data(forColumn: cylDemoConversationTableKeyData) else {
            return nil
        }
        let draft = resultSet.string(forColumn: cylDemoConversationTableKeyDraft)
        guard let conversation = restoreConversation(from: data) else {
            return nil
        }
        conversation.cylDraft = draft
        pinIMClientToConversationIfNeeded(conversation)
        return conversation
    }

    func allRecentConversations() -> [CYLConversationProtocol] {
        return allCachedConversations().compactMap { cylDemoBridgeConversation($0) }
    }

    func updateRecentConversation(_ conversations: [CYLConversationProtocol], shouldRefreshWhenFinished: Bool) {
        let avimConversations = conversations.compactMap { $0 as? AVIMConversation }
        for conversation in avimConversations {
            guard let conversationId = conversation.conversationId else {
                continue
            }
            if let cachedConversation = cachedConversation(forId: conversationId) {
                conversation.cylDraft = cachedConversation.cylDraft
                setCachedConversation(conversation, forId: conversationId)
            }
        }
        sqliteQueue.async {
            self.databaseQueue?.inDatabase { db in
                db.beginTransaction()
                for conversation in avimConversations {
                    db.executeUpdate(cylDemoConversationTableUpdateDataSQL,
                                     withArgumentsIn: [self.archivedData(from: conversation), conversation.conversationId as Any])
                }
                db.commit()
            }
        }
        if shouldRefreshWhenFinished {
            postConversationListUpdated()
        }
    }

    /// Removes all cached data, for example when switching users, because the name and avatar shown for the same person may change.
    func removeAllCachedRecentConversations() -> Bool {
        var removeAllCachedRecentConversationsSuccess = false
        databaseQueue?.inDatabase { db in
            removeAllCachedRecentConversationsSuccess = db.executeUpdate(cylDemoDeleteConversationTable, withArgumentsIn: [])
        }
        if removeAllCachedRecentConversationsSuccess {
            removeAllCachedConversations()
        }
        return removeAllCachedRecentConversationsSuccess
    }

    // MARK: - Conversation list

    func findRecentConversations(_ block: CYLIMRecentConversationsResultBlock?) {
        selectOrRefreshConversations { conversations, error in
            DispatchQueue.global().async {
                let allConversations = (conversations ?? []).compactMap { $0 as? AVIMConversation }
                var filterConversation: [AVIMConversation] = []
                var userIds = Set<String>()
                var totalUnreadCount: UInt = 0
                for conversation in allConversations {
                    let hasHistory = (conversation.lastMessage != nil)
                    if hasHistory {
                        filterConversation.append(conversation)
                        if conversation.cylType() == .single {
                            if let peerId = conversation.cylPeerId() {
                                userIds.insert(peerId)
                            }
                        } else {
                            if let lastMessage = conversation.cylLastMessage,
                               let userId = lastMessage.clientId {
                                userIds.insert(userId)
                            }
                        }
                    }
                    if conversation.muted == false && conversation.unreadMessagesCount > 0 {
                        totalUnreadCount += conversation.unreadMessagesCount
                    }
                }
                let sortedRooms = filterConversation.sorted {
                    cylDemoLastMessageTimestamp(of: $0) > cylDemoLastMessageTimestamp(of: $1)
                }
                DispatchQueue.main.async {
                    block?(sortedRooms.compactMap { cylDemoBridgeConversation($0) }, Int(totalUnreadCount), error)
                }

                if userIds.isEmpty {
                    return
                }
                CYLUserSystemService.sharedInstance().cacheUsers(withIds: userIds, callback: nil)
            }
        }
    }

    /// Same as `findRecentConversations(_:)`, named after the selector, in case the importer keeps `withBlock`.
    func findRecentConversations(withBlock block: CYLIMRecentConversationsResultBlock?) {
        findRecentConversations(block)
    }

    /// Fetches the current user's conversations from the server.
    func fetchRelationConversationsFromServerCallback(_ block: CYLArrayResultBlock?) {
        guard let client = client else {
            block?(nil, makeError(withReason: "Session not opened"))
            return
        }
        let orConversationQuery = client.conversationQuery()
        // `kAVIMCachePolicyIgnoreCache` has the value 0.
        orConversationQuery.setValue(0, forKey: "cachePolicy")
        orConversationQuery.option = .withMessage
        orConversationQuery.limit = 100
        orConversationQuery.findConversations { conversations, error in
            block?(conversations, error)
        }
    }

    /// Same as `fetchRelationConversationsFromServerCallback(_:)`, with the preposition split into a label.
    func fetchRelationConversations(fromServerCallback block: CYLArrayResultBlock?) {
        fetchRelationConversationsFromServerCallback(block)
    }

    private func selectOrRefreshConversations(_ block: CYLArrayResultBlock?) {
        DispatchQueue.global().async {
            let originConversations = self.allCachedConversations()
            let filterCallback: ([AVIMConversation]) -> Void = { conversations in
                if self.refreshedFromServer || !self.session.connect {
                    DispatchQueue.main.async {
                        block?(conversations, nil)
                    }
                    return
                }

                var conversationIds = Set<String>()
                for conversation in conversations {
                    if let conversationId = conversation.conversationId {
                        conversationIds.insert(conversationId)
                    }
                }
                self.fetchConversations(withConversationIds: conversationIds, callback: { objects, error in
                    if error != nil {
                        block?(conversations, error)
                        return
                    }
                    self.refreshedFromServer = true
                    DispatchQueue.global().async {
                        self.updateRecentConversation(conversations.compactMap { cylDemoBridgeConversation($0) },
                                                      shouldRefreshWhenFinished: true)
                        DispatchQueue.main.async {
                            block?(conversations, error)
                        }
                    }
                })
            }

            guard let conversationListShowHookBlock = CYLConversationListService.sharedInstance().conversationListShowHookBlock else {
                filterCallback(originConversations)
                return
            }
            let conversationListShowHookCompletionHandler: CYLConversationListShowHookCompletionHandler = { conversations, aError in
                if aError != nil {
                    filterCallback(originConversations)
                } else {
                    filterCallback((conversations ?? []).compactMap { $0 as? AVIMConversation })
                }
            }
            conversationListShowHookBlock(originConversations.compactMap { cylDemoBridgeConversation($0) },
                                          conversationListShowHookCompletionHandler)
        }
    }

    // MARK: - Conversation cache

    /// Caches conversations in memory so the database is not queried again and again. The database only gets
    /// inserts, deletes, and updates, and is kept in sync with this cache. The first access loads it from the database.
    private func withCachedConversations<T>(_ body: (inout [String: AVIMConversation]) -> T) -> T {
        cachedConversationsLock.lock()
        defer { cachedConversationsLock.unlock() }
        if cachedConversations == nil {
            var loaded: [String: AVIMConversation] = [:]
            databaseQueue?.inDatabase { db in
                let resultSet = db.executeQuery(cylDemoConversationTableSelectSQL, withArgumentsIn: [])
                while let resultSet = resultSet, resultSet.next() {
                    if let conversation = self.createConversation(from: resultSet),
                       conversation.createAt != nil,
                       let conversationId = conversation.conversationId {
                        loaded[conversationId] = conversation
                    }
                }
                resultSet?.close()
            }
            cachedConversations = loaded
        }
        return body(&cachedConversations!)
    }

    private func cachedConversation(forId conversationId: String) -> AVIMConversation? {
        return withCachedConversations { $0[conversationId] }
    }

    private func setCachedConversation(_ conversation: AVIMConversation, forId conversationId: String) {
        withCachedConversations { $0[conversationId] = conversation }
    }

    private func removeCachedConversation(forId conversationId: String) {
        withCachedConversations { _ = $0.removeValue(forKey: conversationId) }
    }

    private func allCachedConversations() -> [AVIMConversation] {
        return withCachedConversations { Array($0.values) }
    }

    private func removeAllCachedConversations() {
        withCachedConversations { $0.removeAll() }
    }

    // MARK: - CYLIMFailedMessageProvider

    /// Called when opening the client. `path` depends on the client id.
    private func setupFailedMessagesDB(withDatabasePath path: String) {
        if databaseQueue == nil {
            NSLog("%@ [Line %d] database queue should not be nil !!!!", #function, #line)
        }
        databaseQueue = FMDatabaseQueue(path: path)
        databaseQueue?.inDatabase { db in
            db.executeUpdate(cylDemoCreateTableSQL, withArgumentsIn: [])
        }
    }

    private struct FailedMessageRecord {
        let message: Any
        let id: String
    }

    private func record(from resultSet: FMResultSet) -> FailedMessageRecord? {
        guard let data = resultSet.data(forColumn: cylDemoKeyMessage),
              let message = NSKeyedUnarchiver.unarchiveObject(with: data),
              let idValue = resultSet.string(forColumn: cylDemoKeyId) else {
            return nil
        }
        return FailedMessageRecord(message: message, id: idValue)
    }

    private func records(byConversationId conversationId: String) -> [FailedMessageRecord] {
        var records: [FailedMessageRecord] = []
        databaseQueue?.inDatabase { db in
            let resultSet = db.executeQuery(cylDemoSelectMessagesSQL, withArgumentsIn: [conversationId])
            while let resultSet = resultSet, resultSet.next() {
                if let record = self.record(from: resultSet) {
                    records.append(record)
                }
            }
            resultSet?.close()
        }
        return records
    }

    func failedMessages(byConversationId conversationId: String) -> [CYLMessage] {
        return records(byConversationId: conversationId).compactMap { $0.message as? CYLMessage }
    }

    func failedMessageIds(byConversationId conversationId: String) -> [String] {
        return records(byConversationId: conversationId).map { $0.id }
    }

    private func records(byMessageIds messageIds: [String]) -> [FailedMessageRecord] {
        let messageIdsString = messageIds.joined(separator: "','")
        var records: [FailedMessageRecord] = []
        let query = cylDemoSelectMessagesByIDSQL(messageIdsString)
        databaseQueue?.inDatabase { db in
            let resultSet = db.executeQuery(query, withArgumentsIn: [])
            while let resultSet = resultSet, resultSet.next() {
                if let record = self.record(from: resultSet) {
                    records.append(record)
                }
            }
            resultSet?.close()
        }
        return records
    }

    func failedMessages(byMessageIds messageIds: [String]) -> [CYLMessage]? {
        let records = self.records(byMessageIds: messageIds)
        if records.isEmpty {
            return nil
        }
        return records.compactMap { $0.message as? CYLMessage }
    }

    func deleteFailedMessage(byRecordId recordId: String) -> Bool {
        var result = false
        databaseQueue?.inDatabase { db in
            result = db.executeUpdate(cylDemoDeleteMessageSQL, withArgumentsIn: [recordId])
        }
        return result
    }

    func insertFailedCYLMessage(_ message: CYLMessage) {
        let data = NSKeyedArchiver.archivedData(withRootObject: message)
        databaseQueue?.inDatabase { db in
            db.executeUpdate(cylDemoInsertMessageSQL,
                             withArgumentsIn: [message.localMessageId as Any, message.conversationId as Any, data])
        }
    }

    /// Same as `insertFailedCYLMessage(_:)`, named as the importer shortens it (the type name `CYLMessage` is dropped).
    func insertFailed(_ message: CYLMessage) {
        insertFailedCYLMessage(message)
    }

    func insertFailedMessage(_ message: CYLIMMessageProtocol) {
        let data = NSKeyedArchiver.archivedData(withRootObject: message)
        databaseQueue?.inDatabase { db in
            db.executeUpdate(cylDemoInsertMessageSQL,
                             withArgumentsIn: [message.messageId() as Any, message.conversationId() as Any, data])
        }
    }
}
