//
//  LCCKConversationListViewController.h
//  LeanCloudChatKit-iOS
//
//  Created by ElonChan on 16/2/22.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCCKBaseTableViewController.h"
#import <AVOSCloudIM/AVOSCloudIM.h>

/**
 *  会话列表 Cell 的默认高度
 */
FOUNDATION_EXTERN const CGFloat LCCKConversationListCellDefaultHeight;

@interface LCCKConversationListViewController : LCCKBaseTableViewController

- (void)refresh;

@end

