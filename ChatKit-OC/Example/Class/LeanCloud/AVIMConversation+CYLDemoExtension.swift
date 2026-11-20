//
//  AVIMConversation+CYLDemoExtension.swift
//  ChatKit-OC
//
//  Translated from Objective-C. Makes `AVIMConversation` satisfy ChatKit's `CYLConversationProtocol`.
//
//  The protocol declares its members as methods (`-name`, `-members`, ...) while the SDK class has properties with the
//  same getters, so Swift cannot declare the conformance statically. The selectors exist at run time, and
//  `CYLDemoLeanCloudRuntime.registerOnce()` adds the protocol to the class so `-conformsToProtocol:` answers YES.
//  The `@objc(cyl_...)` names keep the Objective-C selectors that core calls; the Swift names have no underscores.
//

import Foundation
import AVOSCloud
import AVOSCloudIM
import CYLChatKit

private var cylDemoDraftAssociationKey: UInt8 = 0

extension AVIMConversation {

    /// The last message visible to the current user, found through the SDK's message cache.
    @objc(cyl_lastMessage)
    var cylLastMessage: AVIMTypedMessage? {
        let lastMessageFromCache = lastMessage?.cylDemoGetValidTypedMessage()
        let visibleKey: String = CYLCustomMessageOnlyVisiableForPartClientIds
        let visibleForPartClientIds = lastMessageFromCache?.attributes?[visibleKey]
        let currentClientId: String? = CYLChatKit.sharedInstance().clientId
        if visibleForPartClientIds == nil {
            return lastMessageFromCache
        }
        if let clientIds = visibleForPartClientIds as? [Any], clientIds.count > 0 {
            let visibleForCurrentClientId = clientIds.contains { ($0 as? String) == currentClientId }
            return visibleForCurrentClientId ? lastMessageFromCache : nil
        }
        if let clientIdString = visibleForPartClientIds as? String, clientIdString.count > 0 {
            return clientIdString == currentClientId ? lastMessageFromCache : nil
        }
        return nil
    }

    @objc(cyl_lastMessageAt)
    var cylLastMessageAt: Date? {
        let dateFromServer = lastMessageAt
        let dateFromCache = Date(timeIntervalSince1970: TimeInterval((cylLastMessage?.sendTimestamp ?? 0) / 1000))
        let isServerLate = (dateFromServer as NSDate?)?.cyl_isLaterThan(dateFromCache) ?? false
        return isServerLate ? dateFromServer : dateFromCache
    }

    /// The unread message count, that is `unreadMessagesCount`.
    @objc(cyl_unreadCount)
    func cylUnreadCount() -> Int {
        return Int(unreadMessagesCount)
    }

    /// Whether someone mentioned the current user, that is `unreadMessagesMentioned`.
    @objc(cyl_mentioned)
    func cylMentioned() -> Bool {
        return unreadMessagesMentioned
    }

    /// The unread count as text. Counts above 99 are shown as an ellipsis.
    @objc(cyl_badgeText)
    func cylBadgeText() -> String? {
        let unreadCount = unreadMessagesCount
        if unreadCount > 99 {
            let limitText: String = CYLBadgeTextForNumberGreaterThanLimit
            return limitText
        }
        return "\(unreadCount)"
    }

    /// The unsent draft. Getter selector `cyl_draft`, setter selector `setCyl_draft:`.
    @objc(cyl_draft)
    var cylDraft: String? {
        get {
            return objc_getAssociatedObject(self, &cylDemoDraftAssociationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &cylDemoDraftAssociationKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    /// One-to-one or group, by member count. A system conversation counts as a group.
    @objc(cyl_type)
    func cylType() -> CYLConversationType {
        if members?.count == 2 {
            return .single
        }
        return .group
    }

    /// The client id of the other member of a one-to-one conversation.
    @objc(cyl_peerId)
    func cylPeerId() -> String? {
        guard let members = members, members.count > 0 else {
            NSLog("[CYLDemo] %@ (line %@): invalid conversation", "\(#function)", "\(#line)")
            return nil
        }
        if members.count == 1 {
            return members[0]
        }
        let currentClientId: String? = CYLSessionService.sharedInstance().clientId
        if members[0] == currentClientId {
            return members[1]
        }
        return members[0]
    }

    /// The peer's name for a one-to-one conversation, otherwise the conversation name.
    @objc(cyl_displayName)
    func cylDisplayName() -> String? {
        let disablePreviewUserId = CYLSettingService.sharedInstance().isDisablePreviewUserId
        if cylType() == .single {
            let peerId = cylPeerId()
            let peers = (try? CYLUserSystemService.sharedInstance().getCachedProfilesIfExists([peerId ?? ""])) ?? []
            let peer: CYLUserDelegate? = peers.first
            let peerName: String? = peer?.name
            var displayName = peerName ?? peerId
            if peerName == nil && disablePreviewUserId {
                let defaultNickNameWhenNil = CYLLocalizedStringForKey("nickNameIsNil")
                displayName = defaultNickNameWhenNil.count > 0 ? defaultNickNameWhenNil : ""
            }
            return displayName
        }
        if let name = name, name.count > 0 {
            return name
        }
        if (members?.count ?? 0) == 0 {
            return CYLLocalizedStringForKey("SystemConversation")
        }
        return CYLLocalizedStringForKey("GroupConversation")
    }

    /// The navigation title, such as `Group(30)`.
    @objc(cyl_title)
    func cylTitle() -> String? {
        var displayName = cylDisplayName()
        if displayName == nil || displayName?.count == 0 || displayName == CYLLocalizedStringForKey("nickNameIsNil") {
            displayName = CYLLocalizedStringForKey("Chat")
        }
        let memberCount = members?.count ?? 0
        if cylType() == .single || memberCount == 0 {
            return displayName
        }
        return "\(displayName ?? "")(\(memberCount))"
    }

    /// Mutes or unmutes the conversation. Objective-C: `-cyl_setConversationWithMute:callback:`.
    @objc(cyl_setConversationWithMute:callback:)
    func cylSetConversation(withMute mute: Bool, callback: CYLBooleanResultBlock?) {
        if mute {
            self.mute(callback: { succeeded, error in
                callback?(succeeded, error)
            })
        } else {
            unmute(callback: { succeeded, error in
                callback?(succeeded, error)
            })
        }
    }

    @objc(cyl_isCreaterForCurrentUser)
    func cylIsCreaterForCurrentUser() -> Bool {
        let currentClientId: String? = CYLChatKit.sharedInstance().clientId
        return creator == currentClientId
    }
}
