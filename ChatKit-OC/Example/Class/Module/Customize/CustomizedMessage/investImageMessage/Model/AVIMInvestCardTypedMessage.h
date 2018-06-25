//
//  AVIMInvestCardTypedMessage.h
//  ChatKit-OC
//
//  Created by chenyilong on 21/6/2018.
//  Copyright © 2018 ElonChan. All rights reserved.
//

#import "AVIMTypedMessage.h"
#import <AVOSCloudIM/AVOSCloudIM.h>
#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

static AVIMMessageMediaType const kAVIMInvestCardTypedMessage = 5;

@interface AVIMInvestCardTypedMessage : AVIMTypedMessage<AVIMTypedMessageSubclassing , LCCKMessageDelegate>

@property (nonatomic, readonly, assign) CGSize photoSize; // photoWidth/photoHeight
//@property (nonatomic, strong) UIImage *thumbnailPhoto;
//@property (nonatomic, strong) UIImage *photo;
//@property (nonatomic, readonly, copy) NSString *photoPath;
//@property (nonatomic, readonly, strong) NSURL *originPhotoURL;

- (instancetype)initWithImageURL:(NSURL *)imageURL conversationType:(LCCKConversationType)conversationType;

+ (instancetype)investCardMessageWithImageURL:(NSURL *)imageURL  conversationType:(LCCKConversationType)conversationType;

@end
