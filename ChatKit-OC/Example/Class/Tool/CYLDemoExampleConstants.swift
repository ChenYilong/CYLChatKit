//
//  CYLDemoExampleConstants.swift
//  ChatKit-OC
//
//  Translated from Objective-C (CYLDemoExampleConstants.h). Only the constants the demo uses are kept.
//

import Foundation

// MARK: - Demo contact data

let CYLDemoProfileKeyPeerId = "peerId"
let CYLDemoProfileKeyName = "username"
let CYLDemoProfileKeyAvatarURL = "avatarURL"
let CYLDemoDeveloperPeerId = "571dae7375c4cd3379024b2f"

// TODO: add more friends
let CYLDemoContactProfiles: [[String: String]] = [
    [CYLDemoProfileKeyPeerId: CYLDemoDeveloperPeerId, CYLDemoProfileKeyName: "ChatKit-iOS小秘书", CYLDemoProfileKeyAvatarURL: "http://image17-c.poco.cn/mypoco/myphoto/20151211/16/17338872420151211164742047.png"],
    [CYLDemoProfileKeyPeerId: "Tom", CYLDemoProfileKeyName: "Tom", CYLDemoProfileKeyAvatarURL: "http://www.avatarsdb.com/avatars/tom_and_jerry2.jpg"],
    [CYLDemoProfileKeyPeerId: "Jerry", CYLDemoProfileKeyName: "Jerry", CYLDemoProfileKeyAvatarURL: "http://www.avatarsdb.com/avatars/jerry.jpg"],
    [CYLDemoProfileKeyPeerId: "Harry", CYLDemoProfileKeyName: "Harry", CYLDemoProfileKeyAvatarURL: "http://www.avatarsdb.com/avatars/young_harry.jpg"],
    [CYLDemoProfileKeyPeerId: "William", CYLDemoProfileKeyName: "William", CYLDemoProfileKeyAvatarURL: "http://www.avatarsdb.com/avatars/william_shakespeare.jpg"],
    [CYLDemoProfileKeyPeerId: "Bob", CYLDemoProfileKeyName: "Bob", CYLDemoProfileKeyAvatarURL: "http://www.avatarsdb.com/avatars/bath_bob.jpg"],
    [CYLDemoProfileKeyPeerId: "RP", CYLDemoProfileKeyName: "RP", CYLDemoProfileKeyAvatarURL: "http://www.avatarsdb.com/avatars/bath_bob.jpg"],
    [CYLDemoProfileKeyPeerId: "RP1", CYLDemoProfileKeyName: "RP1", CYLDemoProfileKeyAvatarURL: "http://www.avatarsdb.com/avatars/bath_bob.jpg"],
    [CYLDemoProfileKeyPeerId: "5771e7656be3ff0063a0dada", CYLDemoProfileKeyName: "hhx2", CYLDemoProfileKeyAvatarURL: "http://ac-x3o016bx.clouddn.com/jXyGZv2B2W4oc3OaEQtYDo3w7fJjgovHeXGuyfFD"],
]

/// Peer ids of the test persons, in the order of the original `CYLDemoTestPersonProfiles`.
let CYLDemoTestPeerIds: [String] = [
    "Tom",
    "Jerry",
    "Harry",
    "William",
    "Bob",
    "RP1",
    "RP",
    "5771e7656be3ff0063a0dada",
]

let __CYLDemoContactsOfDevelopers: [String] = [
    CYLDemoDeveloperPeerId,
]

let __CYLDemoContactsOfSections: [[String]] = [
    CYLDemoTestPeerIds,
    __CYLDemoContactsOfDevelopers,
]

// MARK: - Dict or UserDefaults key

let CYLDEMO_KEY_USERID = "CYLDEMO_KEY_USERID"

// MARK: - Other

let CYLDEMO_DEFAULT_AVATAR_PATH = "lcck_conversation_placeholder_avatar"
