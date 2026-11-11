//
//  CYLChatKit.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/22.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//  Core class of LeanCloudChatKit


#define CYLDemoColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]

#import "UIColor+CYLDemoExtension.h"

@implementation UIColor (TLChat)

#pragma mark - # 字体
+ (UIColor *)cyl_demo_colorTextBlack {
    return [UIColor blackColor];
}

+ (UIColor *)cyl_demo_colorTextGray {
    return [UIColor grayColor];
}

+ (UIColor *)cyl_demo_colorTextGray1 {
    return CYLDemoColor(160, 160, 160, 1.0);
}

#pragma mark - 灰色
+ (UIColor *)cyl_demo_colorGrayBG {
    return CYLDemoColor(239.0, 239.0, 244.0, 1.0);
}

+ (UIColor *)cyl_demo_colorGrayCharcoalBG {
    return CYLDemoColor(235.0, 235.0, 235.0, 1.0);
}

+ (UIColor *)cyl_demo_colorGrayLine {
    return [UIColor colorWithWhite:0.5 alpha:0.3];
}

+ (UIColor *)cyl_demo_colorGrayForChatBar {
    return CYLDemoColor(245.0, 245.0, 247.0, 1.0);
}

+ (UIColor *)cyl_demo_colorGrayForMoment {
    return CYLDemoColor(243.0, 243.0, 245.0, 1.0);
}

#pragma mark - 绿色
+ (UIColor *)cyl_demo_colorGreenDefault {
    return CYLDemoColor(2.0, 187.0, 0.0, 1.0f);
}


#pragma mark - 蓝色
+ (UIColor *)cyl_demo_colorBlueMoment {
    return CYLDemoColor(74.0, 99.0, 141.0, 1.0);
}

#pragma mark - 黑色
+ (UIColor *)cyl_demo_colorBlackForNavBar {
    return CYLDemoColor(20.0, 20.0, 20.0, 1.0);
}

+ (UIColor *)cyl_demo_colorBlackBG {
    return CYLDemoColor(46.0, 49.0, 50.0, 1.0);
}

+ (UIColor *)cyl_demo_colorBlackAlphaScannerBG {
    return [UIColor colorWithWhite:0 alpha:0.6];
}

+ (UIColor *)cyl_demo_colorBlackForAddMenu {
    return CYLDemoColor(71, 70, 73, 1.0);
}

+ (UIColor *)cyl_demo_colorBlackForAddMenuHL {
    return CYLDemoColor(65, 64, 67, 1.0);
}

@end
