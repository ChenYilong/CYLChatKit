//
//  AVIMMessage+CYLDemoExtension.swift
//  ChatKit-OC
//
//  Translated from Objective-C.
//

import Foundation
import AVOSCloud
import AVOSCloudIM
import CYLChatKit

extension AVIMMessage {

    /// Objective-C: `-cyl_demo_isValidMessage`.
    func cylDemoIsValidMessage() -> Bool {
        let messageToCheck: AnyObject? = self
        if messageToCheck == nil || messageToCheck === NSNull() {
            return false
        }
        return true
    }

    /// Objective-C: `-cyl_demo_getValidTypedMessage`.
    /// Returns the message itself when it is typed, otherwise a degraded text message built from its JSON content.
    func cylDemoGetValidTypedMessage() -> AVIMTypedMessage? {
        if !cylDemoIsValidMessage() {
            return nil
        }
        if let typedMessage = self as? AVIMTypedMessage {
            return typedMessage
        }
        // The SDK returns a plain `AVIMMessage` for a custom message it does not recognize.
        // Every branch below assigns it, so it is never nil.
        let messageText: String
        var attributes: [AnyHashable: Any]?
        let json: [AnyHashable: Any]? = content.flatMap { ($0 as NSString).cyl_JSONValue() }
        if let degradeText = json?["_lctext"] as? String, degradeText.count > 0 {
            messageText = degradeText
        } else {
            attributes = json?["_lcattrs"] as? [AnyHashable: Any]
            let degradeKey: String = CYLCustomMessageDegradeKey
            if let attributeDegradeText = attributes?[degradeKey] as? String, attributeDegradeText.count > 0 {
                messageText = attributeDegradeText
            } else {
                messageText = CYLLocalizedStringForKey("unknownMessage")
            }
        }
        let typedMessage = AVIMTextMessage(text: messageText, attributes: attributes)
        typedMessage.setValue(conversationId, forKey: "conversationId")
        typedMessage.setValue(messageId, forKey: "messageId")
        typedMessage.setValue(NSNumber(value: sendTimestamp), forKey: "sendTimestamp")
        typedMessage.setValue(clientId, forKey: "clientId")
        let isCustomKey: String = CYLCustomMessageIsCustomKey
        typedMessage.cylDemoSetObject(true, forKey: isCustomKey)
        return typedMessage
    }
}
