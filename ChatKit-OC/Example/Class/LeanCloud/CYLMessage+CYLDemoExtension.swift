//
//  CYLMessage+CYLDemoExtension.swift
//  ChatKit-OC
//
//  Translated from Objective-C. LeanCloud conversion for ChatKit's message model.
//

import Foundation
import UIKit
import CoreLocation
import AVOSCloud
import AVOSCloudIM
import CYLChatKit

extension CYLMessage {

    /// Converts a LeanCloud message for display.
    /// - Returns: The message itself for a supported custom message, a `CYLMessage` for a built-in type,
    ///   or nil for messages ChatKit does not display (video, file, recalled).
    /// Objective-C: `+messageWithAVIMTypedMessage:`.
    @objc(messageWithAVIMTypedMessage:)
    class func message(withAVIMTypedMessage message: AVIMTypedMessage) -> Any? {
        // FIXME: custom messages
        if message.cyl_isCustomMessage() {
            if message.cylDemoIsSupportThisCustomMessage() {
                return message
            }
        }
        let senderId = message.clientId
        // The error is ignored: the sender can be nil.
        let sender: CYLUserDelegate? = senderId.flatMap {
            try? CYLUserSystemService.sharedInstance().getProfile(forUserId: $0)
        }
        var cylDemoMessage: CYLMessage?
        let time = TimeInterval(message.sendTimestamp)
        let serverMessageId = message.messageId
        let mediaType = message.mediaType

        if mediaType == AVIMMessageMediaType(kAVIMMessageMediaTypeText) {
            let textMsg = message as! AVIMTextMessage
            cylDemoMessage = CYLMessage(text: textMsg.text, senderId: senderId, sender: sender, timestamp: time, serverMessageId: serverMessageId)
        } else if mediaType == AVIMMessageMediaType(kAVIMMessageMediaTypeAudio) {
            let audioMsg = message as! AVIMAudioMessage
            let duration = String(format: "%.0f", audioMsg.duration)
            let audioFile: AVFile? = audioMsg.file
            let localPath = CYLCommonUtils.getPath(from: audioFile)
            let voicePath: String?
            if FileManager.default.fileExists(atPath: localPath) {
                voicePath = localPath
            } else {
                voicePath = audioFile?.url
            }
            cylDemoMessage = CYLMessage(voicePath: voicePath, voiceURL: nil, voiceDuration: duration, senderId: senderId, sender: sender, timestamp: time, serverMessageId: serverMessageId)
        } else if mediaType == AVIMMessageMediaType(kAVIMMessageMediaTypeLocation) {
            let locationMsg = message as! AVIMLocationMessage
            let image = UIImage.cyl_imageNamed("MessageBubble_Location", bundleName: "MessageBubble", bundleForClass: self)
            cylDemoMessage = CYLMessage(localPositionPhoto: image,
                                        geolocations: locationMsg.text,
                                        location: CLLocation(latitude: locationMsg.latitude, longitude: locationMsg.longitude),
                                        senderId: senderId,
                                        sender: sender,
                                        timestamp: time,
                                        serverMessageId: serverMessageId)
        } else if mediaType == AVIMMessageMediaType(kAVIMMessageMediaTypeImage) {
            let imageMsg = message as! AVIMImageMessage
            let imageFile: AVFile? = imageMsg.file
            let imagePath = CYLCommonUtils.getPath(from: imageFile)
            let originURL: URL? = imageFile?.url.flatMap { URL(string: $0) }
            cylDemoMessage = CYLMessage(photo: nil,
                                        photoWidth: UInt32(truncatingIfNeeded: imageMsg.width),
                                        photoHeight: UInt32(truncatingIfNeeded: imageMsg.height),
                                        thumbnailPhoto: nil,
                                        photoPath: imagePath,
                                        thumbnailURL: nil,
                                        originPhotoURL: originURL,
                                        senderId: senderId,
                                        sender: sender,
                                        timestamp: time,
                                        serverMessageId: serverMessageId)
        } else if mediaType == AVIMMessageMediaType(kAVIMMessageMediaTypeVideo)
                    || mediaType == AVIMMessageMediaType(kAVIMMessageMediaTypeFile)
                    || mediaType == AVIMMessageMediaType(kAVIMMessageMediaTypeRecalled) {
            return nil
        } else {
            let degradeKey: String = CYLCustomMessageDegradeKey
            var degradeContent = message.attributes?[degradeKey] as? String
            if degradeContent == nil {
                degradeContent = CYLLocalizedStringForKey("unknownMessage")
            }
            cylDemoMessage = CYLMessage(text: degradeContent, senderId: senderId, sender: sender, timestamp: time, serverMessageId: serverMessageId)
            #if DEBUG
            NSLog("%@ [Line %@] %@", "\(#function)", "\(#line)", CYLLocalizedStringForKey("unknownMessage"))
            #endif
        }

        guard let result = cylDemoMessage else {
            return nil
        }
        let currentClientId: String? = CYLSessionService.sharedInstance().clientId
        // CYLMessageOwnerType raw values: self 2, other 3.
        if currentClientId == message.clientId {
            result.ownerType = CYLMessageOwnerType(rawValue: 2)!
        } else {
            result.ownerType = CYLMessageOwnerType(rawValue: 3)!
        }
        result.sendStatus = message.cylSendStatus()
        result.message = message
        return result
    }

    /// Swift-only alias of `message(withAVIMTypedMessage:)` (the name Swift's importer may derive from the selector).
    class func message(with message: AVIMTypedMessage) -> Any? {
        return self.message(withAVIMTypedMessage: message)
    }
}
