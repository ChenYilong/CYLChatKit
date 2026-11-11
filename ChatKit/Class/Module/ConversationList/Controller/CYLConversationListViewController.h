//
//  CYLConversationListViewController.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 18/6/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYLChatBaseTableViewController.h"

#import "CYLConversationProtocol.h"

@protocol CYLConversationListViewControllerDelegate <NSObject>

@optional
/*!
 实现代理方法,可获得到cell点击事件的回调
 */
- (void)conversation:(id<CYLConversationProtocol>)conversation tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

/*!
 实现代理方法,当默认的 Cell 或自定义的 Cell 需要配置时，该代理将被调用
 */
- (void)conversation:(id<CYLConversationProtocol>)conversation cell:(UITableViewCell *)cell tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
/*!
 *  对话列表 Cell 的默认高度
 */
FOUNDATION_EXTERN const CGFloat CYLConversationListCellDefaultHeight;

@interface CYLConversationListViewController : CYLChatBaseTableViewController

@property (nonatomic, weak) id<CYLConversationListViewControllerDelegate> delegate;
@property (nonatomic, strong) UIView *placeHolderView;

- (void)refresh;

@end

