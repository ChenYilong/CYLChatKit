//
//  LCCKUser.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/3/9.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<CYLChatKit/LCChatKit.h>)
    #import <CYLChatKit/LCChatKit.h>
#else
    #import "LCChatKit.h"
#endif

@interface LCCKUser : NSObject <LCCKUserDelegate>

/**
 *  检查与 aPerson 是否表示同一对象
 */
- (BOOL)isEqualToUer:(LCCKUser *)user;

- (void)saveToDiskWithKey:(NSString *)key;

+ (id)loadFromDiskWithKey:(NSString *)key;

@end
