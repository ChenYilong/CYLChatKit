//
//  CYLDemoEmotionMessage.swift
//  ChatKit-OC
//
//  Translated from Objective-C. A custom LeanCloud typed message that carries an emotion path.
//

import Foundation
import AVOSCloud
import AVOSCloudIM

/// The media type of `CYLDemoEmotionMessage`. Positive values are reserved for custom messages.
let kAVIMMessageMediaTypeEmotion: AVIMMessageMediaType = 1

private let cylDemoEmotionPathKey = "emotionPath"

@objc(CYLDemoEmotionMessage)
final class CYLDemoEmotionMessage: AVIMTypedMessage, AVIMTypedMessageSubclassing {

    // MARK: - AVIMTypedMessageSubclassing

    @objc class func classMediaType() -> AVIMMessageMediaType {
        return kAVIMMessageMediaTypeEmotion
    }

    // MARK: - Factory

    /// Creates an emotion message. Objective-C selector: `+messageWithEmotionPath:`.
    @objc(messageWithEmotionPath:)
    class func message(withEmotionPath emotionPath: String) -> CYLDemoEmotionMessage? {
        // The factory `+[AVIMTypedMessage messageWithText:file:attributes:]` is called through its implementation so the
        // instance has this subclass (the Objective-C code used `[super messageWithText:...]` in a class method).
        let selector = NSSelectorFromString("messageWithText:file:attributes:")
        guard let method = class_getClassMethod(CYLDemoEmotionMessage.self, selector) else {
            return nil
        }
        typealias Factory = @convention(c) (AnyClass, Selector, NSString?, AnyObject?, NSDictionary?) -> AnyObject?
        let factory = unsafeBitCast(method_getImplementation(method), to: Factory.self)
        let attributes = [cylDemoEmotionPathKey: emotionPath] as NSDictionary
        return factory(CYLDemoEmotionMessage.self, selector, nil, nil, attributes) as? CYLDemoEmotionMessage
    }

    // MARK: - Accessors

    @objc func emotionPath() -> String? {
        return attributes?[cylDemoEmotionPathKey] as? String
    }
}
