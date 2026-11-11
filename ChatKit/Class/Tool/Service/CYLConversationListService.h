//
//  CYLConversationListService.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/22.
//  Copyright © 2016年 ElonChan . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYLChatConstants.h"
#import "CYLServiceDefinition.h"


/*!
 * @param conversations Objects conforming to `CYLConversationProtocol`.
 */
typedef void (^CYLRecentConversationsCallback)(NSArray *conversations, NSInteger totalUnreadCount,  NSError *error);

@interface CYLConversationListService : CYLSingleton <CYLConversationsListService>

typedef void(^CYLPrepareConversationsWhenLoadBlock)(NSArray<id<CYLConversationProtocol>> *conversations, CYLBooleanResultBlock callback);
@property (nonatomic, copy, readonly) CYLPrepareConversationsWhenLoadBlock prepareConversationsWhenLoadBlock;
- (void)setPrepareConversationsWhenLoadBlock:(CYLPrepareConversationsWhenLoadBlock)prepareConversationsWhenLoadBlock;

- (void)findRecentConversationsWithBlock:(CYLRecentConversationsCallback)block;

/*!
 *  提供自定义行高的 Block
 */
typedef CGFloat (^CYLHeightForRowBlock) (UITableView *tableView, NSIndexPath *indexPath, id<CYLConversationProtocol> conversation);
@property (nonatomic, copy, readonly) CYLHeightForRowBlock heightForRowBlock;
- (void)setHeightForRowBlock:(CYLHeightForRowBlock)heightForRowBlock;

/*!
 *  提供自定义 Cell 的 Block，如果返回为 nil 则使用默认 Cell
 *  当使用自定义的 Cell 时，内部将不会处理 Cell，需要使用 configureCellBlock 自行配制 Cell
 */
typedef UITableViewCell* (^CYLCellForRowBlock)(UITableView *tableView, NSIndexPath *indexPath, id<CYLConversationProtocol> conversation);
@property (nonatomic, copy, readonly) CYLCellForRowBlock cellForRowBlock __deprecated_msg("CYLCellForRowBlock is deprecated. Use <CYLConversationListViewControllerDelegate> instead");
- (void)setCellForRowBlock:(CYLCellForRowBlock)cellForRowBlock __deprecated_msg("CYLCellForRowBlock is deprecated. Use <CYLConversationListViewControllerDelegate> instead");

/*!
 *  配置 Cell 的 Block，当默认的 Cell 或自定义的 Cell 需要配置时，该 block 将被调用
 */
typedef void (^CYLConfigureCellBlock) (UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath, id<CYLConversationProtocol> conversation);
@property (nonatomic, copy, readonly) CYLConfigureCellBlock configureCellBlock;
-(void)setConfigureCellBlock:(CYLConfigureCellBlock)configureCellBlock;
- (void)fetchRelationConversationsFromServerCallback:(CYLArrayResultBlock)block;

@end
