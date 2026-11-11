//
//  CYLStatusView.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/11.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "CYLStatusView.h"
#if __has_include(<CYLChatKit/CYLChatKit.h>)
#import <CYLChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif

static CGFloat CYLStatusImageViewHeight = 20;
static CGFloat CYLHorizontalSpacing = 15;
static CGFloat CYLHorizontalLittleSpacing = 5;

@interface CYLStatusView ()

@property (nonatomic, strong) UIImageView *statusImageView;

@property (nonatomic, strong) UILabel *statusLabel;

@end

@implementation CYLStatusView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:199 / 255.0 blue:199 / 255.0 alpha:1];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.statusImageView];
    [self addSubview:self.statusLabel];
}

#pragma mark - Propertys

- (UIImageView *)statusImageView {
    if (_statusImageView == nil) {
        _statusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CYLHorizontalSpacing, (CYLStatusViewHight - CYLStatusImageViewHeight) / 2, CYLStatusImageViewHeight, CYLStatusImageViewHeight)];
        _statusImageView.image =  ({
            NSString *imageName = @"MessageSendFail";
            UIImage *image = [UIImage cyl_imageNamed:imageName bundleName:@"MessageBubble" bundleForClass:[self class]];
            image;});
    }
    return _statusImageView;
}

- (UILabel *)statusLabel {
    if (_statusLabel == nil) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_statusImageView.frame) + CYLHorizontalLittleSpacing, 0, self.frame.size.width - CGRectGetMaxX(_statusImageView.frame) - CYLHorizontalSpacing - CYLHorizontalLittleSpacing, CYLStatusViewHight)];
        _statusLabel.font = [UIFont systemFontOfSize:15.0];
        _statusLabel.textColor = [UIColor grayColor];
        _statusLabel.text = CYLLocalizedStrings(@"netDisconnected");
    }
    return _statusLabel;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(statusViewClicked:)]) {
        [self.delegate statusViewClicked:self];
    }
}

@end
