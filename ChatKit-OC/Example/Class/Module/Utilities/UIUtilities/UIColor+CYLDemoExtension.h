//
//  CYLChatKit.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/22.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//  Core class of LeanCloudChatKit


#import <UIKit/UIKit.h>

@interface UIColor (TLChat)

#pragma mark - # 字体
+ (UIColor *)cyl_demo_colorTextBlack;
+ (UIColor *)cyl_demo_colorTextGray;
+ (UIColor *)cyl_demo_colorTextGray1;


#pragma mark - 灰色
+ (UIColor *)cyl_demo_colorGrayBG;           // 浅灰色默认背景
+ (UIColor *)cyl_demo_colorGrayCharcoalBG;   // 较深灰色背景（聊天窗口, 朋友圈用）
+ (UIColor *)cyl_demo_colorGrayLine;
+ (UIColor *)cyl_demo_colorGrayForChatBar;
+ (UIColor *)cyl_demo_colorGrayForMoment;


#pragma mark - 绿色
+ (UIColor *)cyl_demo_colorGreenDefault;


#pragma mark - 蓝色
+ (UIColor *)cyl_demo_colorBlueMoment;


#pragma mark - 黑色
+ (UIColor *)cyl_demo_colorBlackForNavBar;
+ (UIColor *)cyl_demo_colorBlackBG;
+ (UIColor *)cyl_demo_colorBlackAlphaScannerBG;
+ (UIColor *)cyl_demo_colorBlackForAddMenu;
+ (UIColor *)cyl_demo_colorBlackForAddMenuHL;


@end
