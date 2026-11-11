//
//  NSFileManager+CYLExtension.h
//  Pods
//
//  Created by 陈宜龙 on 18/6/24.
//
//

#import <Foundation/Foundation.h>

@interface NSFileManager (CYLExtension)

/*!
 Get URL of Documents directory.
 
 @return Documents directory URL.
 */
+ (NSURL *)cyl_documentsURL;

/*!
 Get path of Documents directory.
 
 @return Documents directory path.
 */
+ (NSString *)cyl_documentsPath;

/*!
 Get URL of Library directory.
 
 @return Library directory URL.
 */
+ (NSURL *)cyl_libraryURL;

/*!
 Get path of Library directory.
 
 @return Library directory path.
 */
+ (NSString *)cyl_libraryPath;

/*!
 Get URL of Caches directory.
 
 @return Caches directory URL.
 */
+ (NSURL *)cyl_cachesURL;

/*!
 Get path of Caches directory.
 
 @return Caches directory path.
 */
+ (NSString *)cyl_cachesPath;

/*!
 Adds a special filesystem flag to a file to avoid iCloud backup it.
 
 @param path Path to a file to set an attribute.
 */
+ (BOOL)cyl_addSkipBackupAttributeToFile:(NSString *)cyl_path;

/*!
 Get available disk space.
 
 @return An amount of available disk space in Megabytes.
 */
+ (double)cyl_availableDiskSpace;

@end
