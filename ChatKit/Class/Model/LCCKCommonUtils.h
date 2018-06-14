//
//  LCCKCommonUtils.h
//  AVOSCloud
//
//  Created by chenyilong on 14/6/2018.
//

#import <Foundation/Foundation.h>
@class AVFile;

@interface LCCKCommonUtils : NSObject

+ (NSString *)getPathFromFile:(AVFile *)file;

+ (BOOL)isCacheDataAvailableForFile:(AVFile *)file;

@end
