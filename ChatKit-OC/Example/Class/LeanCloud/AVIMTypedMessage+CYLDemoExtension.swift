//
//  AVIMTypedMessage+CYLDemoExtension.swift
//  ChatKit-OC
//
//  Translated from Objective-C. Makes `AVIMTypedMessage` satisfy ChatKit's `CYLIMMessageProtocol`.
//
//  The protocol declares its members as methods (`-mediaType`, `-messageId`, ...) while the SDK class has properties
//  with the same getters, so Swift cannot declare the conformance statically. The selectors exist at run time, and
//  `CYLDemoLeanCloudRuntime.registerOnce()` adds the protocol to the class so `-conformsToProtocol:` in core answers YES.
//  The members below are the ones the SDK class does not have.
//

import Foundation
import AVOSCloud
import AVOSCloudIM
import CYLChatKit

extension AVIMTypedMessage {

    // MARK: - CYLIMMessageProtocol (selectors required by core)

    @objc(cyl_senderId)
    func cylSenderId() -> String? {
        return clientId
    }

    @objc(setCyl_senderId:)
    func cylSetSenderId(_ senderId: String?) {
        setValue(senderId, forKey: "clientId")
    }

    @objc(cyl_ownerType)
    func cylOwnerType() -> CYLMessageOwnerType {
        // CYLMessageOwnerType raw values: unknown 0, system 1, self 2, other 3.
        let rawValue: UInt
        switch ioType {
        case .out:
            rawValue = 2
        case .in:
            rawValue = 3
        default:
            rawValue = 0
        }
        return CYLMessageOwnerType(rawValue: rawValue) ?? CYLMessageOwnerType(rawValue: 0)!
    }

    @objc(cyl_sendStatus)
    func cylSendStatus() -> CYLMessageSendState {
        // AVIMMessageStatus and CYLMessageSendState share the same raw values.
        let rawValue = UInt(clamping: Int(status.rawValue))
        return CYLMessageSendState(rawValue: rawValue) ?? CYLMessageSendState(rawValue: 0)!
    }

    @objc(cyl_sendTimestamp)
    func cylSendTimestamp() -> Int64 {
        return sendTimestamp
    }

    // MARK: - LeanCloud helpers

    /// Whether the custom message class is registered with `+[AVIMTypedMessage registerSubclass]`.
    /// Objective-C: `-cyl_demo_isSupportThisCustomMessage`.
    func cylDemoIsSupportThisCustomMessage() -> Bool {
        return CYLDemoLeanCloudRuntime.isCustomMessageTypeRegistered(mediaType)
    }

    /// Converts a ChatKit message to a LeanCloud message. Objective-C: `+cyl_demo_messageWithCYLDemoMessage:`.
    class func cylDemoMessage(withCYLDemoMessage message: CYLMessage) -> AVIMTypedMessage? {
        var avimTypedMessage: AVIMTypedMessage?
        switch message.mediaType {
        case .text:
            avimTypedMessage = AVIMTextMessage(text: message.text, attributes: nil)
        case .video, .image:
            let localPhotoPath: String? = message.photoPath
            // `originPhotoURL` is an URL; reading it as a string crashed on `-hasPrefix:`.
            let remotePhotoPath: String? = message.originPhotoURL?.absoluteString
            if let remote = remotePhotoPath, remote.hasPrefix("http"), let url = URL(string: remote) {
                let file = AVFile(remoteURL: url)
                avimTypedMessage = AVIMImageMessage(text: nil, file: file, attributes: nil)
            } else if let local = localPhotoPath, local.hasPrefix("http"), let url = URL(string: local) {
                let file = AVFile(remoteURL: url)
                avimTypedMessage = AVIMImageMessage(text: nil, file: file, attributes: nil)
            } else {
                avimTypedMessage = AVIMImageMessage(text: nil, attachedFilePath: message.photoPath, attributes: nil)
            }
        case .audio:
            avimTypedMessage = AVIMAudioMessage(text: nil, attachedFilePath: message.voicePath, attributes: nil)
        case .location:
            avimTypedMessage = AVIMLocationMessage(text: message.geolocations,
                                                   latitude: message.location.coordinate.latitude,
                                                   longitude: message.location.coordinate.longitude,
                                                   attributes: nil)
        case .none:
            // TODO: the Objective-C code left this case empty.
            break
        default:
            break
        }
        avimTypedMessage?.setObject(NSNumber(value: Date().timeIntervalSince1970 * 1000), forKey: "sendTimestamp")
        return avimTypedMessage
    }

    /// Adds one attribute, keeping the existing ones. Objective-C: `-cyl_demo_setObject:forKey:`.
    func cylDemoSetObject(_ object: Any, forKey key: String) {
        var newAttributes: [AnyHashable: Any] = [key: object]
        if let existing = attributes {
            // Existing entries win, as `-addEntriesFromDictionary:` did.
            newAttributes.merge(existing) { _, existingValue in existingValue }
        }
        attributes = newAttributes
    }
}
