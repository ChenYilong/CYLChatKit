//
//  AVIMConversation+CYLDemoAddition.m
//  LeanCloudChatKit-iOS
//
//  Created by 陈宜龙 on 16/3/11.
//  Copyright © 2016年 ElonChan. All rights reserved.
//

#import "CYLDemoEmotionMessage.h"
#import <AVOSCloudIM/AVOSCloudIM.h>

static NSString *kCYLDemoEmotionPath = @"emotionPath";

@implementation CYLDemoEmotionMessage

+ (void)load {
    [self registerSubclass];
}

+ (AVIMMessageMediaType)classMediaType {
    return kAVIMMessageMediaTypeEmotion;
}

+ (instancetype)messageWithEmotionPath:(NSString *)emotionPath {
    return [super messageWithText:nil file:nil attributes:@{kCYLDemoEmotionPath: emotionPath}];
}

- (NSString *)emotionPath {
    return [self.attributes objectForKey:kCYLDemoEmotionPath];
}

@end
