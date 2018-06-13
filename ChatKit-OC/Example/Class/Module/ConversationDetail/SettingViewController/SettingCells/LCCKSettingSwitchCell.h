//
//  LCChatKit.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//  Core class of LeanCloudChatKit


#import <UIKit/UIKit.h>
#import "LCCKSettingItem.h"

typedef void (^LCCKSettingSwitchCellCompletionhandler)(BOOL succeeded, NSError *error);
@protocol LCCKSettingSwitchCellDelegate <NSObject>
@optional
- (void)settingSwitchCellForItem:(LCCKSettingItem *)settingItem didChangeStatus:(BOOL)on completionHandler:(LCCKSettingSwitchCellCompletionhandler)completionHandler;
@end

@interface LCCKSettingSwitchCell : UITableViewCell

@property (nonatomic, assign) id<LCCKSettingSwitchCellDelegate>delegate;

@property (nonatomic, strong) LCCKSettingItem *item;

@end
