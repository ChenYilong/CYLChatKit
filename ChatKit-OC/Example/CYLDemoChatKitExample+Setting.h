//
//  CYLDemoChatKitExample.m
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/24.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//

#import "CYLDemoChatKitExample.h"
#import <Foundation/Foundation.h>

@interface CYLDemoChatKitExample (Setting) //<MWPhotoBrowserDelegate>

/**
 *  初始化需要的设置
 */
- (void)cyl_demo_setting;
+ (void)cyl_demo_pushToViewController:(UIViewController *)viewController;
+ (void)cyl_demo_tryPresentViewControllerViewController:(UIViewController *)viewController;
+ (void)cyl_demo_clearLocalClientInfo;
+ (void)cyl_demo_exampleChangeGroupAvatarURLsForConversationId:(NSString *)conversationId
                                         shouldInsert:(BOOL)shouldInsert;
@end
