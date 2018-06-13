//
//  LCCKConversationListViewModel.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/3/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LCCKConversationListViewController;
@class AVIMConversation;

@interface LCCKConversationListViewModel : NSObject <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithConversationListViewController:(LCCKConversationListViewController *)conversationListViewController;

@property (nonatomic, strong) NSMutableArray<AVIMConversation *> *dataArray;

- (void)refresh;

@end
