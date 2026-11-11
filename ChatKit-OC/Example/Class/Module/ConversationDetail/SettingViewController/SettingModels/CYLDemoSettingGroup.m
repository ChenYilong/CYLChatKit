//
//  CYLChatKit.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/22.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//  Core class of LeanCloudChatKit


#import "CYLDemoSettingGroup.h"
#import "CYLDemoUIUtility.h"
#import "UIFont+CYLDemoExtension.h"

@implementation CYLDemoSettingGroup

+ (CYLDemoSettingGroup *) createGroupWithHeaderTitle:(NSString *)headerTitle
                                    footerTitle:(NSString *)footerTitle
                                          items:(NSMutableArray *)items {
    CYLDemoSettingGroup *group= [[CYLDemoSettingGroup alloc] init];
    group.headerTitle = headerTitle;
    group.footerTitle = footerTitle;
    group.items = items;
    return group;
}

#pragma mark - Public Mthods
- (id) objectAtIndex:(NSUInteger)index {
    return [self.items objectAtIndex:index];
}

- (NSUInteger)indexOfObject:(id)obj {
    return [self.items indexOfObject:obj];
}


- (void)removeObject:(id)obj {
    [self.items removeObject:obj];
}

#pragma mark - Setter
- (void)setHeaderTitle:(NSString *)headerTitle {
    _headerTitle = headerTitle;
    _headerHeight = [CYLDemoUIUtility getTextHeightOfText:headerTitle font:[UIFont cyl_demo_fontSettingHeaderAndFooterTitle] width:[UIScreen mainScreen].bounds.size.width - 30];
}

- (void)setFooterTitle:(NSString *)footerTitle {
    _footerTitle = footerTitle;
    _footerHeight = [CYLDemoUIUtility getTextHeightOfText:footerTitle font:[UIFont cyl_demo_fontSettingHeaderAndFooterTitle] width:[UIScreen mainScreen].bounds.size.width - 30];
}

#pragma mark - Getter
- (NSUInteger)count {
    return self.items.count;
}

@end
