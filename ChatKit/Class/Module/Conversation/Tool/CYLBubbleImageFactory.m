//
//  CYLBubbleImageFactory.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/21.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "CYLBubbleImageFactory.h"
#import "CYLChatConstants.h"
#import "UIImage+CYLExtension.h"
#import "CYLSettingService.h"

@implementation CYLBubbleImageFactory

+ (UIImage *)bubbleImageViewForType:(CYLMessageOwnerType)owner
                        messageType:(CYLMessageMediaType)messageMediaType
                      isHighlighted:(BOOL)isHighlighted {
    BOOL isCustomMessage = NO;
    NSString *messageTypeString = @"message_";
    switch (messageMediaType) {
        case CYLMessageMediaTypeImage:
        case CYLMessageMediaTypeLocation:
            messageTypeString = [messageTypeString stringByAppendingString:@"hollow_"];
            break;
        default:
            break;
    }
    UIEdgeInsets bubbleImageCapInsets = UIEdgeInsetsZero;
    switch (owner) {
        case CYLMessageOwnerTypeSelf: {
            // 发送
            switch (messageMediaType) {
                case CYLMessageMediaTypeImage:
                case CYLMessageMediaTypeLocation:
                    bubbleImageCapInsets = [CYLSettingService sharedInstance].rightHollowCapMessageBubbleCustomize;
                    break;
                default:
                    bubbleImageCapInsets = [CYLSettingService sharedInstance].rightCapMessageBubbleCustomize;
                    break;
            }
            messageTypeString = [messageTypeString stringByAppendingString:@"sender_"];
            break;
        }
        case CYLMessageOwnerTypeOther: {
            // 接收
            switch (messageMediaType) {
                case CYLMessageMediaTypeImage:
                case CYLMessageMediaTypeLocation:
                    bubbleImageCapInsets = [CYLSettingService sharedInstance].leftHollowCapMessageBubbleCustomize;
                    break;
                default:
                    bubbleImageCapInsets = [CYLSettingService sharedInstance].leftCapMessageBubbleCustomize;
                    break;
            }
            messageTypeString = [messageTypeString stringByAppendingString:@"receiver_"];
            break;
        }
        case CYLMessageOwnerTypeSystem:
            break;
        case CYLMessageOwnerTypeUnknown:
            isCustomMessage = YES;
            break;
    }
    if (isCustomMessage) {
        return nil;
    }
    messageTypeString = [messageTypeString stringByAppendingString:@"background_"];
    if (isHighlighted) {
        messageTypeString = [messageTypeString stringByAppendingString:@"highlight"];
    } else {
        messageTypeString = [messageTypeString stringByAppendingString:@"normal"];
    }
    UIImage *bubbleImage = [UIImage cyl_imageNamed:messageTypeString bundleName:@"MessageBubble" bundleForClass:[self class]];
    return CYL_STRETCH_IMAGE(bubbleImage, bubbleImageCapInsets);
}

@end
