//
//  CYLChatKit.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/22.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//  Core class of LeanCloudChatKit


#import <UIKit/UIKit.h>
@class CYLDemoUser;

typedef NS_ENUM(NSInteger, CYLDemoConversationOperationType) {
    CYLDemoConversationOperationTypeNone,
    CYLDemoConversationOperationTypeAdd,
    CYLDemoConversationOperationTypeRemove
};

@interface CYLDemoUserGroupItemCell : UICollectionViewCell

@property (nonatomic, strong) CYLDemoUser *user;

@property (nonatomic, strong) void (^clickBlock)(CYLDemoUser *user);

- (void)setUser:(CYLDemoUser *)user operationType:(CYLDemoConversationOperationType)operationType;

@end
