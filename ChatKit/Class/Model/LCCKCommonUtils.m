//
//  LCCKCommonUtils.m
//  AVOSCloud
//
//  Created by chenyilong on 14/6/2018.
//

#import "LCCKCommonUtils.h"
#import <AVOSCloud/AVOSCloud.h>

@implementation LCCKCommonUtils

+ (NSString *)getPathFromFile:(AVFile *)file {
    NSString *localPath = [file persistentCachePath];
    return localPath;
}

+ (BOOL)isCacheDataAvailableForFile:(AVFile *)file {
    NSString *objectId = file.objectId;
    NSString *localPath = [self getPathFromFile:file];
    localPath = (localPath.length > 0) ? localPath :@"";
    BOOL fileExistsAtPath = ([[NSFileManager defaultManager] fileExistsAtPath:localPath]);
    if (objectId.length > 0 && fileExistsAtPath) {
        return YES;
    }
    return NO;
}

@end
