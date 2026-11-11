//
//  CYLDemoGroupConversationDetailViewController.m
//  ChatKit-OC
//
//  Created by 陈宜龙 on 12/8/16.
//  Copyright © 2016 ElonChan. All rights reserved.
//

#import "CYLDemoGroupConversationDetailViewController.h"
#import "CYLDemoUserGroupCell.h"
#import "CYLDemoChatDetailHelper.h"
#if __has_include(<ChatKit/CYLChatKit.h>)
#import <ChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif
#import "CYLDemoContactManager.h"
#import "CYLDemoProfileNameEditViewController.h"
#import "CYLTabBarController.h"
#import "CYLDemoUser.h"
#import "CYLDemoGroupConversationManagementViewController.h"

@interface CYLDemoGroupConversationDetailViewController ()<CYLDemoUserGroupCellDelegate, CYLDemoProfileNameEditViewControllerDelegate>

@property (nonatomic, strong) CYLDemoChatDetailHelper *helper;

@end

@implementation CYLDemoGroupConversationDetailViewController
@synthesize data = _data;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"聊天详情"];
    
    self.helper = [[CYLDemoChatDetailHelper alloc] init];
    
    [self.tableView registerClass:[CYLDemoUserGroupCell class] forCellReuseIdentifier:NSStringFromClass([CYLDemoUserGroupCell class])];
}

/**
 *  lazy load data
 *
 *  @return NSMutableArray
 */
- (NSMutableArray *)data {
    if (_data == nil) {
        _data = [self.helper chatDetailDataByGroupInfo:self.conversation];
    }
    return _data;
}

#pragma mark - Delegate -
//MARK: UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        CYLDemoUserGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CYLDemoUserGroupCell class])];
        NSArray *users = [[CYLChatKit sharedInstance] getCachedProfilesIfExists:self.conversation.members error:nil];
        [cell setUsers:[users mutableCopy]];
        [cell setDelegate:self];
        [cell.collectionView reloadData];
        return cell;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

//MARK: UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    CYLDemoSettingItem *item = [self.data[indexPath.section] objectAtIndex:indexPath.row];
    if ([item.title isEqualToString:@"群聊名称"]) {
        BOOL isCreater = [self.conversation cyl_isCreaterForCurrentUser];
        BOOL tooManyMembers = self.conversation.members.count > 5;
        if (tooManyMembers && !isCreater) {
            NSString *creatorNickname = nil;
            [[CYLChatKit sharedInstance] getCachedProfileIfExists:self.conversation.creator name:&creatorNickname avatarURL:nil error:nil];
            NSString *title = [NSString stringWithFormat:@"当前群聊人数较多，只有群主%@才能修改群名称", creatorNickname ?: self.conversation.creator];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:title delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
            [alert show];
            return;
        }
        CYLDemoProfileNameEditViewController *profileNameEditViewController = [[CYLDemoProfileNameEditViewController alloc] init];
        profileNameEditViewController.title = @"群聊名称";
        profileNameEditViewController.delegate = self;
        profileNameEditViewController.placeholderName = self.conversation.name;

        [self.navigationController pushViewController:profileNameEditViewController animated:YES];
    } else if ([item.title isEqualToString:@"群二维码"]) {
//        CYLDemoGroupQRCodeViewController *gorupQRCodeVC = [[CYLDemoGroupQRCodeViewController alloc] init];
//        [gorupQRCodeVC setGroup:self.conversation];
//        [self setHidesBottomBarWhenPushed:YES];
//        [self.navigationController pushViewController:gorupQRCodeVC animated:YES];
    }
    else if ([item.title isEqualToString:@"设置当前聊天背景"]) {
        [self presentViewController:self.pickerController animated:YES completion:nil];
//        CYLDemoChatBackgroundSettingViewController *chatBGSettingVC = [[CYLDemoChatBackgroundSettingViewController alloc] init];
//        [chatBGSettingVC setPartnerID:self.conversation.groupID];
//        [self setHidesBottomBarWhenPushed:YES];
//        [self.navigationController pushViewController:chatBGSettingVC animated:YES];
    }
    else if ([item.title isEqualToString:@"聊天文件"]) {
//        CYLDemoChatFileViewController *chatFileVC = [[CYLDemoChatFileViewController alloc] init];
//        [chatFileVC setPartnerID:self.conversation.groupID];
//        [self setHidesBottomBarWhenPushed:YES];
//        [self.navigationController pushViewController:chatFileVC animated:YES];
    }
    else if ([item.title isEqualToString:@"清空聊天记录"]) {
//        CYLDemoActionSheet *actionSheet = [[CYLDemoActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"清空聊天记录" otherButtonTitles: nil];
//        actionSheet.tag = TAG_EMPTY_CHAT_REC;
//        [actionSheet show];
    }
    else if ([item.title isEqualToString:@"群管理"]) {
        CYLDemoGroupConversationManagementViewController *vc = [[CYLDemoGroupConversationManagementViewController alloc] initWithStyle:UITableViewStyleGrouped];
        vc.conversation = self.conversation;
        [self.navigationController pushViewController:vc animated:true];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        NSUInteger count = self.conversation.members.count;
        if ([self cyl_isCreatorForCurrentGroupConversaton]) {
            count ++;
        }
        return ((count + 1) / 4 + ((((count + 1) % 4) == 0) ? 0 : 1)) * 90 + 15;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

//MARK: CYLDemoActionSheetDelegate
//- (void)actionSheet:(CYLDemoActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (actionSheet.tag == TAG_EMPTY_CHAT_REC) {
//        if (buttonIndex == 0) {
//            BOOL ok = [[CYLDemoMessageManager sharedInstance] deleteMessagesByPartnerID:self.conversation.groupID];
//            if (!ok) {
//                [UIAlertView bk_alertViewWithTitle:@"错误" message:@"清空讨论组聊天记录失败"];
//            }
//            else {
//                [[CYLDemoChatViewController sharedChatVC] resetChatVC];
//            }
//        }
//    }
//}

- (void)settingSwitchCellForItem:(CYLDemoSettingItem *)settingItem didChangeStatus:(BOOL)on completionHandler:(CYLDemoSettingSwitchCellCompletionhandler)completionHandler {
    if ([settingItem.title isEqualToString:@"消息免打扰"]) {
        [[self class] showHUD];
        __weak __typeof(self) weakSelf = self;
        [self.conversation cyl_setConversationWithMute:on callback:^(BOOL succeeded, NSError *error) {
            completionHandler(succeeded, error);
            [[weakSelf class] hideHUD];
            if (succeeded) {
                [[CYLConversationService sharedInstance] removeCacheForConversationId:weakSelf.conversation.conversationId];
                [[weakSelf class] showSuccess:on ? @"已设为静音" : @"已设为提醒"];
            } else {
                [[weakSelf class] showSuccess:@"设置失败"];
            }
        }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Switch事件未被子类处理" message:[NSString stringWithFormat:@"Title: %@\nStatus: %@", settingItem.title, (on ? @"on" : @"off")] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)userGroupCellDidSelectUser:(CYLDemoUser *)user {
    NSString *currentClientID = [[CYLChatKit sharedInstance] clientId];
    if ([currentClientID isEqualToString:user.clientId]) {
        return;
    }
    NSString *peerId = user.clientId;
    CYLConversationViewController *conversationViewController = [[CYLConversationViewController alloc] initWithPeerId:peerId];
    [self cyl_pushOrPopToViewController:conversationViewController animated:YES callback:^(NSArray<__kindof CYLConversationViewController *> *viewControllers, CYLPushOrPopCompletionHandler completionHandler) {
        __block CYLConversationViewController *viewControllerPopTo = nil;
        __block BOOL shouldPop = NO;
        [viewControllers enumerateObjectsUsingBlock:^(__kindof CYLConversationViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.peerId isEqualToString:peerId]) {
                viewControllerPopTo = obj;
                shouldPop = YES;
                *stop = YES;
                return;
            }
        }];
        completionHandler(shouldPop, viewControllerPopTo, YES, 0);
    }];
}

- (void)userGroupCellAddUserButtonDownWithOperationType:(CYLDemoConversationOperationType)operationType {
    switch (operationType) {
        case CYLDemoConversationOperationTypeNone:
            break;
        case CYLDemoConversationOperationTypeAdd: {
            NSArray *allPersonIds = [[CYLDemoContactManager defaultManager] fetchContactPeerIds];
            [self presentSelectMemberViewControllerMemberIds:allPersonIds excludedUserIds:self.conversation.members callback:^(NSArray *peerIds, NSError *error) {
                __weak __typeof(self) weakSelf = self;
                [self addAndCacheMembersWithClientIds:peerIds callback:^(BOOL succeeded, NSError * _Nullable error) {
                    [[weakSelf class] hideHUD];
                    if (succeeded) {
                        _data = nil;
                        [[weakSelf class] showSuccess:@"添加成功"];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                        [weakSelf.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                    } else {
                        [[weakSelf class] showError:@"添加失败"];
                    }
                }];
            }];
        }
            break;
        case CYLDemoConversationOperationTypeRemove: {
            [self presentSelectMemberViewControllerMemberIds:self.conversation.members excludedUserIds:nil callback:^(NSArray *peerIds, NSError *error) {
                [self.conversation removeMembersWithClientIds:peerIds callback:^(BOOL succeeded, NSError * _Nullable error) {
                    [[self class] hideHUD];
                    if (succeeded) {
                        [[self class] showSuccess:@"移除成功"];
                        self.data = nil;
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                    } else {
                        [[self class] showError:@"移除失败"];
                    }
                }];
            }];
        }
            break;
    }
}

- (void)addAndCacheMembersWithClientIds:(NSArray *)clientIds callback:(CYLBooleanResultBlock)callback {
    void(^addAndCacheCallback)(BOOL succeeded, NSError *error) = ^(BOOL succeeded, NSError *error) {
        !callback ?: callback(succeeded, error);
    };
    [self.conversation addMembersWithClientIds:clientIds callback:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [[CYLUserSystemService sharedInstance] cacheUsersWithIds:[NSSet setWithArray:clientIds] callback:^(BOOL succeeded, NSError *error) {
                addAndCacheCallback(succeeded, error);
            }];
        } else {
            addAndCacheCallback(succeeded, error);
        }
    }];
}

- (void)profileNameDidChanged:(NSString *)name {
    [[self class] showHUD];
    //FIXME:
//    [self.conversation setObject:name forKey:@"name"];
//    [self.conversation updateWithCallback:^(BOOL succeeded, NSError * _Nullable error) {
//        [[self class] hideHUD];
//        if (succeeded) {
//            [[self class] showSuccess:@"修改成功"];
//            self.data = nil;
//            [self.tableView reloadData];
//            [[CYLConversationService sharedInstance] removeCacheForConversationId:self.conversation.conversationId];
//        } else {
//            [[self class] showError:@"修改失败"];
//        }
//    }];
    
}


@end
