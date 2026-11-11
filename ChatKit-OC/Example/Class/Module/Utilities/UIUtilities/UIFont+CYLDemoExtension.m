//
//  CYLChatKit.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/22.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//  Core class of LeanCloudChatKit


#import "UIFont+CYLDemoExtension.h"

@implementation UIFont (CYLDemoExtension)

+ (UIFont *)cyl_demo_fontNavBarTitle {
    return [UIFont boldSystemFontOfSize:17.5f];
}

+ (UIFont *)cyl_demo_fontConversationUsername {
    return [UIFont systemFontOfSize:17.0f];
}

+ (UIFont *)cyl_demo_fontConversationDetail {
    return [UIFont systemFontOfSize:14.0f];
}

+ (UIFont *)cyl_demo_fontConversationTime {
    return [UIFont systemFontOfSize:12.5f];
}

+ (UIFont *)cyl_demo_fontFriendsUsername {
    return [UIFont systemFontOfSize:17.0f];
}

+ (UIFont *)cyl_demo_fontMineNikename {
    return [UIFont systemFontOfSize:17.0f];
}

+ (UIFont *)cyl_demo_fontMineUsername {
    return [UIFont systemFontOfSize:14.0f];
}

+ (UIFont *)cyl_demo_fontSettingHeaderAndFooterTitle {
    return [UIFont systemFontOfSize:14.0f];
}

+ (UIFont *)cyl_demo_fontTextMessageText {
    CGFloat size = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CHAT_FONT_SIZE"];
    if (size == 0) {
        size = 16.0f;
    }
    return [UIFont systemFontOfSize:size];
}

@end
