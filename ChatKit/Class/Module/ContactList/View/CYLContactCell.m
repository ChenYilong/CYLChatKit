//
//  CYLContactCell.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/9.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "CYLContactCell.h"

#if __has_include(<SDWebImage/UIImageView+WebCache.h>)
    #import <SDWebImage/UIImageView+WebCache.h>
#else
    #import "UIImageView+WebCache.h"
#endif

#if __has_include(<CYLChatKit/LCChatKit.h>)
    #import <CYLChatKit/LCChatKit.h>
#else
    #import "LCChatKit.h"
#endif

@interface CYLContactCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectionStatusButton;

@end

@implementation CYLContactCell

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    self.selectionStatusButton.selected = checked;
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setup {
    CYLAvatarImageViewCornerRadiusBlock avatarImageViewCornerRadiusBlock = [LCChatKit sharedInstance].avatarImageViewCornerRadiusBlock;
    if (avatarImageViewCornerRadiusBlock) {
        CGFloat avatarImageViewCornerRadius = avatarImageViewCornerRadiusBlock(self.avatarImageView.frame.size);
        // Related avatar corner-radius report: https://github.com/leancloud/ChatKit-OC/issues/347
        self.avatarImageView.layer.cornerRadius = avatarImageViewCornerRadius;
        self.avatarImageView.clipsToBounds = YES;
    }
    NSString *selectionStatusButtonNormalImageName = @"CellGraySelected";
    NSString *selectionStatusButtonSelectedImageName = @"CellBlueSelected";
    UIImage *selectionStatusButtonNormalImage = [UIImage cyl_imageNamed:selectionStatusButtonNormalImageName bundleName:@"Other" bundleForClass:[LCChatKit class]];
    UIImage *selectionStatusButtonSelectedImage = [UIImage cyl_imageNamed:selectionStatusButtonSelectedImageName bundleName:@"Other" bundleForClass:[LCChatKit class]];
    [self.selectionStatusButton setImage:selectionStatusButtonNormalImage forState:UIControlStateNormal];
    [self.selectionStatusButton setImage:selectionStatusButtonSelectedImage forState:UIControlStateSelected];
}

- (void)configureWithAvatarURL:(NSURL *)avatarURL title:(NSString *)title subtitle:(NSString *)subtitle model:(CYLContactListMode)model {
    NSString *imageName = @"Placeholder_Avatar";
    UIImage *image = [UIImage cyl_imageNamed:imageName bundleName:@"Placeholder" bundleForClass:[LCChatKit class]];
    UIImage *avatarImage = image;
    [self.avatarImageView sd_setImageWithURL:avatarURL placeholderImage:avatarImage];
    self.titleLabel.text = title;
    self.subtitleLabel.text = subtitle;
    if (subtitle.length == 0) {
        self.subtitleLabel.hidden = YES;
    }
    if (model != CYLContactListModeMultipleSelection) {
        self.selectionStatusButton.hidden = YES;
    }
}

@end
