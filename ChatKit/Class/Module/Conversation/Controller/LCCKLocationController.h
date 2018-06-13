//
//  LCCKLocationController.h
//  LCCKChatBarExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/leancloud/ChatKit-OC ) on 15/8/24.
//  Copyright (c) 2015年 https://LeanCloud.cn . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCCKLocationManager.h"

@protocol LCCKLocationControllerDelegate <NSObject>

- (void)cancelLocation;
- (void)sendLocation:(CLPlacemark *)placemark;

@end

/**
 *  选择地理位置
 */
@interface LCCKLocationController : UIViewController

@property (weak, nonatomic) id<LCCKLocationControllerDelegate> delegate;

@end
