//
//  CYLDemoChatKitExample.m
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/24.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//

#import "CYLDemoTabBarControllerConfig.h"
#import "CYLDemoUser.h"
#import "CYLDemoUtil.h"
#import "CYLDemoChatKitExample.h"

#import "NSObject+CYLDemoHUD.h"
#import <objc/runtime.h>
#if __has_include(<ChatKit/CYLChatKit.h>)
#import <ChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif
#import "CYLDemoContactManager.h"
#import "CYLDemoExampleConstants.h"
#import "CYLDemoLoginViewController.h"
#import "CYLDemoChatKitExample+Setting.h"


@interface CYLDemoChatKitExample ()

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *selections;

@end

@implementation CYLDemoChatKitExample

#pragma mark - SDK Life Control

+ (void)invokeThisMethodBeforeLogoutSuccess:(CYLVoidBlock)success failed:(CYLErrorBlock)failed {
    //    [AVOSCloudIM handleRemoteNotificationsWithDeviceToken:nil];
    [[CYLChatKit sharedInstance] removeAllCachedProfiles];
    [[CYLChatKit sharedInstance] closeWithCallback:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self cyl_demo_clearLocalClientInfo];
            [CYLDemoUtil showNotificationWithTitle:@"退出成功"
                                       subtitle:nil
                                           type:CYLMessageNotificationTypeSuccess];
            !success ?: success();
        } else {
            [CYLDemoUtil showNotificationWithTitle:@"退出失败"
                                       subtitle:nil
                                           type:CYLMessageNotificationTypeError];
            !failed ?: failed(error);
        }
    }];
}

+ (void)invokeThisMethodAfterLoginSuccessWithClientId:(NSString *)clientId
                                              success:(CYLVoidBlock)success
                                               failed:(CYLErrorBlock)failed {
    [[self sharedInstance] exampleInit];
    [[CYLChatKit sharedInstance] openWithClientId:clientId
                                        callback:^(BOOL succeeded, NSError *error) {
                                            if (succeeded) {
                                                [self saveLocalClientInfo:clientId];
                                                !success ?: success();
                                            } else {
                                                [CYLDemoUtil showNotificationWithTitle:@"登陆失败"
                                                                           subtitle:nil
                                                                               type:CYLMessageNotificationTypeError];
                                                !failed ?: failed(error);
                                            }
                                        }];
    // TODO:
}

+ (void)invokeThisMethodInApplication:(UIApplication *)application
         didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (application.applicationState == UIApplicationStateActive) {
        // 应用在前台时收到推送，只能来自于普通的推送，而非离线消息推送
    } else {
        /*!
         *  当使用 https://github.com/leancloud/leanchat-cloudcode 云代码更改推送内容的时候
         {
         aps = {
                alert = "lcckkit : sdfsdf";
                badge = 4;
                sound = default;
            };
          convid = 55bae86300b0efdcbe3e742e;
         }
         */
        [[CYLChatKit sharedInstance] didReceiveRemoteNotification:userInfo];
    }
}

#pragma -
#pragma mark - init Method

/**
 *  初始化的示例代码
 */
- (void)exampleInit {
    [self cyl_demo_setting];
}

#pragma -
#pragma mark - Other Method

+ (void)exampleChangeGroupAvatarURLsForConversationId:(NSString *)conversationId {
    [self cyl_demo_exampleChangeGroupAvatarURLsForConversationId:conversationId shouldInsert:YES];
}

+ (void)exampleCreateGroupConversationFromViewController:(UIViewController *)fromViewController {
    // FIXME: add more to allPersonIds
    NSArray *allPersonIds = [[CYLDemoContactManager defaultManager] fetchContactPeerIds];
    NSArray *users = [[CYLChatKit sharedInstance] getCachedProfilesIfExists:allPersonIds
                                                           shouldSameCount:YES
                                                                     error:nil];
    NSString *currentClientID = [[CYLChatKit sharedInstance] clientId];
    CYLContactListViewController *contactListViewController =
    [[CYLContactListViewController alloc]
     initWithContacts:[NSSet setWithArray:users]
     userIds:[NSSet setWithArray:allPersonIds]
     excludedUserIds:[NSSet setWithArray:@[ currentClientID ]]
     mode:CYLContactListModeMultipleSelection];
    contactListViewController.title = @"创建群聊";
    [contactListViewController setSelectedContactsCallback:^(UIViewController *viewController,
                                                             NSArray<NSString *> *peerIds) {
        if (!peerIds || peerIds.count == 0) {
            return;
        }
        [self showMessage:@"创建群聊..." toView:fromViewController.view];
        [[CYLChatKit sharedInstance]
         createConversationWithMembers:peerIds
         type:CYLConversationTypeGroup
         unique:YES
         callback:^(id<CYLConversationProtocol> conversation, NSError *error) {
             [self hideHUDForView:fromViewController.view];
             if (conversation) {
                 [self showSuccess:@"创建成功"
                                 toView:fromViewController.view];
                 [self
                  exampleOpenConversationViewControllerWithConversaionId:
                  conversation.conversationId
                  fromNavigationController:
                  viewController
                  .navigationController];
             } else {
                 [self showError:@"创建失败"
                               toView:fromViewController.view];
             }
         }];
    }];
    UINavigationController *navigationViewController =
    [[UINavigationController alloc] initWithRootViewController:contactListViewController];
    [fromViewController presentViewController:navigationViewController animated:YES completion:nil];
}

/**
 *  打开单聊页面
 */
+ (void)exampleOpenConversationViewControllerWithPeerId:(NSString *)peerId
                               fromNavigationController:(UINavigationController *)navigationControlle {

    CYLConversationViewController *conversationViewController =
    [[CYLConversationViewController alloc] initWithPeerId:peerId];
    [conversationViewController
     setViewWillDisappearBlock:^(CYLChatBaseViewController *viewController, BOOL aAnimated) {
         [self hideHUDForView:viewController.view];
     }];
    [self cyl_demo_pushToViewController:conversationViewController];
}

+ (void)exampleOpenConversationViewControllerWithConversaionId:(NSString *)conversationId
                                      fromNavigationController:
(UINavigationController *)aNavigationController {
    CYLConversationViewController *conversationViewController =
    [[CYLConversationViewController alloc] initWithConversationId:conversationId];
    conversationViewController.enableAutoJoin = YES;
    [conversationViewController
     setViewWillDisappearBlock:^(CYLChatBaseViewController *viewController, BOOL aAnimated) {
         [self hideHUDForView:viewController.view];
     }];
    [conversationViewController
     setViewWillAppearBlock:^(CYLChatBaseViewController *viewController, BOOL aAnimated) {
         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
                                                     animated:aAnimated];
     }];
    
    [self cyl_demo_pushToViewController:conversationViewController];
}

+ (void)signOutFromViewController:(UIViewController *)viewController {
    [CYLDemoUtil showProgressText:@"close client ..." duration:10.0f];
    [CYLDemoChatKitExample invokeThisMethodBeforeLogoutSuccess:^{
        [CYLDemoUtil hideProgress];
        CYLDemoLoginViewController *loginViewController = [[CYLDemoLoginViewController alloc] init];
        [loginViewController setClientIDHandler:^(NSString *clientID) {
            [CYLDemoChatKitExample invokeThisMethodAfterLoginSuccessWithClientId:clientID
                                                                    success:^{
                                                                        CYLDemoTabBarControllerConfig *tabBarControllerConfig =
                                                                        [[CYLDemoTabBarControllerConfig alloc] init];
                                                                        [self cyl_tabBarController].rootWindow.rootViewController =
                                                                        tabBarControllerConfig.tabBarController;
                                                                    }
                                                                     failed:^(NSError *error) {
                                                                         CYLLog(@"%@", error);
                                                                     }];
        }];
        [viewController presentViewController:loginViewController animated:YES completion:nil];
    }
                                                   failed:^(NSError *error) {
                                                       [CYLDemoUtil hideProgress];
                                                       CYLLog(@"%@", error);
                                                   }];
}

- (void)exampleOpenProfileForUser:(id<CYLUserDelegate>)user
                           userId:(NSString *)userId
                 parentController:(__kindof UIViewController *)parentController {
    NSString *currentClientId = [CYLChatKit sharedInstance].clientId;
    NSString *title = [NSString stringWithFormat:@"打开用户主页 \nClientId是 : %@", userId];
    NSString *subtitle = [NSString stringWithFormat:@"name是 : %@", user.name];
    if ([userId isEqualToString:currentClientId]) {
        title = [NSString stringWithFormat:@"打开自己的主页 \nClientId是 : %@", userId];
        subtitle = [NSString stringWithFormat:@"我自己的name是 : %@", user.name];
    
    } else if ([parentController isKindOfClass:[CYLConversationViewController class]]) {
        CYLConversationViewController *conversationViewController_ =
        [[CYLConversationViewController alloc] initWithPeerId:user.clientId ?: userId];
        [[self class] cyl_demo_pushToViewController:conversationViewController_];
        return;
    }
    [CYLDemoUtil showNotificationWithTitle:title
                               subtitle:subtitle
                                   type:CYLMessageNotificationTypeMessage];
}

#pragma mark -
#pragma mark - Private Methods

/**
 * create a singleton instance of CYLDemoChatKitExample
 */
+ (instancetype)sharedInstance {
    static CYLDemoChatKitExample *_sharedCYLDemoChatKitExample = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCYLDemoChatKitExample = [[self alloc] init];
    });
    return _sharedCYLDemoChatKitExample;
}

+ (void)saveLocalClientInfo:(NSString *)clientId {
    // 在系统偏好保存信息
    NSUserDefaults *defaultsSet = [NSUserDefaults standardUserDefaults];
    [defaultsSet setObject:clientId forKey:CYLDEMO_KEY_USERID];
    [defaultsSet synchronize];
    NSString *subtitle = [NSString stringWithFormat:@"User Id 是 : %@", clientId];
    [CYLDemoUtil showNotificationWithTitle:@"登陆成功"
                               subtitle:subtitle
                                   type:CYLMessageNotificationTypeSuccess];
}

@end
