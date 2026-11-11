//
//  CYLMessageVoiceFactory.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/21.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "CYLMessageVoiceFactory.h"
#import "UIImage+CYLExtension.h"

@implementation CYLMessageVoiceFactory

+ (UIImageView *)messageVoiceAnimationImageViewWithBubbleMessageType:(CYLMessageOwnerType)owner {
    UIImageView *messageVoiceAniamtionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    NSString *imageSepatorName;
    switch (owner) {
        case CYLMessageOwnerTypeSelf:
            imageSepatorName = @"Sender";
            break;
        case CYLMessageOwnerTypeOther:
            imageSepatorName = @"Receiver";
            break;
        default:
            break;
    }
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:4];
    for (NSInteger i = 0; i < 4; i ++) {
        NSString *imageName = [imageSepatorName stringByAppendingFormat:@"VoiceNodePlaying00%ld", (long)i];
        UIImage *image = [self imageInBundleForImageName:imageName];
        if (image)
            [images addObject:image];
    }
    
    messageVoiceAniamtionImageView.image = ({
        NSString *imageName = [imageSepatorName stringByAppendingString:@"VoiceNodePlaying"];
        UIImage *image = [self imageInBundleForImageName:imageName];
        image;});
    messageVoiceAniamtionImageView.animationImages = images;
    messageVoiceAniamtionImageView.animationDuration = 1.0;
    [messageVoiceAniamtionImageView stopAnimating];
    return messageVoiceAniamtionImageView;
}

+ (UIImage *)imageInBundleForImageName:(NSString *)imageName {
    UIImage *image = [UIImage cyl_imageNamed:imageName bundleName:@"MessageBubble" bundleForClass:[self class]];
    return  image;
}

@end
