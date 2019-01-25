//
//  LCCKBaseTableViewController.h
//  LeanCloudChatKit-iOS
//
//  Created by 陈宜龙 on 16/3/9.
//  Copyright © 2016年 ElonChan. All rights reserved.
//


#import "LCCKBaseViewController.h"
@class LCCKStatusView;

@interface LCCKBaseTableViewController : LCCKBaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong, readonly) LCCKStatusView *clientStatusView;

/**
 *  显示大量数据的控件
 */
@property (nonatomic, weak) UITableView *tableView;

/**
 *  初始化init的时候设置tableView的样式才有效
 */
@property (nonatomic, assign) UITableViewStyle tableViewStyle;

/**
 *  大量数据的数据源
 */
@property (nonatomic, strong) NSMutableArray *dataSource;

/**
 *  加载本地或者网络数据源
 */
- (void)loadDataSource;

@end
