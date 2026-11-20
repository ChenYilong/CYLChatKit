//
//  CYLCommonUtils+CYLDemoExtension.swift
//  ChatKit-OC
//
//  Translated from Objective-C. LeanCloud file helpers (they take an `AVFile`).
//

import Foundation
import AVOSCloud
import AVOSCloudIM
import CYLChatKit

extension CYLCommonUtils {

    /// Objective-C: `+getPathFromFile:`. Returns the local cache path of the file, or an empty string.
    @objc(getPathFromFile:)
    class func getPath(from file: AVFile?) -> String {
        // `persistentCachePath` is read through key-value coding so it works as a property or as a getter method.
        let cachePath = file?.value(forKey: "persistentCachePath") as? String
        let pathForFile = (cachePath?.count ?? 0) > 0 ? (cachePath ?? "") : ""
        var imagePath = ""
        if FileManager.default.fileExists(atPath: pathForFile) {
            imagePath = pathForFile
        }
        return imagePath
    }

    /// Alias of `getPath(from:)` with the label the Objective-C selector suggests.
    class func getPath(fromFile file: AVFile?) -> String {
        return getPath(from: file)
    }

    /// Objective-C: `+isCacheDataAvailableForFile:`.
    @objc(isCacheDataAvailableForFile:)
    class func isCacheDataAvailable(for file: AVFile?) -> Bool {
        let objectId = file?.objectId()
        let localPath = getPath(from: file)
        let data = NSData(contentsOfFile: localPath)
        if (objectId?.count ?? 0) > 0 && (data?.length ?? 0) > 0 {
            return true
        }
        return false
    }

    /// Alias of `isCacheDataAvailable(for:)` with the label the Objective-C selector suggests.
    class func isCacheDataAvailable(forFile file: AVFile?) -> Bool {
        return isCacheDataAvailable(for: file)
    }
}
