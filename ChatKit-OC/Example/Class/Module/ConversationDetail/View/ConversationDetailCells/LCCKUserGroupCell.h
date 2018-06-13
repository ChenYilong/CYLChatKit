//
//  LCChatKit.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//  Core class of LeanCloudChatKit


#import <UIKit/UIKit.h>
@class LCCKUser;
#import "LCCKUserGroupItemCell.h"

@protocol LCCKUserGroupCellDelegate <NSObject>

- (void)userGroupCellDidSelectUser:(LCCKUser *)user;

- (void)userGroupCellAddUserButtonDownWithOperationType:(LCCKConversationOperationType)operationType;;

@end

@interface LCCKUserGroupCell : UITableViewCell

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) id<LCCKUserGroupCellDelegate>delegate;

@property (nonatomic, strong) NSMutableArray *users;


@end
