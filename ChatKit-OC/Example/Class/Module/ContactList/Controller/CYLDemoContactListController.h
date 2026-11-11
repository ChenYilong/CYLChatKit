//
//  CYLDemoContactListController.h
//  LeanCloudChatKit-iOS
//
//  Created by ElonChan on 16/2/22.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<ChatKit/CYLChatKit.h>)
#import <ChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif

typedef enum : NSUInteger {
    CYLDemoContactListModeNormal,
    CYLDemoContactListModeSingleSelection,
    CYLDemoContactListModeMultipleSelection
} CYLDemoContactListMode;

@class CYLDemoContactListController;

@protocol CYLDemoContactListControllerDelegate <NSObject>
- (void)contactListController:(CYLDemoContactListController *)controller
           didSelectPeerIds:(NSArray *)peerIds;
@end

@interface CYLDemoContactListController : CYLChatBaseTableViewController

@property (nonatomic, assign) CYLDemoContactListMode mode;
@property (nonatomic, strong) NSArray *excludedPersonIDs;
@property (nonatomic, weak) id<CYLDemoContactListControllerDelegate> delegate;

- (void)refresh;

@end
