//
//  CYLDemoLoginDataSource.swift
//  ChatKit-OC
//
//  Translated from Objective-C.
//

import Foundation
import UIKit
import MLPAutoCompleteTextField

@objc(CYLDemoLoginDataSource)
final class CYLDemoLoginDataSource: NSObject, MLPAutoCompleteTextFieldDataSource {

    /// Set this to true to return an array of autocomplete objects to the text field instead of strings.
    @objc var testWithAutoCompleteObjectsInsteadOfStrings = false

    /// Set this to true to prevent auto complete terms from returning instantly.
    @objc var simulateLatency = false

    // MARK: - MLPAutoCompleteTextFieldDataSource

    @objc(autoCompleteTextField:possibleCompletionsForString:completionHandler:)
    func autoCompleteTextField(_ textField: MLPAutoCompleteTextField!,
                               possibleCompletionsFor string: String!,
                               completionHandler handler: (([Any]?) -> Void)!) {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.simulateLatency {
                let seconds = arc4random_uniform(4) + arc4random_uniform(4)
                NSLog("sleeping fetch of completions for %f", Double(seconds))
                sleep(seconds)
            }
            let completions: [Any] = self.allPeerIds()
            handler?(completions)
        }
    }

    private func allPeerIds() -> [String] {
        return CYLDemoTestPeerIds
    }
}
