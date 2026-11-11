//
//  CYLDemoUser.swift
//  ChatKit-OC
//
//  Translated from Objective-C. `isEqualToUer:`, `saveToDiskWithKey:` and `loadFromDiskWithKey:` were not called
//  anywhere and are not translated.
//

import Foundation
import CYLChatKit

@objc(CYLDemoUser)
final class CYLDemoUser: NSObject, CYLUserDelegate {

    private(set) var userId: String!
    private(set) var name: String!
    private(set) var avatarURL: URL!
    var clientId: String!

    init(userId: String!, name: String!, avatarURL: URL!, clientId: String!) {
        self.userId = userId
        self.name = name
        self.avatarURL = avatarURL
        self.clientId = clientId
        super.init()
    }

    @objc(userWithUserId:name:avatarURL:clientId:)
    static func user(withUserId userId: String!, name: String!, avatarURL: URL!, clientId: String!) -> CYLDemoUser {
        return CYLDemoUser(userId: userId, name: name, avatarURL: avatarURL, clientId: clientId)
    }

    convenience init(userId: String!, name: String!, avatarURL: URL!) {
        self.init(userId: userId, name: name, avatarURL: avatarURL, clientId: userId)
    }

    @objc(userWithUserId:name:avatarURL:)
    static func user(withUserId userId: String!, name: String!, avatarURL: URL!) -> CYLDemoUser {
        return user(withUserId: userId, name: name, avatarURL: avatarURL, clientId: userId)
    }

    convenience init(clientId: String!) {
        self.init(userId: nil, name: nil, avatarURL: nil, clientId: clientId)
    }

    @objc(userWithClientId:)
    static func user(withClientId clientId: String!) -> CYLDemoUser {
        return user(withUserId: nil, name: nil, avatarURL: nil, clientId: clientId)
    }

    /// Alias of `init(userId:name:avatarURL:)` kept for demo code written against the misspelled name.
    convenience init(userId: String!, name: String!, avatorURL: URL!) {
        self.init(userId: userId, name: name, avatarURL: avatorURL)
    }

    // MARK: - NSCopying

    func copy(with zone: NSZone? = nil) -> Any {
        return CYLDemoUser(userId: userId, name: name, avatarURL: avatarURL, clientId: clientId)
    }

    // MARK: - NSCoding

    func encode(with aCoder: NSCoder) {
        aCoder.encode(userId, forKey: "userId")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(avatarURL, forKey: "avatarURL")
        aCoder.encode(clientId, forKey: "clientId")
    }

    required init?(coder aDecoder: NSCoder) {
        userId = aDecoder.decodeObject(forKey: "userId") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        avatarURL = aDecoder.decodeObject(forKey: "avatarURL") as? URL
        clientId = aDecoder.decodeObject(forKey: "clientId") as? String
        super.init()
    }
}
