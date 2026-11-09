//
//  UIImageView+CYLExtension.h
//  LeanCloudChatKit-iOS
//
//  Created by 陈宜龙 on 16/5/16.
//  Copyright © 2016年 ElonChan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (CYLExtension)

- (instancetype)initWithCornerRadiusAdvance:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType;

- (void)cyl_cornerRadiusAdvance:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType;

- (instancetype)initWithRoundingRectImageView;

- (void)cyl_cornerRadiusRoundingRect;

- (void)cyl_attachBorderWidth:(CGFloat)width color:(UIColor *)color;

@end
