//
//  LCChatKit.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 18/6/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//  Core class of LeanCloudChatKit


#import <Foundation/Foundation.h>
@import UIKit;
#import "LCCKSettingItem.h"

#define LCCKCreateSettingGroup(Header, Footer, Items)  [LCCKSettingGroup createGroupWithHeaderTitle:Header footerTitle:Footer items:[NSMutableArray arrayWithArray:Items]]

@interface LCCKSettingGroup : NSObject

/**
 *  section头部标题
 */
@property (nonatomic, strong) NSString *headerTitle;

/**
 *  section尾部说明
 */
@property (nonatomic, strong) NSString *footerTitle;

/**
 *  setcion元素
 */
@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, assign, readonly) CGFloat headerHeight;

@property (nonatomic, assign, readonly) CGFloat footerHeight;

@property (nonatomic, assign, readonly) NSUInteger count;

+ (LCCKSettingGroup *)createGroupWithHeaderTitle:(NSString *)headerTitle
                                    footerTitle:(NSString *)footerTitle
                                          items:(NSMutableArray *)items;

- (id)objectAtIndex:(NSUInteger)index;

- (NSUInteger)indexOfObject:(id)obj;

- (void)removeObject:(id)obj;

@end
