//
//  LCCKConversationListViewController.m
//  LeanCloudChatKit-iOS
//
//  Created by ElonChan on 16/2/22.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//

#import "LCCKConversationListViewController.h"
#import "LCCKConstants.h"
#import "LCCKSessionService.h"
#import "MJRefresh.h"
#import "LCCKConversationService.h"
#import "LCCKConversationListViewModel.h"
#import "LCChatKit.h"

@interface LCCKConversationListViewController ()

@property (nonatomic, strong) NSMutableArray *conversations;
@property (nonatomic, copy) LCCKConversationListViewModel *conversationListViewModel;

@end

@implementation LCCKConversationListViewController

#pragma mark -
#pragma mark - UIViewController Life

- (void)viewDidLoad {
    [super viewDidLoad];
    BOOL clientStatusOpened = [LCCKSessionService sharedInstance].client.status == AVIMClientStatusOpened;
    //NSAssert([LCCKSessionService sharedInstance].client.status == AVIMClientStatusOpened, @"client not opened");
    if (!clientStatusOpened) {
        LCCKSessionNotOpenedHandler sessionNotOpenedHandler = [LCCKSessionService sharedInstance].sessionNotOpenedHandler;
        !sessionNotOpenedHandler ?: sessionNotOpenedHandler(self, nil);
    }
    self.navigationItem.title = @"消息";
    self.tableView.delegate = self.conversationListViewModel;
    self.tableView.dataSource = self.conversationListViewModel;
    self.tableView.mj_header = ({
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            // 进入刷新状态后会自动调用这个 block
            [self.conversationListViewModel refresh];
            // 设置颜色
        }];
        header.stateLabel.textColor = [UIColor grayColor];
        header.lastUpdatedTimeLabel.textColor = [UIColor grayColor];
        header;
    });
    [self.tableView.mj_header beginRefreshing];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark - LazyLoad Method

/**
 *  lazy load conversations
 *
 *  @return NSMutableArray
 */
- (NSMutableArray *)conversations
{
    if (_conversations == nil) {
        _conversations = [[NSMutableArray alloc] init];
    }
    return _conversations;
}

/**
 *  lazy load conversationListViewModel
 *
 *  @return LCCKconversationListViewModel
 */
- (LCCKConversationListViewModel *)conversationListViewModel {
    if (_conversationListViewModel == nil) {
        LCCKConversationListViewModel *conversationListViewModel = [[LCCKConversationListViewModel alloc] initWithConversationListViewController:self];
        _conversationListViewModel = conversationListViewModel;
    }
    return _conversationListViewModel;
}

- (void)updateStatusView {
    BOOL isConnected = [LCCKSessionService sharedInstance].connect;
    if (isConnected) {
        self.tableView.tableHeaderView = nil ;
    } else {
        self.tableView.tableHeaderView = (UIView *)self.clientStatusView;
    }
}

- (void)refresh {
    [self.conversationListViewModel refresh];
}

@end
