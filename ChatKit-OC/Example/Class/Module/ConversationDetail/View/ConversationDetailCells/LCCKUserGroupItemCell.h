//
//  LCChatKit.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//  Core class of LeanCloudChatKit


#import <UIKit/UIKit.h>
@class LCCKUser;

typedef NS_ENUM(NSInteger, LCCKConversationOperationType) {
    LCCKConversationOperationTypeNone,
    LCCKConversationOperationTypeAdd,
    LCCKConversationOperationTypeRemove
};

@interface LCCKUserGroupItemCell : UICollectionViewCell

@property (nonatomic, strong) LCCKUser *user;

@property (nonatomic, strong) void (^clickBlock)(LCCKUser *user);

- (void)setUser:(LCCKUser *)user operationType:(LCCKConversationOperationType)operationType;

@end
