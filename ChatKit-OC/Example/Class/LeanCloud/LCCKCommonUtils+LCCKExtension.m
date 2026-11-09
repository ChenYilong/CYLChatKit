//
//  LCCKCommonUtils+LCCKExtension.m
//  ChatKit-OC
//
//  Created by ChenYilong on 2026/11/09.
//  Copyright © 2026 ChenYilong. All rights reserved.
//

#import "LCCKCommonUtils+LCCKExtension.h"

@implementation LCCKCommonUtils (LCCKExtension)

+ (NSString *)getPathFromFile:(AVFile *)file {
    NSString *pathForFile = [file persistentCachePath];
    pathForFile = (pathForFile.length > 0) ? pathForFile :@"";
    NSString *imagePath = @"";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:pathForFile]){
        imagePath = pathForFile;
    }
    return imagePath;
}

+ (BOOL)isCacheDataAvailableForFile:(AVFile *)file {
    NSString *objectId = file.objectId;
    NSString *localPath = [self getPathFromFile:file];
    NSData *data = [NSData dataWithContentsOfFile:localPath];
    if (objectId.length > 0 && data.length > 0) {
        return YES;
    }
    return NO;
}

@end
