//
//  CYLChatImageMessageCell.m
//  CYLChatExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/11/16.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//

#import "CYLChatImageMessageCell.h"
#import "UIImage+CYLExtension.h"
#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

#if __has_include(<SDWebImage/UIImageView+WebCache.h>)
#import <SDWebImage/UIImageView+WebCache.h>
#else
#import "UIImageView+WebCache.h"
#endif

@interface CYLChatImageMessageCell ()

/**
 *  用来显示image的UIImageView
 */
@property (nonatomic, strong) UIImageView *messageImageView;

/**
 *  用来显示上传进度的UIView
 */
@property (nonatomic, strong) UIView *messageProgressView;

/**
 *  显示上传进度百分比的UILabel
 */
@property (nonatomic, weak) UILabel *messageProgressLabel;

@end

@implementation CYLChatImageMessageCell

#pragma mark - Override Methods

#pragma mark - Public Methods

- (void)setup {
    [self.messageContentView addSubview:self.messageImageView];
    [self.messageContentView addSubview:self.messageProgressView];
    UIEdgeInsets edgeMessageBubbleCustomize;
    if (self.messageOwner == CYLMessageOwnerTypeSelf) {
        UIEdgeInsets rightEdgeMessageBubbleCustomize = [CYLSettingService sharedInstance].rightHollowEdgeMessageBubbleCustomize;
        edgeMessageBubbleCustomize = rightEdgeMessageBubbleCustomize;
    } else {
        UIEdgeInsets leftEdgeMessageBubbleCustomize = [CYLSettingService sharedInstance].leftHollowEdgeMessageBubbleCustomize;
        edgeMessageBubbleCustomize = leftEdgeMessageBubbleCustomize;
    }
    [self.messageImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.messageContentView).with.insets(edgeMessageBubbleCustomize);
        make.height.lessThanOrEqualTo(@200).priorityHigh();
    }];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapMessageImageViewGestureRecognizerHandler:)];
    [self.messageContentView addGestureRecognizer:recognizer];
    [super setup];
    [self addGeneralView];
}

- (void)singleTapMessageImageViewGestureRecognizerHandler:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(messageCellTappedMessage:)]) {
            [self.delegate messageCellTappedMessage:self];
        }
    }
}

/*!
 * Downloads the image through the IM provider, or from `originPhotoURL` if the provider does not download attachments.
 */
- (void)downloadAttachmentOfMessage:(CYLMessage *)message completion:(void (^)(NSURL *filePath, NSError *error))completion {
    id<CYLIMProvider> IMProvider = [LCChatKit sharedInstance].IMProvider;
    if ([IMProvider respondsToSelector:@selector(downloadAttachmentOfMessage:completion:)]) {
        [IMProvider downloadAttachmentOfMessage:message completion:completion];
        return;
    }
    NSURL *URL = message.originPhotoURL;
    if (!URL) {
        !completion ?: completion(nil, nil);
        return;
    }
    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:URL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSURL *filePath = nil;
        if (location && !error) {
            NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
            NSURL *destination = [NSURL fileURLWithPath:path];
            if ([[NSFileManager defaultManager] moveItemAtURL:location toURL:destination error:nil]) {
                filePath = destination;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            !completion ?: completion(filePath, error);
        });
    }];
    [task resume];
}

- (void)configureCellWithData:(CYLMessage *)message {
    [super configureCellWithData:message];
    UIImage *thumbnailPhoto = message.thumbnailPhoto;
    do {
        if (self.messageImageView.image && (self.messageImageView.image == thumbnailPhoto)) {
            break;
        }
        if (thumbnailPhoto) {
            self.messageImageView.image = thumbnailPhoto;
            break;
        }
        NSString *imageLocalPath = message.photoPath;
        
        NSString *imageLocalOrURLPath = message.originPhotoURL.absoluteString;
        if (imageLocalPath.length > 0 && [NSData dataWithContentsOfFile:imageLocalPath]) {
            imageLocalOrURLPath = imageLocalPath;
        }
        BOOL isLocalPath = ![imageLocalOrURLPath hasPrefix:@"http"];
        //note: this will ignore contentMode.
        if (imageLocalPath.length > 0 && isLocalPath) {
            NSData *imageData = [NSData dataWithContentsOfFile:imageLocalPath];
            UIImage *image = [UIImage imageWithData:imageData];
            // Use the original dimensions to keep image-message bubble heights stable: https://github.com/leancloud/ChatKit-OC/issues/279
            // Dimensionless custom message models use a bounded fallback size: https://github.com/ChenYilong/CYLChatKit/issues/6
            CGSize photoSize = CGSizeMake(message.photoWidth ?: 30, message.photoHeight ?: 30);
            UIImage *resizedImage = [image cyl_imageByScalingAspectFillWithOriginSize:photoSize];
            self.messageImageView.image = resizedImage;
            message.photo = image;
            message.thumbnailPhoto = resizedImage;
            break;
        }
        // requied!
        if (message.originPhotoURL) {
            UIImage *image;
            image = [self imageInBundleForImageName:@"Placeholder_Accept_Defeat"];
            if (message.photoWidth > 0 && message.photoHeight > 0) {
               image = [self imageInBundleForImageName:@"Placeholder_Image"];
            }
            // Keep the placeholder aligned with the eventual image dimensions: https://github.com/leancloud/ChatKit-OC/issues/279
            CGSize photoSize = CGSizeMake(message.photoWidth ?: 30, message.photoHeight ?: 30);
            UIImage *newImage = [image cyl_imageByScalingAspectFillWithOriginSize:photoSize];
            self.messageImageView.contentMode = UIViewContentModeScaleAspectFit;
            self.messageImageView.image = newImage;
            [self downloadAttachmentOfMessage:message completion:^(NSURL * _Nullable filePath, NSError * _Nullable error) {
                if (filePath.absoluteString.length > 0) {
                    NSData *data = [NSData dataWithContentsOfURL:filePath];
                    UIImage *image = [UIImage imageWithData:data];
                    if (image){
                        message.photo = image;
                        message.thumbnailPhoto = [image cyl_imageByScalingAspectFillWithOriginSize:photoSize];
                        [[NSNotificationCenter defaultCenter] postNotificationName:CYLNotificationConversionImageMessageDidDownloaded object:self];
                        
                    }
                }
            }];
            break;
        }
    } while (NO);
}

- (UIImage *)imageInBundleForImageName:(NSString *)imageName {
    return ({
        UIImage *image = [UIImage cyl_imageNamed:imageName bundleName:@"Placeholder" bundleForClass:[self class]];
        image;});
}

#pragma mark - Setters

- (void)setUploadProgress:(CGFloat)uploadProgress {
    [self setMessageSendState:CYLMessageSendStateSending];
    [self.messageProgressView setFrame:CGRectMake(self.messageImageView.frame.origin.x, self.messageImageView.frame.origin.y, self.messageImageView.bounds.size.width, self.messageImageView.bounds.size.height * (1 - uploadProgress))];
    [self.messageProgressLabel setText:[NSString stringWithFormat:@"%.0f%%",uploadProgress * 100]];
}

- (void)setMessageSendState:(CYLMessageSendState)messageSendState {
    [super setMessageSendState:messageSendState];
    if (messageSendState == CYLMessageSendStateSending) {
        if (!self.messageProgressView.superview) {
            [self.messageContentView addSubview:self.messageProgressView];
        }
        [self.messageProgressLabel setFrame:CGRectMake(self.messageImageView.frame.origin.y, self.messageImageView.image.size.height/2 - 8, self.messageImageView.image.size.width, 16)];
    } else {
        [self removeProgressView];
    }
}

- (void)removeProgressView {
    [self.messageProgressView removeFromSuperview];
    [[self.messageProgressView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.messageProgressView = nil;
    self.messageProgressLabel = nil;
}

#pragma mark - Getters

- (UIImageView *)messageImageView {
    if (!_messageImageView) {
        _messageImageView = [[UIImageView alloc] init];
        //FIXME:这一行可以不需要
        _messageImageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _messageImageView;
    
}

- (UIView *)messageProgressView {
    if (!_messageProgressView) {
        _messageProgressView = [[UIView alloc] init];
        _messageProgressView.backgroundColor = [UIColor colorWithRed:.0f green:.0f blue:.0f alpha:.3f];
        _messageProgressView.translatesAutoresizingMaskIntoConstraints = NO;
        _messageProgressView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        UILabel *progressLabel = [[UILabel alloc] init];
        progressLabel.font = [UIFont systemFontOfSize:14.0f];
        progressLabel.textColor = [UIColor whiteColor];
        progressLabel.textAlignment = NSTextAlignmentCenter;
        [_messageProgressView addSubview:self.messageProgressLabel = progressLabel];
    }
    return _messageProgressView;
}

#pragma mark -
#pragma mark - CYLChatMessageCellSubclassing Method

+ (void)load {
    [self registerSubclass];
}

+ (CYLMessageMediaType)classMediaType {
    return CYLMessageMediaTypeImage;
}

@end
