//
//  CYLDemoChatKitExample.m
//  LeanCloudChatKit-iOS
//
//  Created by ElonChan on 16/2/24.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//
#if __has_include(<ChatKit/CYLChatKit.h>)
#import <ChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif
#import "CYLDemoChatKitExample.h"
#import "CYLDemoUtil.h"
#import "NSObject+CYLDemoHUD.h"
#import "CYLDemoTabBarControllerConfig.h"
#import "CYLDemoUser.h"
#import "MWPhotoBrowser.h"
#import <objc/runtime.h>
#import <AVOSCloud/AVOSCloud.h>
#import <AVOSCloudIM/AVOSCloudIM.h>
#import "CYLDemoLeanCloudIMProvider.h"
#import "AVIMConversation+CYLDemoExtension.h"

//==================================================================================================================================
//If you want to see the storage of this demo, log in public account of leancloud.cn, search for the app named `LeanCloudChatKit-iOS`.
//======================================== username : leancloud@163.com , password : Public123 =====================================
//==================================================================================================================================

#warning TODO: CHANGE TO YOUR AppId and AppKey

static NSString *const CYLDemoAPPID = @"dYRQ8YfHRiILshUnfFJu2eQM-gzGzoHsz";
static NSString *const CYLDemoAPPKEY = @"ye24iIK6ys8IvaISMC4Bs5WK";

// Dictionary that holds all instances of Singleton include subclasses
static NSMutableDictionary *_sharedInstances = nil;

@interface CYLDemoChatKitExample () <MWPhotoBrowserDelegate>

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *selections;

@end

@implementation CYLDemoChatKitExample

#pragma mark - SDK Life Control

+ (void)invokeThisMethodInDidFinishLaunching {
    [AVOSCloud registerForRemoteNotification];
    //    [AVOSCloud setStorageType:AVStorageTypeQCloud];
    [AVIMClient setTimeoutIntervalInSeconds:20];
    [[self sharedInstance] exampleInit];
}

+ (void)invokeThisMethodInDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [AVOSCloud handleRemoteNotificationsWithDeviceToken:deviceToken];
}

+ (void)invokeThisMethodBeforeLogoutSuccess:(CYLVoidBlock)success failed:(CYLErrorBlock)failed {
    //    [AVOSCloudIM handleRemoteNotificationsWithDeviceToken:nil];
    [[CYLChatKit sharedInstance] removeAllCachedProfiles];
    [[CYLChatKit sharedInstance] removeAllCachedRecentConversations];
    [[CYLChatKit sharedInstance] closeWithCallback:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [CYLDemoUtil showNotificationWithTitle:@"退出成功" subtitle:nil type:CYLMessageNotificationTypeSuccess];
            !success ?: success();
        } else {
            [CYLDemoUtil showNotificationWithTitle:@"退出失败" subtitle:nil type:CYLMessageNotificationTypeError];
            !failed ?: failed(error);
        }
    }];
}

+ (void)invokeThisMethodAfterLoginSuccessWithClientId:(NSString *)clientId success:(CYLVoidBlock)success failed:(CYLErrorBlock)failed  {
    [[CYLChatKit sharedInstance] openWithClientId:clientId callback:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSString *subtitle = [NSString stringWithFormat:@"User Id 是 : %@", clientId];
            [CYLDemoUtil showNotificationWithTitle:@"登陆成功" subtitle:subtitle type:CYLMessageNotificationTypeSuccess];
            !success ?: success();
        } else {
            [CYLDemoUtil showNotificationWithTitle:@"登陆失败" subtitle:nil type:CYLMessageNotificationTypeError];
            !failed ?: failed(error);
        }
    }];
    //TODO:
}

+ (void)invokeThisMethodInApplication:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (application.applicationState == UIApplicationStateActive) {
        // 应用在前台时收到推送，只能来自于普通的推送，而非离线消息推送
    }
    else {
        //  当使用 https://github.com/leancloud/leanchat-cloudcode 云代码更改推送内容的时候
        //        {
        //            aps =     {
        //                alert = "lcckkit : sdfsdf";
        //                badge = 4;
        //                sound = default;
        //            };
        //            convid = 55bae86300b0efdcbe3e742e;
        //        }
        [[CYLChatKit sharedInstance] didReceiveRemoteNotification:userInfo];
    }
}

+ (void)invokeThisMethodInApplicationWillResignActive:(UIApplication *)application {
    [[CYLChatKit sharedInstance] syncBadge];
}

+ (void)invokeThisMethodInApplicationWillTerminate:(UIApplication *)application {
    [[CYLChatKit sharedInstance] syncBadge];
}

#pragma -
#pragma mark - init Method

/**
 *  初始化的示例代码
 */
- (void)exampleInit {
#ifndef __OPTIMIZE__
//    [CYLChatKit setAllLogsEnabled:YES];
#endif
    // ChatKit is UI only. Plug in the LeanCloud IM backend before starting ChatKit.
    [CYLChatKit sharedInstance].IMProvider = [[CYLDemoLeanCloudIMProvider alloc] init];
    [CYLChatKit setAppId:CYLDemoAPPID appKey:CYLDemoAPPKEY];
    [[CYLChatKit sharedInstance] setFetchProfilesBlock:^(NSArray<NSString *> *userIds, CYLDemoFetchProfilesCallBack callback) {
        if (userIds.count == 0) {
            NSInteger code = 0;
            NSString *errorReasonText = @"User ids is nil";
            NSDictionary *errorInfo = @{
                                        @"code":@(code),
                                        NSLocalizedDescriptionKey : errorReasonText,
                                        };
            NSError *error = [NSError errorWithDomain:@"CYLChatKit"
                                                 code:code
                                             userInfo:errorInfo];
            !callback ?: callback(nil, error);
            return;
        }
        
        NSMutableArray *users = [NSMutableArray arrayWithCapacity:userIds.count];;
        for (NSDictionary *user in CYLDemoContactProfiles) {
            if ([userIds containsObject:user[CYLDemoProfileKeyPeerId]]) {
                NSURL *avatorURL = [NSURL URLWithString:user[CYLDemoProfileKeyAvatarURL]];
                CYLDemoUser *user_ = [[CYLDemoUser alloc] initWithUserId:user[CYLDemoProfileKeyPeerId] name:user[CYLDemoProfileKeyName] avatorURL:avatorURL];
                [users addObject:user_];
            }
        }
        !callback ?: callback([users copy], nil);
    }];
    
    [[CYLChatKit sharedInstance] setDidSelectItemBlock:^(NSIndexPath *indexPath, id<CYLConversationProtocol> conversation, CYLConversationListViewController *controller) {
        [[self class] exampleOpenConversationViewControllerWithConversaionId:conversation.conversationId fromNavigationController:nil];
    }];
    
    [[CYLChatKit sharedInstance] setPreviewImageMessageBlock:^(NSUInteger index, NSArray *allVisibleImages, NSArray *allVisibleThumbs, NSDictionary *userInfo) {
        [self examplePreviewImageMessageWithIndex:index allVisibleImages:allVisibleImages allVisibleThumbs:allVisibleThumbs];
    }];
    
    [[CYLChatKit sharedInstance] setLongPressMessageBlock:^NSArray<UIMenuItem *> *(CYLMessage *message, NSDictionary *userInfo) {
        CYLMenuItem *copyItem = [[CYLMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"copy", @"LCChatKitString", @"复制文本消息")
                                                               block:^{
                                                                   UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                                                   [pasteboard setString:[message text]];
                                                               }];
        NSArray *menuItems = [NSArray array];
        if (message.messageMediaType ==  CYLDemoMessageTypeText) {
            menuItems = @[ copyItem ];
        }
        return menuItems;
    }];
    
    //    [[CYLChatKit sharedInstance] setDidDeleteItemBlock:^(NSIndexPath *indexPath, id<CYLConversationProtocol> conversation, CYLConversationListViewController *controller) {
    //        //TODO:
    //    }];
    
    [[CYLChatKit sharedInstance] setOpenProfileBlock:^(NSString *userId, UIViewController *parentController) {
        [self exampleOpenProfileForUserId:userId];
    }];
    
    [[CYLChatKit sharedInstance] setAvatarImageViewCornerRadiusBlock:^CGFloat(CGSize avatarImageViewSize) {
        if (avatarImageViewSize.height > 0) {
            return avatarImageViewSize.height/2;
        }
        return 5;
    }];
    
    [[CYLChatKit sharedInstance] setShowNotificationBlock:^(UIViewController *viewController, NSString *title, NSString *subtitle, CYLMessageNotificationType type) {
        [self exampleShowNotificationWithTitle:title subtitle:subtitle type:type];
    }];
    
    // 自定义Cell菜单
    [[CYLChatKit sharedInstance] setConversationEditActionBlock:^NSArray *(NSIndexPath *indexPath, NSArray<UITableViewRowAction *> *editActions, id<CYLConversationProtocol> conversation, CYLConversationListViewController *controller) {
        return [self exampleConversationEditActionAtIndexPath:indexPath conversation:conversation controller:controller];
    }];
    
    [[CYLChatKit sharedInstance] setMarkBadgeWithTotalUnreadCountBlock:^(NSInteger totalUnreadCount, UIViewController *controller) {
        [self exampleMarkBadgeWithTotalUnreadCount:totalUnreadCount controller:controller];
    }];
    
    [[CYLChatKit sharedInstance] setPreviewLocationMessageBlock:^(CLLocation *location, NSString *geolocations, NSDictionary *userInfo) {
        [self examplePreViewLocationMessageWithLocation:location geolocations:geolocations];
    }];
    
    [[CYLChatKit sharedInstance] setSessionNotOpenedHandler:^(UIViewController *viewController, CYLBooleanResultBlock callback) {
        [[self class] showMessage:@"正在重新连接聊天服务..." toView:viewController.view];
        [[CYLChatKit sharedInstance] openWithClientId:[CYLChatKit sharedInstance].clientId callback:^(BOOL succeeded, NSError *error) {
            [[self class] hideHUDForView:viewController.view];
            if (succeeded) {
                [[self class] showSuccess:@"连接成功"];
                callback(succeeded, nil);
            } else {
                [[self class] showError:@"连接失败"];
                callback(succeeded, error);
            }
        }];
    }];
}

- (NSArray *)exampleConversationEditActionAtIndexPath:(NSIndexPath *)indexPath
                                         conversation:(id<CYLConversationProtocol>)conversation
                                           controller:(CYLConversationListViewController *)controller {
    // 如果需要自定义其他会话的菜单，在此编辑
    return [self rightButtonsAtIndexPath:indexPath conversation:conversation controller:controller];
}

typedef void (^UITableViewRowActionHandler)(UITableViewRowAction *action, NSIndexPath *indexPath);

- (void)markReadStatusAtIndexPath:(NSIndexPath *)indexPath
                            title:(NSString **)title
                           handle:(UITableViewRowActionHandler *)handler
                     conversation:(id<CYLConversationProtocol>)conversation
                       controller:(CYLConversationListViewController *)controller {
    if (conversation.cyl_unreadCount > 0) {
        if (*title == nil) {
            *title = @"标记为已读";
        }
        *handler = ^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [controller.tableView setEditing:NO animated:YES];
            [[CYLChatKit sharedInstance] updateUnreadCountToZeroWithConversation:conversation];
            [controller refresh];
        };
    } else {
        if (*title == nil) {
            *title = @"标记为未读";
        }
        *handler = ^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [controller.tableView setEditing:NO animated:YES];
            [[CYLChatKit sharedInstance] increaseUnreadCountWithConversation:conversation];
            [controller refresh];
        };
    }
}

- (NSArray *)rightButtonsAtIndexPath:(NSIndexPath *)indexPath
                        conversation:(id<CYLConversationProtocol>)conversation
                          controller:(CYLConversationListViewController *)controller {
    NSString *title = nil;
    UITableViewRowActionHandler handler = nil;
    [self markReadStatusAtIndexPath:indexPath
                              title:&title
                             handle:&handler
                       conversation:conversation
                         controller:controller];
    UITableViewRowAction *actionItemMore = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                              title:title
                                                                            handler:handler];
    
    actionItemMore.backgroundColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0];
    
    UITableViewRowAction *actionItemDelete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                                title:@"Delete"
                                                                              handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                                                  [[CYLChatKit sharedInstance] deleteRecentConversation:conversation];
                                                                                  [controller refresh];
                                                                              }];
    return @[ actionItemDelete, actionItemMore ];
}

#pragma -
#pragma mark - Other Method

/**
 *  打开单聊页面
 */
+ (void)exampleOpenConversationViewControllerWithPeerId:(NSString *)peerId fromNavigationController:(UINavigationController *)navigationController {
    CYLConversationViewController *conversationViewController = [[CYLConversationViewController alloc] initWithPeerId:peerId];
    [conversationViewController setViewDidLoadBlock:^(CYLChatBaseViewController *viewController) {
        [self showMessage:@"加载历史记录..."];
        [viewController configureBarButtonItemStyle:CYLBarButtonItemStyleSingleProfile action:^{
            NSString *title = @"打开用户详情";
            NSString *subTitle = [NSString stringWithFormat:@"用户id：%@", peerId];
            [CYLDemoUtil showNotificationWithTitle:title subtitle:subTitle type:CYLMessageNotificationTypeMessage];
        }];
    }];
    [conversationViewController setConversationHandler:^(id<CYLConversationProtocol> conversation, CYLConversationViewController *aConversationController) {
        if (!conversation) {
            [aConversationController.navigationController popViewControllerAnimated:YES];
            return;
        }
    }];
    [conversationViewController setLoadHistoryMessagesHandler:^(BOOL succeeded, NSError *error) {
        [self hideHUD];
        NSString *title;
        CYLMessageNotificationType type;
        if (succeeded) {
            title = @"聊天记录加载成功";
            type = CYLMessageNotificationTypeSuccess;
        } else {
            title = @"聊天记录加载失败";
            type = CYLMessageNotificationTypeError;
        }
        [CYLDemoUtil showNotificationWithTitle:title subtitle:nil type:type];
    }];
    [self pushToViewController:conversationViewController];
}

+ (void)exampleOpenConversationViewControllerWithConversaionId:(NSString *)conversationId fromNavigationController:(UINavigationController *)aNavigationController {
    CYLConversationViewController *conversationViewController = [[CYLConversationViewController alloc] initWithConversationId:conversationId];
    [conversationViewController setConversationHandler:^(id<CYLConversationProtocol> conversation, CYLConversationViewController *aConversationController) {
        if (!conversation) {
            [aConversationController.navigationController popViewControllerAnimated:YES];
            return;
        }
        if (conversation.members.count > 2) {
            [aConversationController configureBarButtonItemStyle:CYLBarButtonItemStyleGroupProfile action:^{
                NSString *title = @"打开群聊详情";
                NSString *subTitle = [NSString stringWithFormat:@"群聊id：%@", conversationId];
                [CYLDemoUtil showNotificationWithTitle:title subtitle:subTitle type:CYLMessageNotificationTypeMessage];
            }];
        } else {
            [aConversationController configureBarButtonItemStyle:CYLBarButtonItemStyleSingleProfile action:^{
                NSString *title = @"打开用户详情";
                
                NSArray *members = conversation.members;
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", @[ conversation.clientId ]];
                NSString *peerId = [members filteredArrayUsingPredicate:predicate][0];

                NSString *subTitle = [NSString stringWithFormat:@"用户id：%@", peerId];
                [CYLDemoUtil showNotificationWithTitle:title subtitle:subTitle type:CYLMessageNotificationTypeMessage];
            }];
        }
        
        if (conversation.members.count > 2 && (![conversation.members containsObject:[CYLChatKit sharedInstance].clientId])) {
            [self showMessage:@"正在加入聊天室..."];
            [conversation joinWithCallback:^(BOOL succeeded, NSError *error) {
                [self hideHUD];
                NSString *title;
                NSString *subtitle;
                CYLMessageNotificationType type;
                if (error) {
                    title = @"加入聊天室失败";
                    subtitle = error.localizedDescription;
                    type = CYLMessageNotificationTypeError;
                    [aConversationController.navigationController popViewControllerAnimated:YES];
                } else {
                    title = @"加入聊天室";
                    type = CYLMessageNotificationTypeSuccess;
                }
                [CYLDemoUtil showNotificationWithTitle:title subtitle:subtitle type:type];
            }];
        }
    }];
    
    [conversationViewController setViewDidLoadBlock:^(CYLChatBaseViewController *viewController) {
        [self showMessage:@"加载历史记录..."];
    }];
    [conversationViewController setLoadHistoryMessagesHandler:^(BOOL succeeded, NSError *error) {
        [self hideHUD];
        NSString *title;
        CYLMessageNotificationType type;
        if (succeeded) {
            title = @"聊天记录加载成功";
            type = CYLMessageNotificationTypeSuccess;
        } else {
            title = @"聊天记录加载失败";
            type = CYLMessageNotificationTypeError;
        }
        [CYLDemoUtil showNotificationWithTitle:title subtitle:nil type:type];
    }];
    
    [conversationViewController setViewWillDisappearBlock:^(CYLChatBaseViewController *viewController, BOOL aAnimated) {
        [self hideHUD];
    }];
    [self pushToViewController:conversationViewController];
}

+ (void)pushToViewController:(UIViewController *)viewController {
    UITabBarController *tabBarController = [self cyl_tabBarController];
    UINavigationController *navigationController = tabBarController.selectedViewController;
    [navigationController cyl_popSelectTabBarChildViewControllerAtIndex:0
                                                             completion:^(__kindof UIViewController *selectedChildTabBarController) {
                                                                 [selectedChildTabBarController.navigationController pushViewController:viewController animated:YES];
                                                             }];
}

- (void)exampleMarkBadgeWithTotalUnreadCount:(NSInteger)totalUnreadCount controller:(UIViewController *)controller {
    if (totalUnreadCount > 0) {
        [controller tabBarItem].badgeValue = [NSString stringWithFormat:@"%ld", (long)totalUnreadCount];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:totalUnreadCount];
    } else {
        [controller tabBarItem].badgeValue = nil;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
}

- (void)examplePreViewLocationMessageWithLocation:(CLLocation *)location geolocations:(NSString *)geolocations {
    NSString *title = [NSString stringWithFormat:@"打开地理位置：%@", geolocations];
    NSString *subTitle = [NSString stringWithFormat:@"纬度：%@\n经度：%@",@(location.coordinate.latitude), @(location.coordinate.longitude)];
    [CYLDemoUtil showNotificationWithTitle:title subtitle:subTitle type:CYLMessageNotificationTypeMessage];
}

- (void)examplePreviewImageMessageWithIndex:(NSUInteger)index allVisibleImages:(NSArray *)allVisibleImages allVisibleThumbs:(NSArray *)allVisibleThumbs {
    // Browser
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:[allVisibleImages count]];
    NSMutableArray *thumbs = [[NSMutableArray alloc] initWithCapacity:[allVisibleThumbs count]];
    MWPhoto *photo;
    MWPhoto *thumb;
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
    BOOL autoPlayOnAppear = NO;
    for (NSUInteger index = 0; index < allVisibleImages.count; index++) {
        id image_ = allVisibleImages[index];
        if ([image_ isKindOfClass:[UIImage class]]) {
            photo = [MWPhoto photoWithImage:image_];
        } else {
            photo = [MWPhoto photoWithURL:image_];
        }
        [photos addObject:photo];
        
        id thumb_ = allVisibleThumbs[index];
        if ([thumb_ isKindOfClass:[UIImage class]]) {
            thumb = [MWPhoto photoWithImage:thumb_];
        } else {
            thumb = [MWPhoto photoWithURL:thumb_];
        }
        [thumbs addObject:thumb];
    }
    // Options
    startOnGrid = NO;
    displayNavArrows = YES;
    self.photos = photos;
    self.thumbs = thumbs;
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = NO;
    browser.autoPlayOnAppear = autoPlayOnAppear;
    [browser setCurrentPhotoIndex:index];
    // Reset selections
    if (displaySelectionButtons) {
        _selections = [[NSMutableArray alloc] initWithCapacity:[allVisibleImages count]];;
        for (int i = 0; i < photos.count; i++) {
            [_selections addObject:[NSNumber numberWithBool:NO]];
        }
    }
    [[self class] pushToViewController:browser];
}

- (void)exampleOpenProfileForUserId:(NSString *)userId {
    NSString *subtitle = [NSString stringWithFormat:@"User Id 是 : %@", userId];
    [CYLDemoUtil showNotificationWithTitle:@"打开用户主页" subtitle:subtitle type:CYLMessageNotificationTypeMessage];
}

- (void)exampleShowNotificationWithTitle:(NSString *)title subtitle:(NSString *)subtitle type:(CYLMessageNotificationType)type {
    [CYLDemoUtil showNotificationWithTitle:title subtitle:subtitle type:type];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
}

@end
