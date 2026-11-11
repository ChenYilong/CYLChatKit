//
//  CYLChatKit.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/22.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//  Core class of LeanCloudChatKit


#import "CYLDemoSettingItem.h"
#import "CYLDemoSettingCell.h"
#import "CYLDemoSettingButtonCell.h"
#import "CYLDemoSettingSwitchCell.h"

@implementation CYLDemoSettingItem

+ (CYLDemoSettingItem *) createItemWithTitle:(NSString *)title {
    CYLDemoSettingItem *item = [[CYLDemoSettingItem alloc] init];
    item.title = title;
    return item;
}

- (id) init {
    if (self = [super init]) {
        self.showDisclosureIndicator = YES;
    }
    return self;
}

- (NSString *) cellClassName {
    switch (self.type) {
        case CYLDemoSettingItemTypeDefalut:
            return NSStringFromClass([CYLDemoSettingCell class]);
            break;
        case CYLDemoSettingItemTypeTitleButton:
            return NSStringFromClass([CYLDemoSettingButtonCell class]);
            break;
        case CYLDemoSettingItemTypeSwitch:
            return NSStringFromClass([CYLDemoSettingSwitchCell class]);
            break;
        default:
            break;
    }
    return nil;
}

@end
