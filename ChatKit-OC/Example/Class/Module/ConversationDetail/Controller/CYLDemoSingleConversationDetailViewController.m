//
//  CYLDemoSingleConversationDetailViewController.m
//  ChatKit-OC
//
//  Created by 陈宜龙 on 12/8/16.
//  Copyright © 2016 ElonChan. All rights reserved.
//

#import "CYLDemoSingleConversationDetailViewController.h"
#import <AVOSCloudIM/AVOSCloudIM.h>
#import "AVIMConversation+CYLDemoExtension.h"
#import "CYLDemoChatDetailHelper.h"
#import "CYLDemoUserGroupCell.h"
#import "CYLDemoUser.h"
#import "CYLTabBarController.h"
#import "CYLDemoContactManager.h"
#import "NSObject+CYLDemoHUD.h"

@interface CYLDemoSingleConversationDetailViewController ()<CYLDemoUserGroupCellDelegate>

@property (nonatomic, strong) CYLDemoChatDetailHelper *helper;
@property (nonatomic, strong) CYLDemoUser *user;

@end

@implementation CYLDemoSingleConversationDetailViewController
@synthesize data = _data;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"聊天详情"];
    
    self.helper = [[CYLDemoChatDetailHelper alloc] init];
    
    [self.tableView registerClass:[CYLDemoUserGroupCell class] forCellReuseIdentifier:@"CYLDemoUserGroupCell"];
}

- (CYLDemoUser *)user {
    if (_user) {
        return _user;
    }
    _user = [[CYLChatKit sharedInstance] getCachedProfilesIfExists:@[self.conversation.cyl_peerId] error:nil][0];
    return _user;
}

/**
 *  lazy load data
 *
 *  @return NSMutableArray
 */
- (NSMutableArray *)data {
    if (_data == nil) {
        _data = [self.helper chatDetailDataBySingleInfo:self.conversation];
    }
    return _data;
}

#pragma mark - Delegate -
//MARK: UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        CYLDemoUserGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CYLDemoUserGroupCell class])];
        [cell setUsers:[NSMutableArray arrayWithArray:@[self.user]]];
        [cell setDelegate:self];
        return cell;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

//MARK: UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CYLDemoSettingItem *item = [self.data[indexPath.section] objectAtIndex:indexPath.row];
    
    if ([item.title isEqualToString:@"聊天文件"]) {
        //        CYLDemoChatFileViewController *chatFileVC = [[CYLDemoChatFileViewController alloc] init];
        //        [chatFileVC setPartnerID:self.user.userID];
        //        [self setHidesBottomBarWhenPushed:YES];
        //        [self.navigationController pushViewController:chatFileVC animated:YES];
    }
    else if ([item.title isEqualToString:@"设置当前聊天背景"]) {
        [self presentViewController:self.pickerController animated:YES completion:nil];
        
        //        CYLDemoChatBackgroundSettingViewController *chatBGSettingVC = [[CYLDemoChatBackgroundSettingViewController alloc] init];
        //        [chatBGSettingVC setPartnerID:self.user.userID];
        //        [self setHidesBottomBarWhenPushed:YES];
        //        [self.navigationController pushViewController:chatBGSettingVC animated:YES];
    }
    else if ([item.title isEqualToString:@"清空聊天记录"]) {
        //        CYLDemoActionSheet *actionSheet = [[CYLDemoActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"清空聊天记录" otherButtonTitles: nil];
        //        actionSheet.tag = TAG_EMPTY_CHAT_REC;
        //        [actionSheet show];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        NSUInteger count = self.user ? 1 : 0;
        return ((count + 1) / 4 + ((((count + 1) % 4) == 0) ? 0 : 1)) * 90 + 15;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

//MARK: CYLDemoActionSheetDelegate
//- (void)actionSheet:(CYLDemoActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (actionSheet.tag == TAG_EMPTY_CHAT_REC) {
//        if (buttonIndex == 0) {
//            BOOL ok = [[CYLDemoMessageManager sharedInstance] deleteMessagesByPartnerID:self.user.userID];
//            if (!ok) {
//                [UIAlertView bk_alertViewWithTitle:@"错误" message:@"清空聊天记录失败"];
//            }
//            else {
//                [[CYLDemoChatViewController sharedChatVC] resetChatVC];
//            }
//        }
//    }
//}

#pragma mark -
#pragma mark - CYLDemoUserGroupCellDelegate Method

- (void)userGroupCellDidSelectUser:(CYLDemoUser *)user {
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
    NSString *currentClientID = [[CYLChatKit sharedInstance] clientId];
    switch (operationType) {
        case CYLDemoConversationOperationTypeNone:
            break;
        case CYLDemoConversationOperationTypeAdd: {
            NSArray *allPersonIds = [[CYLDemoContactManager defaultManager] fetchContactPeerIds];
            [self presentSelectMemberViewControllerMemberIds:allPersonIds excludedUserIds:self.conversation.members callback:^(NSArray *peerIds, NSError *error) {
                NSMutableArray *mutableArray = @[currentClientID, self.user.clientId].mutableCopy;;
                [mutableArray addObjectsFromArray:peerIds];
                NSArray *members = [mutableArray copy];
                [[CYLChatKit sharedInstance] createConversationWithMembers:members type:CYLConversationTypeGroup unique:YES callback:^(AVIMConversation * _Nullable conversation, NSError * _Nullable error) {
                    [[self class] hideHUD];
                    if (conversation) {
                        [[self class] showSuccess:@"创建对话成功"];
                        [self cyl_popSelectTabBarChildViewControllerAtIndex:0 completion:^(__kindof UIViewController *selectedTabBarChildViewController) {
                            CYLConversationViewController *conversationViewController = [[CYLConversationViewController alloc] initWithConversationId:conversation.conversationId];
                            [selectedTabBarChildViewController.navigationController pushViewController:conversationViewController animated:YES];
                        }];
                    } else {
                        [[self class] showError:@"创建对话失败"];
                    }
                }];
            }];
        }
            break;
        case CYLDemoConversationOperationTypeRemove:
            break;
    }
}



@end
