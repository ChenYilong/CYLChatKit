//
//  LCChatKit.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 18/6/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//  Core class of LeanCloudChatKit


#import <UIKit/UIKit.h>

//@class LCCKGroup;
@interface LCCKUIUtility : NSObject

+ (CGFloat)getTextHeightOfText:(NSString *)text
                          font:(UIFont *)font
                         width:(CGFloat)width;

//+ (void)createGroupAvatar:(LCCKGroup *)group
//                 finished:(void (^)(NSString *groupID))finished;

+ (void)captureScreenshotFromView:(UIView *)view
                             rect:(CGRect)rect
                         finished:(void (^)(NSString *avatarPath))finished;

@end
