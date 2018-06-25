//
//  LCCKInvestCardChatMessageCell.m
//  ChatKit-OC
//
//  Created by chenyilong on 21/6/2018.
//  Copyright © 2018 ElonChan. All rights reserved.
//

#import "LCCKInvestCardChatMessageCell.h"
#import "AVIMInvestCardTypedMessage.h"
#import "UIImage+LCCKExtension.h"
#if __has_include(<SDWebImage/SDWebImageManager.h>)
#import <SDWebImage/SDWebImageManager.h>
#else
#import "SDWebImageManager.h"
#endif

@interface LCCKInvestCardChatMessageCell()

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

@property (nonatomic, strong) UILabel *investLabel;

@property (nonatomic, strong) UIImageView *messageImageViewBackgroundImageView;
@property (nonatomic, strong) LCCKContentView *investMessageContentView;

@end

@implementation LCCKInvestCardChatMessageCell

#pragma mark - Override Methods

#pragma mark - Public Methods
- (void)updateConstraints {
    [super updateConstraints];
    UIEdgeInsets edgeMessageBubbleCustomize;
    
    if (self.messageOwner == LCCKMessageOwnerTypeSelf) {
        UIEdgeInsets rightEdgeMessageBubbleCustomize = [LCCKSettingService sharedInstance].rightHollowEdgeMessageBubbleCustomize;
        edgeMessageBubbleCustomize = rightEdgeMessageBubbleCustomize;
    } else {
        UIEdgeInsets leftEdgeMessageBubbleCustomize = [LCCKSettingService sharedInstance].leftHollowEdgeMessageBubbleCustomize;
        edgeMessageBubbleCustomize = leftEdgeMessageBubbleCustomize;
    }
    if (self.messageImageViewBackgroundImageView.superview) {
        [self.messageImageViewBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.messageImageView);
        }];
    }
    
    if (self.messageImageView.superview) {
        [self.messageImageView mas_makeConstraints:^(MASConstraintMaker *make) {            make.edges.equalTo(self.investMessageContentView).with.insets(edgeMessageBubbleCustomize);
        }];
    }
    
    if (self.messageOwner == LCCKMessageOwnerTypeSelf) {
        if (self.investLabel.superview) {
            [self.investLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@10);
                make.top.equalTo(self.avatarImageView);
                make.right.equalTo(self.avatarImageView.mas_left).with.offset(-LCCKAvatarToMessageContent);
                make.bottom.equalTo(self.messageImageView.mas_top);
            }];
        }
        if (self.investMessageContentView.superview) {
            [self.investMessageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.avatarImageView.mas_left).with.offset(-LCCKAvatarToMessageContent);
                CGFloat width = [UIApplication sharedApplication].keyWindow.frame.size.width;
                CGFloat height = [UIApplication sharedApplication].keyWindow.frame.size.height;
                CGFloat widthLimit = MIN(width, height)/5 * 3;
                make.width.lessThanOrEqualTo(@(widthLimit)).priorityHigh();
                make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-LCCK_MSG_CELL_EDGES_OFFSET).priorityLow();
            }];
        }
        } else if (self.messageOwner == LCCKMessageOwnerTypeOther){
            if (self.investLabel.superview) {
                [self.investLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@10);
                    make.top.equalTo(self.nickNameLabel.mas_bottom); make.left.equalTo(self.avatarImageView.mas_right).with.offset(LCCKAvatarToMessageContent);
                                        make.bottom.equalTo(self.messageImageView.mas_top);
                }];
            }
            if (self.investMessageContentView.superview) {
                [self.investMessageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.avatarImageView.mas_right).with.offset(LCCKAvatarToMessageContent);
                    CGFloat width = [UIApplication sharedApplication].keyWindow.frame.size.width;
                    CGFloat height = [UIApplication sharedApplication].keyWindow.frame.size.height;
                    CGFloat widthLimit = MIN(width, height)/5 * 3;
                    make.width.lessThanOrEqualTo(@(widthLimit)).priorityHigh();
                    make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-LCCK_MSG_CELL_EDGES_OFFSET).priorityLow();
                }];
            }
    }
}

- (BOOL)showName {
    BOOL isMessageOwner = self.messageOwner == LCCKMessageOwnerTypeOther;
    BOOL isMessageChatTypeGroup = self.messageChatType == LCCKConversationTypeGroup;
    if (isMessageOwner && isMessageChatTypeGroup) {
        self.nickNameLabel.hidden = NO;
        return YES;
    }
    self.nickNameLabel.hidden = YES;
    return NO;
}

- (void)setup {
    [super setup];
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.nickNameLabel];
    
    [self.contentView addSubview:self.investMessageContentView];
    [self.contentView addSubview:self.investLabel];
    
//    [self.contentView addSubview:self.messageSendStateView];
//    [self.contentView addSubview:self.messageReadStateImageView];
    
    [self.investMessageContentView addSubview:self.messageImageView];
    [self.investMessageContentView addSubview:self.messageProgressView];
    
    [self initialize];
    
    if (self.messageOwner == LCCKMessageOwnerTypeSelf) {
        self.investLabel.text = @"你发起了饭局";
    } else {
        self.investLabel.text = @"向你发起了饭局";
    }

    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapMessageImageViewGestureRecognizerHandler:)];
    [self.investMessageContentView addGestureRecognizer:recognizer];
    [self updateConstraintsIfNeeded];
    [self updateConstraintsIfNeeded];
    [self updateConstraints];
    [self layoutIfNeeded];
}

- (LCCKContentView *)investMessageContentView {
    if (!_investMessageContentView) {
        _investMessageContentView = [[LCCKContentView alloc] init];
    }
    return _investMessageContentView;
}

- (void)initialize {
    UIImage *bubbleImage = [UIImage imageNamed:@"message_receiver_background_normal"];
    UIEdgeInsets bubbleImageCapInsets = UIEdgeInsetsMake(24, 30, 16, 16);
    UIImage *stretch = LCCK_STRETCH_IMAGE(bubbleImage, bubbleImageCapInsets);
    [self.messageImageViewBackgroundImageView setImage:stretch];
    self.investMessageContentView.layer.mask.contents = (__bridge id _Nullable)(self.messageImageViewBackgroundImageView.image.CGImage);
    [self.contentView insertSubview:self.messageImageViewBackgroundImageView belowSubview:self.investMessageContentView];
    [self updateConstraintsIfNeeded];
    self.messageSendStateView.hidden = YES;
    self.messageReadStateImageView.hidden = YES;
    
    //    if (self.isAbleToTap) {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.delegate = self;
    tap.numberOfTapsRequired = 1;
    [self.contentView addGestureRecognizer:tap];
    //    }
    
//    UITapGestureRecognizer *avatarImageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageViewHandleTap:)];
//    self.avatarImageView.userInteractionEnabled = YES;
//    [self.avatarImageView addGestureRecognizer:avatarImageViewTap];
    
//    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
//    [recognizer setMinimumPressDuration:0.4f];
//    [self addGestureRecognizer:recognizer];
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        CGPoint tapPoint = [tap locationInView:self.contentView];
        if (CGRectContainsPoint(self.investMessageContentView.frame, tapPoint)) {
            [self.delegate messageCellTappedMessage:self];
            return;
        }
        [self.delegate messageCellTappedBlank:self];
    }
}

- (void)singleTapMessageImageViewGestureRecognizerHandler:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(messageCellTappedMessage:)]) {
            [self.delegate messageCellTappedMessage:self];
        }
    }
}

- (void)configureCellWithData:(AVIMInvestCardTypedMessage *)message {
    [super configureCellWithData:message];
    if (![message isKindOfClass:[AVIMInvestCardTypedMessage class]]) {
        return;
    }
    self.message = message;
    UIImage *thumbnailPhoto = message.thumbnailPhoto;
    if (!thumbnailPhoto) {
        UIImage *image = [self imageInBundleForImageName:@"invest_card_placeholder"];
        UIImage *newImage = [image lcck_imageByScalingAspectFillWithOriginSize:message.photoSize];
        self.messageImageView.image = newImage;
    }
    
    do {
        if (self.messageImageView.image && (self.messageImageView.image == thumbnailPhoto)) {
            break;
        }
//        if (thumbnailPhoto) {
//            self.messageImageView.image = thumbnailPhoto;
//            break;
//        }
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
            CGSize photoSize = CGSizeMake(message.photoSize.width ?: 30, message.photoSize.height ?: 30);
            UIImage *resizedImage = [image lcck_imageByScalingAspectFillWithOriginSize:photoSize];
            self.messageImageView.image = resizedImage;
            message.photo = image;
            message.thumbnailPhoto = resizedImage;
            break;
        }
        // requied!
        NSURL *originPhotoURL = message.originPhotoURL;
        if (originPhotoURL.absoluteString.length > 0) {
            UIImage *image;
            CGSize photoSize = message.photoSize;
            image = [self imageInBundleForImageName:@"invest_card_placeholder"];
            if (photoSize.width > 0 && photoSize.height > 0) {
                image = [self imageInBundleForImageName:@"invest_card_placeholder"];
            }
            UIImage *newImage = [image lcck_imageByScalingAspectFillWithOriginSize:photoSize];
            self.messageImageView.image = newImage;
            [message.file downloadWithCompletionHandler:^(NSURL * _Nullable filePath, NSError * _Nullable error) {
                if (filePath.absoluteString.length > 0) {
                    NSData *data = [NSData dataWithContentsOfURL:filePath];
                    UIImage *image = [UIImage imageWithData:data];
                    if (image){
                        message.photo = image;
                        message.thumbnailPhoto = [image lcck_imageByScalingAspectFillWithOriginSize:photoSize];
                        [[NSNotificationCenter defaultCenter] postNotificationName:LCCKNotificationConversionImageMessageDidDownloaded object:self];
                    }
                }
            }];

            break;
        }
    } while (NO);
    
    [self updateConstraintsIfNeeded];
    [self updateConstraints];
    [self layoutIfNeeded];
}

- (UIImage *)imageInBundleForImageName:(NSString *)imageName {
    return ({
        UIImage *image = [UIImage lcck_imageNamed:imageName bundleName:@"Placeholder" bundleForClass:[LCChatKit class]];
        image;});
}

- (UIImageView *)messageImageViewBackgroundImageView {
    if (_messageImageViewBackgroundImageView) {
        return _messageImageViewBackgroundImageView;
    }
    UIImageView *messageImageViewBackgroundImageView = [UIImageView new];
    _messageImageViewBackgroundImageView = messageImageViewBackgroundImageView;
    return _messageImageViewBackgroundImageView;
}

#pragma mark - Setters

- (void)setUploadProgress:(CGFloat)uploadProgress {
    [self setMessageSendState:LCCKMessageSendStateSending];
    [self.messageProgressView setFrame:CGRectMake(self.messageImageView.frame.origin.x, self.messageImageView.frame.origin.y, self.messageImageView.bounds.size.width, self.messageImageView.bounds.size.height * (1 - uploadProgress))];
    [self.messageProgressLabel setText:[NSString stringWithFormat:@"%.0f%%",uploadProgress * 100]];
}

- (void)setMessageSendState:(LCCKMessageSendState)messageSendState {
    [super setMessageSendState:messageSendState];
    if (messageSendState == LCCKMessageSendStateSending) {
        if (!self.messageProgressView.superview) {
            [self.investMessageContentView addSubview:self.messageProgressView];
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
        _messageImageView.contentMode = UIViewContentModeScaleAspectFit;

    }
    return _messageImageView;
}

- (UILabel *)investLabel {
    if (_investLabel) {
        return _investLabel;
    }
    UILabel *investLabel = [UILabel new];
    investLabel.textColor = [UIColor redColor];
    _investLabel = investLabel;
    _investLabel.text = @"向你发起了饭局";
    return _investLabel;
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
#pragma mark - LCCKChatMessageCellSubclassing Method

+ (void)load {
    [self registerSubclass];
}

+ (AVIMMessageMediaType)classMediaType {
    return kAVIMInvestCardTypedMessage;
}

@end
