//
//  CYLDemoContactManager.swift
//  ChatKit-OC
//
//  Translated from Objective-C. `addContactForPeerId:` was not called anywhere and is not translated.
//

import Foundation
import CYLChatKit

@objc(CYLDemoContactManager)
final class CYLDemoContactManager: NSObject {

    private static let sharedManager = CYLDemoContactManager()

    private var cachedContactIDs: [String]?

    /// The singleton instance.
    class func defaultManager() -> CYLDemoContactManager {
        return sharedManager
    }

    private func contactIDs() -> [String] {
        if let ids = cachedContactIDs {
            return ids
        }
        let path = storeFilePath()
        var ids: [String]
        if let stored = NSArray(contentsOfFile: path) as? [String] {
            ids = stored
        } else {
            ids = []
            for contacts in __CYLDemoContactsOfSections {
                ids.append(contentsOf: contacts)
            }
            _ = (ids as NSArray).write(toFile: path, atomically: true)
        }
        cachedContactIDs = ids
        return ids
    }

    func fetchContactPeerIds() -> [String] {
        return contactIDs()
    }

    func existContact(forPeerId peerId: String?) -> Bool {
        guard let peerId = peerId else {
            return false
        }
        return contactIDs().contains(peerId)
    }

    @discardableResult
    func removeContact(forPeerId peerId: String?) -> Bool {
        guard let peerId = peerId else {
            return false
        }
        guard existContact(forPeerId: peerId) else {
            return false
        }
        var ids = contactIDs()
        ids.removeAll { $0 == peerId }
        cachedContactIDs = ids
        return saveContactIDs()
    }

    private func saveContactIDs() -> Bool {
        if let ids = cachedContactIDs {
            return (ids as NSArray).write(toFile: storeFilePath(), atomically: true)
        }
        return true
    }

    private func storeFilePath() -> String {
        let clientId = CYLChatKit.sharedInstance().clientId ?? "(null)"
        let fileName = "CYLDemoContacts\(clientId).plist"
        let library = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        return (library as NSString).appendingPathComponent(fileName)
    }
}
