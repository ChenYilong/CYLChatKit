//
//  CYLConversationListViewModel.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CYLConversationListViewController;
#import "CYLConversationProtocol.h"

@interface CYLConversationListViewModel : NSObject <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithConversationListViewController:(CYLConversationListViewController *)conversationListViewController;

@property (nonatomic, strong) NSMutableArray<id<CYLConversationProtocol>> *dataArray;

- (void)refresh;

@end
