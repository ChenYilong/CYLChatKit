//
//  CYLDemoExampleLocalization.swift
//  ChatKit-OC
//
//  Translated from Objective-C (the CYLDemoExampleLocalizedString macro in CYLDemoExampleConstants.h).
//

import Foundation

/// The example bundle that holds the demo strings. It is `nil` when the bundle is not part of the app.
private let cylDemoExampleBundle: Bundle? = {
    guard let path = Bundle.main.path(forResource: "CYLDemoExample", ofType: "bundle") else {
        return nil
    }
    return Bundle(path: path)
}()

/// Reads a demo string from `CYLDemoExample.bundle` (table `CYLDemoExample`) and returns `defaultValue` when the key is
/// missing. Demo strings never come from the core bundles (AGENTS.md, "Internationalization and localization").
func CYLDemoExampleLocalizedString(_ key: String, _ defaultValue: String) -> String {
    guard let bundle = cylDemoExampleBundle else {
        return defaultValue
    }
    return bundle.localizedString(forKey: key, value: defaultValue, table: "CYLDemoExample")
}
