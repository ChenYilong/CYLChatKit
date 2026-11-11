//
//  CYLChatKit.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/22.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//  Core class of LeanCloudChatKit


#import <UIKit/UIKit.h>
#import "CYLDemoSettingItem.h"

typedef void (^CYLDemoSettingSwitchCellCompletionhandler)(BOOL succeeded, NSError *error);
@protocol CYLDemoSettingSwitchCellDelegate <NSObject>
@optional
- (void)settingSwitchCellForItem:(CYLDemoSettingItem *)settingItem didChangeStatus:(BOOL)on completionHandler:(CYLDemoSettingSwitchCellCompletionhandler)completionHandler;
@end

@interface CYLDemoSettingSwitchCell : UITableViewCell

@property (nonatomic, assign) id<CYLDemoSettingSwitchCellDelegate>delegate;

@property (nonatomic, strong) CYLDemoSettingItem *item;

@end
