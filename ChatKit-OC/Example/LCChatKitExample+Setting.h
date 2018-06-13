//
//  LCChatKitExample.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 18/6/24.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "LCChatKitExample.h"
#import <Foundation/Foundation.h>

@interface LCChatKitExample (Setting) //<MWPhotoBrowserDelegate>

/**
 *  初始化需要的设置
 */
- (void)lcck_setting;
+ (void)lcck_pushToViewController:(UIViewController *)viewController;
+ (void)lcck_tryPresentViewControllerViewController:(UIViewController *)viewController;
+ (void)lcck_clearLocalClientInfo;
+ (void)lcck_exampleChangeGroupAvatarURLsForConversationId:(NSString *)conversationId
                                         shouldInsert:(BOOL)shouldInsert;
@end
