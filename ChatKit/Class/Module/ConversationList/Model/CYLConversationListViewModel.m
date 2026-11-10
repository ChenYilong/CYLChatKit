//
//  CYLConversationListViewModel.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "CYLConversationListViewModel.h"
#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif
#import "CYLConversationListCell.h"
#import "CYLUserDelegate.h"
#import "CYLUserSystemService.h"
#import "CYLConversationListViewController.h"
#import "CYLChatConstants.h"
#import "CYLLastMessageTypeManager.h"
#import "NSDate+CYLDateTools.h"
#import "CYLConversationListService.h"
#import "UIImage+CYLExtension.h"

#if __has_include(<MJRefresh/MJRefresh.h>)
    #import <MJRefresh/MJRefresh.h>
#else
    #import "MJRefresh.h"
#endif

#if __has_include(<SDWebImage/UIImageView+WebCache.h>)
    #import <SDWebImage/UIImageView+WebCache.h>
#else
    #import "UIImageView+WebCache.h"
#endif

#if __has_include(<CYLDeallocBlockExecutor/CYLDeallocBlockExecutor.h>)
#import <CYLDeallocBlockExecutor/CYLDeallocBlockExecutor.h>
#else
#import "CYLDeallocBlockExecutor.h"
#endif
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>

@interface CYLConversationListViewModel ()

@property (nonatomic, weak) CYLConversationListViewController *conversationListViewController;
@property (nonatomic, assign, getter=isFreshing) BOOL freshing;

@end

@implementation CYLConversationListViewModel

#pragma mark -
#pragma mark - LifeCycle Method

- (instancetype)initWithConversationListViewController:(CYLConversationListViewController *)conversationListViewController {
    self = [super init];
    if (!self) {
        return nil;
    }
    // 当在其它 Tab 的时候，收到消息, badge 增加，所以需要一直监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:CYLNotificationMessageReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:CYLNotificationMessageUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:CYLNotificationUnreadsUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:CYLNotificationConversationListDataSourceUpdated object:nil];
    [self cyl_willDeallocWithSelfCallback:^(__unsafe_unretained id owner, NSUInteger identifier) {
        [[NSNotificationCenter defaultCenter] removeObserver:owner];
    }];
    _conversationListViewController = conversationListViewController;
    return self;
}

#pragma mark - table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<CYLConversationProtocol> conversation = [self.dataArray objectAtIndex:indexPath.row];
    
    CYLCellForRowBlock cellForRowBlock = [[CYLConversationListService sharedInstance] cellForRowBlock];
    if (cellForRowBlock) {
        UITableViewCell *customCell = cellForRowBlock(tableView, indexPath, conversation);
        CYLConfigureCellBlock configureCellBlock = [[CYLConversationListService sharedInstance] configureCellBlock];
        if (configureCellBlock) {
            configureCellBlock(customCell, tableView, indexPath, conversation);
        }
        return customCell;
    }
    CYLConversationListCell *cell = [CYLConversationListCell dequeueOrCreateCellByTableView:tableView];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [tableView setSeparatorColor:[[CYLSettingService sharedInstance] defaultThemeColorForKey:@"TableView-SeparatorColor"]];
    __block NSString *displayName = nil;
    __block NSURL *avatarURL = nil;
    __block NSInteger userType = 0;
    NSString *peerId = nil;
    if (conversation.cyl_type == CYLConversationTypeSingle) {
        peerId = conversation.cyl_peerId;
        cell.clientId = conversation.cyl_peerId;
    } else {
        peerId = conversation.cyl_lastMessage.cyl_senderId;
        cell.clientId = nil;
    }
    if (peerId) {
        [self asyncCacheElseNetLoadCell:cell peerId:peerId name:&displayName userType:&userType avatarURL:&avatarURL];
    }
    if (userType == 1) {
        cell.officialSignImageView.hidden = NO;
    } else {
        cell.officialSignImageView.hidden = YES;
    }
    if (conversation.cyl_type == CYLConversationTypeSingle) {
        [cell.avatarImageView sd_setImageWithURL:avatarURL placeholderImage:[self imageInBundleForImageName:@"Placeholder_Avatar" ]];
    } else {
        NSString *conversationGroupAvatarURLKey = [conversation.attributes valueForKey:CYLConversationGroupAvatarURLKey];
        NSURL *conversationGroupAvatarURL = [NSURL URLWithString:conversationGroupAvatarURLKey];
        [cell.avatarImageView sd_setImageWithURL:conversationGroupAvatarURL placeholderImage:[self imageInBundleForImageName:@"Placeholder_Group" ]];
    }
    cell.remindMuteImageView.hidden = !conversation.muted;
    cell.nameLabel.text = conversation.cyl_displayName;
    if (conversation.cyl_lastMessage) {
        cell.messageTextLabel.attributedText = [CYLLastMessageTypeManager attributedStringWithMessage:conversation.cyl_lastMessage conversation:conversation userName:displayName];
        cell.timestampLabel.text = [conversation.cyl_lastMessageAt cyl_timeAgoSinceNow];
    }
    if (conversation.cyl_unreadCount > 0) {
        if (conversation.muted) {
            cell.litteBadgeView.hidden = NO;
        } else {
            cell.badgeView.badgeText = conversation.cyl_badgeText;
        }
    }

    CYLConfigureCellBlock configureCellBlock = [[CYLConversationListService sharedInstance] configureCellBlock];
    
    BOOL impDelegate = [self.conversationListViewController.delegate respondsToSelector:@selector(conversation:cell:tableView:cellForRowAtIndexPath:)];

    // Delegate 与 Block 两种方式不能同时实现
    if (configureCellBlock && impDelegate) {
        //TODO: add debug model
//        [NSException raise:NSInternalInconsistencyException format:@"Block or Delegate choose one."];
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"Block or Delegate choose one.");
        return cell;
    }
    // 调用 Delegate
    else if (impDelegate){
        
        [self.conversationListViewController.delegate conversation:conversation cell:cell tableView:tableView cellForRowAtIndexPath:indexPath];

    }
    // 调用 Block
    else if (configureCellBlock){
        configureCellBlock(cell, tableView, indexPath, conversation);
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    CYLConversationEditActionsBlock conversationEditActionBlock = [[CYLConversationListService sharedInstance] conversationEditActionBlock];
    id<CYLConversationProtocol> conversation = nil;
    if ((NSUInteger)indexPath.row < self.dataArray.count) {
        conversation = [self.dataArray objectAtIndex:indexPath.row];
    }
    else {
        return nil;
    }
    NSArray *editActions = [NSArray array];
    if (conversationEditActionBlock) {
        editActions = conversationEditActionBlock(indexPath, [self defaultRightButtons], conversation, self.conversationListViewController);
    } else {
        editActions = [self defaultRightButtons];
    }
    return editActions;
}

- (void)asyncCacheElseNetLoadCell:(CYLConversationListCell *)cell peerId:(NSString *)peerId name:(NSString **)name avatarURL:(NSURL **)avatarURL {
    NSError *error = nil;
    cell.identifier = peerId;
    [[CYLUserSystemService sharedInstance] getCachedProfileIfExists:peerId name:name avatarURL:avatarURL error:&error];
    if (error) {
//        NSLog(@"%@", error);
    }
    //头像消息一般和昵称消息一同返回，故假设如果服务端返回了昵称，那么如果该用户有头像就一定会返回头像。反之，没返回昵称，一定是还未缓存用户信息。如果你的App中，不是这样的逻辑，可联系维护者将这一逻辑修改得严谨些，邮箱luohanchenyilong@163.com.
    if (!*name) {
        if (peerId != NULL && ![CYLSettingService sharedInstance].isDisablePreviewUserId) {
            *name = peerId;
        }
        __weak __typeof(self) weakSelf = self;
        __weak __typeof(cell) weakCell = cell;
        [[CYLUserSystemService sharedInstance] getProfileInBackgroundForUserId:peerId callback:^(id<CYLUserDelegate> user, NSError *error) {
            BOOL hasData = user.name;
            if (hasData && [weakCell.identifier isEqualToString:user.clientId]) {
                NSIndexPath *indexPath_ = [weakSelf.conversationListViewController.tableView indexPathForCell:weakCell];
                if (!indexPath_) {
                    return;
                }
                dispatch_async(dispatch_get_main_queue(),^{
                    [weakSelf.conversationListViewController.tableView reloadRowsAtIndexPaths:@[indexPath_] withRowAnimation:UITableViewRowAnimationNone];
                });
            }
        }];
    }
}

- (void)asyncCacheElseNetLoadCell:(CYLConversationListCell *)cell peerId:(NSString *)peerId name:(NSString **)name userType:(NSInteger *)userType avatarURL:(NSURL **)avatarURL {
    NSError *error = nil;
    cell.identifier = peerId;
    [[CYLUserSystemService sharedInstance] getCachedProfileIfExists:peerId name:name avatarURL:avatarURL userTye:userType error:&error];
    if (error) {
//        NSLog(@"%@", error);
    }
    //头像消息一般和昵称消息一同返回，故假设如果服务端返回了昵称，那么如果该用户有头像就一定会返回头像。反之，没返回昵称，一定是还未缓存用户信息。如果你的App中，不是这样的逻辑，可联系维护者将这一逻辑修改得严谨些，邮箱luohanchenyilong@163.com.
    if (!*name) {
        if (peerId != NULL && ![CYLSettingService sharedInstance].isDisablePreviewUserId) {
            *name = peerId;
        }
        __weak __typeof(self) weakSelf = self;
        __weak __typeof(cell) weakCell = cell;
        [[CYLUserSystemService sharedInstance] getProfileInBackgroundForUserId:peerId callback:^(id<CYLUserDelegate> user, NSError *error) {
            BOOL hasData = user.name;
            if (hasData && [weakCell.identifier isEqualToString:user.clientId]) {
                NSIndexPath *indexPath_ = [weakSelf.conversationListViewController.tableView indexPathForCell:weakCell];
                if (!indexPath_) {
                    return;
                }
                dispatch_async(dispatch_get_main_queue(),^{
                    [weakSelf.conversationListViewController.tableView reloadRowsAtIndexPaths:@[indexPath_] withRowAnimation:UITableViewRowAnimationNone];
                });
            }
        }];
    }
}

- (NSArray *)defaultRightButtons {
    UITableViewRowAction *actionItemDelete = [UITableViewRowAction
                                              rowActionWithStyle:UITableViewRowActionStyleNormal
                                              title:CYLLocalizedStrings(@"Delete")
                                              handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                  id<CYLConversationProtocol> conversation = [self.dataArray objectAtIndex:indexPath.row];
                                                  [[CYLConversationService sharedInstance] deleteRecentConversationWithConversationId:conversation.conversationId];
                                                  [self refresh];
                                                  CYLDidDeleteConversationsListCellBlock conversationsListDidDeleteItemBlock = [CYLConversationListService sharedInstance].didDeleteConversationsListCellBlock;
                                                  !conversationsListDidDeleteItemBlock ?: conversationsListDidDeleteItemBlock(indexPath, conversation, self.conversationListViewController);
                                              }];
    actionItemDelete.backgroundColor = [UIColor redColor];
    return @[ actionItemDelete ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id<CYLConversationProtocol> conversation = [self.dataArray objectAtIndex:indexPath.row];
    
    id didSelectBlock = [CYLConversationListService sharedInstance].didSelectConversationsListCellBlock;
    BOOL impDelegate = [self.conversationListViewController.delegate respondsToSelector:@selector(conversation:tableView:didSelectRowAtIndexPath:)];
    
    // Delegate 与 Block 两种方式不能同时实现
    if (didSelectBlock && impDelegate) {
        //TODO: add debug model
//        [NSException raise:NSInternalInconsistencyException format:@"Block or Delegate choose one."];
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"Block or Delegate choose one.");
        return;
    }
    // 调用 Delegate
    else if (impDelegate){
        
        [self.conversationListViewController.delegate conversation:conversation tableView:tableView didSelectRowAtIndexPath:indexPath];
        
    }
    // 调用 Block
    else if (didSelectBlock){
        !didSelectBlock ?: [CYLConversationListService sharedInstance].didSelectConversationsListCellBlock(indexPath, conversation, self.conversationListViewController);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CYLHeightForRowBlock heightForRowBlock = [[CYLConversationListService sharedInstance] heightForRowBlock];
    if (heightForRowBlock) {
        id<CYLConversationProtocol> conversation = [self.dataArray objectAtIndex:indexPath.row];
        return heightForRowBlock(tableView, indexPath, conversation);
    }
    return CYLConversationListCellDefaultHeight;
}

#pragma mark - refresh

- (void)setFreshing:(BOOL)freshing {
    _freshing = freshing;
    if (freshing == NO) {
        [self.conversationListViewController.tableView.mj_header endRefreshing];
    }
}

- (void)refresh {
    self.freshing = YES;
    //FIXME:  
    [[CYLConversationListService sharedInstance] findRecentConversationsWithBlock:^(NSArray *conversations, NSInteger totalUnreadCount, NSError *error) {
        dispatch_block_t finishBlock = ^{
            self.freshing = NO;
            if ([self.conversationListViewController filterCYLIMError:error]) {
                self.dataArray = [NSMutableArray arrayWithArray:conversations];
                [self.conversationListViewController.tableView cyl_reloadData];
                [self selectConversationIfHasRemoteNotificatoinConvid];
                CYLMarkBadgeWithTotalUnreadCountBlock markBadgeWithTotalUnreadCountBlock = [CYLConversationListService sharedInstance].markBadgeWithTotalUnreadCountBlock;
                if (markBadgeWithTotalUnreadCountBlock) {
                    [CYLConversationListService sharedInstance].markBadgeWithTotalUnreadCountBlock(totalUnreadCount, self.conversationListViewController.navigationController);
                    return;
                }
                if (totalUnreadCount > 0) {
                    NSString *badgeValue = [NSString stringWithFormat:@"%ld", (long)totalUnreadCount];
                    if (totalUnreadCount > 99) {
                        badgeValue = CYLBadgeTextForNumberGreaterThanLimit;
                    }
                    [self.conversationListViewController.navigationController tabBarItem].badgeValue = badgeValue;
//                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:totalUnreadCount];
                } else {
                    [self.conversationListViewController.navigationController tabBarItem].badgeValue = nil;
//                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
                }
            }
        };
        if([CYLConversationListService sharedInstance].prepareConversationsWhenLoadBlock) {
            [CYLConversationListService sharedInstance].prepareConversationsWhenLoadBlock(conversations, ^(BOOL succeeded, NSError *error) {
                if ([self.conversationListViewController filterCYLIMError:error]) {
                    finishBlock();
                } else {
                    self.freshing = NO;
                }
            });
        } else {
            finishBlock();
        }
    }];
}

- (void)selectConversationIfHasRemoteNotificatoinConvid {
    NSString * remoteNotificationConversationId= [CYLConversationService sharedInstance].remoteNotificationConversationId;
    if (remoteNotificationConversationId) {
        // 进入之前推送弹框点击的对话
        __block BOOL found = NO;
        [self.dataArray enumerateObjectsUsingBlock:^(id<CYLConversationProtocol> _Nonnull conversation, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([conversation.conversationId isEqualToString:remoteNotificationConversationId]) {
                //TODO: If has section.
                NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:idx];
                ![CYLConversationListService sharedInstance].didSelectConversationsListCellBlock ?: [CYLConversationListService sharedInstance].didSelectConversationsListCellBlock(indexPath, conversation, self.conversationListViewController);
                found = YES;
                *stop = YES;
                return;
            }
        }];
        
        if (!found) {
            CYLLog(@"not found remoteNofitciaonID");
        }
        [CYLConversationService sharedInstance].remoteNotificationConversationId = nil;
    }
}

#pragma mark -
#pragma mark - LazyLoad Method

/**
 *  lazy load dataArray
 *
 *  @return NSMutableArray
 */
- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = @[].mutableCopy;
    }
    return _dataArray;
}

- (UIImage *)imageInBundleForImageName:(NSString *)imageName {
    return ({
        UIImage *image = [UIImage cyl_imageNamed:imageName bundleName:@"Placeholder" bundleForClass:[self class]];
        image;});
}

#pragma mark - CYLTableViewPlaceHolderDelegate Method

- (UIView *)makePlaceHolderView {
    return self.conversationListViewController.placeHolderView;;
}

@end
