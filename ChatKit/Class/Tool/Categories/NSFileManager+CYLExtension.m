//
//  NSFileManager+CYLExtension.m
//  Pods
//
//  Created by 陈宜龙 on 18/6/24.
//
//

#import "NSFileManager+CYLExtension.h"
#include <sys/xattr.h>

@implementation NSFileManager (CYLExtension)

+ (NSURL *)cyl_URLForDirectory:(NSSearchPathDirectory)directory {
    return [self.defaultManager URLsForDirectory:directory inDomains:NSUserDomainMask].lastObject;
}

+ (NSString *)cyl_pathForDirectory:(NSSearchPathDirectory)directory {
    return NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES)[0];
}

+ (NSURL *)cyl_documentsURL {
    return [self cyl_URLForDirectory:NSDocumentDirectory];
}

+ (NSString *)cyl_documentsPath {
    return [self cyl_pathForDirectory:NSDocumentDirectory];
}

+ (NSURL *)cyl_libraryURL {
    return [self cyl_URLForDirectory:NSLibraryDirectory];
}

+ (NSString *)cyl_libraryPath {
    return [self cyl_pathForDirectory:NSLibraryDirectory];
}

+ (NSURL *)cyl_cachesURL {
    return [self cyl_URLForDirectory:NSCachesDirectory];
}

+ (NSString *)cyl_cachesPath {
    return [self cyl_pathForDirectory:NSCachesDirectory];
}

+ (BOOL)cyl_addSkipBackupAttributeToFile:(NSString *)path {
    return [[NSURL.alloc initFileURLWithPath:path] setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:nil];
}

+ (double)cyl_availableDiskSpace {
    NSDictionary *attributes = [self.defaultManager attributesOfFileSystemForPath:self.cyl_documentsPath error:nil];
    return [attributes[NSFileSystemFreeSize] unsignedLongLongValue] / (double)0x100000;
}

@end
