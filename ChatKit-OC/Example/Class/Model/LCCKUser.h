//
//  LCCKUser.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/3/9.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<ChatKit/LCChatKit.h>)
    #import <ChatKit/LCChatKit.h>
#else
    #import "LCChatKit.h"
#endif

#if __has_include(<CYLChatKit/CYLUserDelegate.h>)
#import <CYLChatKit/CYLUserDelegate.h>
#else
#import "CYLUserDelegate.h"
#endif

@interface LCCKUser : NSObject <CYLUserDelegate>

/**
 *  检查与 aPerson 是否表示同一对象
 */
- (BOOL)isEqualToUer:(LCCKUser *)user;

/// Alias of `-initWithUserId:name:avatarURL:` kept for demo code written against the misspelled name.
- (instancetype)initWithUserId:(NSString *)userId name:(NSString *)name avatorURL:(NSURL *)avatorURL;

- (void)saveToDiskWithKey:(NSString *)key;

+ (id)loadFromDiskWithKey:(NSString *)key;

@end
