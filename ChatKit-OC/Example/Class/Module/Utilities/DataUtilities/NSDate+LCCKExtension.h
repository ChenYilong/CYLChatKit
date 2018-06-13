//
//  LCCKContactListViewController.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 18/6/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate+Extension.h"
#import "NSDate+Utilities.h"

@interface NSDate (LCCKExtension)

- (NSString *)lcck_chatTimeInfo;

- (NSString *)lcck_conversaionTimeInfo;

- (NSString *)lcck_chatFileTimeInfo;

@end
