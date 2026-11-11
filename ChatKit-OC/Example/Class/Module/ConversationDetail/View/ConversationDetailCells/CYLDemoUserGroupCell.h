//
//  CYLChatKit.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/22.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//  Core class of LeanCloudChatKit


#import <UIKit/UIKit.h>
@class CYLDemoUser;
#import "CYLDemoUserGroupItemCell.h"

@protocol CYLDemoUserGroupCellDelegate <NSObject>

- (void)userGroupCellDidSelectUser:(CYLDemoUser *)user;

- (void)userGroupCellAddUserButtonDownWithOperationType:(CYLDemoConversationOperationType)operationType;;

@end

@interface CYLDemoUserGroupCell : UITableViewCell

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) id<CYLDemoUserGroupCellDelegate>delegate;

@property (nonatomic, strong) NSMutableArray *users;


@end
