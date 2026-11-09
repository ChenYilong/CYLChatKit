//
//  CYLCommonUtils+LCCKExtension.h
//  ChatKit-OC
//
//  Created by ChenYilong on 2026/11/09.
//  Copyright © 2026 ChenYilong. All rights reserved.
//
//  LeanCloud file helpers. Moved from ChatKit to the demo because they take an `AVFile`;
//  the selectors are unchanged.

#import <AVOSCloud/AVOSCloud.h>
#import "CYLCommonUtils.h"

@interface CYLCommonUtils (LCCKExtension)

+ (NSString *)getPathFromFile:(AVFile *)file;

+ (BOOL)isCacheDataAvailableForFile:(AVFile *)file;

@end
