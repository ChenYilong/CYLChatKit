//
//  LCCKInvestCardInputViewPlugin.m
//  ChatKit-OC
//
//  Created by chenyilong on 23/6/2018.
//  Copyright © 2018 ElonChan. All rights reserved.
//

#import "LCCKInvestCardInputViewPlugin.h"
#import "AVIMInvestCardTypedMessage.h"

@implementation LCCKInvestCardInputViewPlugin
@synthesize inputViewRef = _inputViewRef;
@synthesize sendCustomMessageHandler = _sendCustomMessageHandler;

#pragma mark -
#pragma mark - Override Methods

#pragma mark -
#pragma mark - LCCKInputViewPluginSubclassing Method

+ (void)load {
    [self registerCustomInputViewPlugin];
}

+ (LCCKInputViewPluginType)classPluginType {
    return LCCKInputViewPluginTypeInvestCard;
}

#pragma mark -
#pragma mark - LCCKInputViewPluginDelegate Method

/**
 * 插件图标
 */
- (UIImage *)pluginIconImage {
    return [self imageInBundlePathForImageName:@"chat_bar_icons_location"];
}

/**
 * 插件名称
 */
- (NSString *)pluginTitle {
    return @"邀请";
}

/**
 * 插件对应的 view，会被加载到 inputView 上
 */
- (UIView *)pluginContentView {
    return nil;
}

/**
 * 插件被选中运行
 */
- (void)pluginDidClicked {
    [super pluginDidClicked];
    self.sendCustomMessageHandler(nil, nil);
}

/**
 * 发送自定消息的实现
 */
- (LCCKIdResultBlock)sendCustomMessageHandler {
    if (_sendCustomMessageHandler) {
        return _sendCustomMessageHandler;
    }
    if (!self.conversationViewController.isAvailable) {
        [self.conversationViewController sendLocalFeedbackTextMessge:@"邀请发送失败"];
        return nil;
    }
    LCCKIdResultBlock sendCustomMessageHandler = ^(id object, NSError *error) {
        AVIMInvestCardTypedMessage *messsage = [AVIMInvestCardTypedMessage investCardMessageWithImageURL:[NSURL URLWithString:@"https://hdl-emas-app-bucket.oss-cn-beijing.aliyuncs.com/invest_card-containsqrinfo-501-767.png"] conversationType:LCCKConversationTypeSingle];
        [self.conversationViewController sendCustomMessage:messsage progressBlock:^(NSInteger percentDone) {
        } success:^(BOOL succeeded, NSError *error) {
            [self.conversationViewController sendLocalFeedbackTextMessge:@"邀请发送成功"];
        } failed:^(BOOL succeeded, NSError *error) {
            [self.conversationViewController sendLocalFeedbackTextMessge:@"邀请发送失败"];
        }];
        [self.inputViewRef close];
        _sendCustomMessageHandler = nil;
    };
    _sendCustomMessageHandler = sendCustomMessageHandler;
    return sendCustomMessageHandler;
}

#pragma mark -
#pragma mark - Private Methods

- (UIImage *)imageInBundlePathForImageName:(NSString *)imageName {
    UIImage *image = [UIImage lcck_imageNamed:imageName bundleName:@"ChatKeyboard" bundleForClass:[self class]];
    return image;
}
//
//- (void)presentSelectMemberViewController {
//    AVIMConversation *conversation = [self.conversationViewController getConversationIfExists];
//    NSArray *allPersonIds;
//    if (conversation.lcck_type == LCCKConversationTypeGroup) {
//        allPersonIds = conversation.members;
//    } else {
//        allPersonIds = [[LCCKContactManager defaultManager] fetchContactPeerIds];
//    }
//    NSArray *users = [[LCChatKit sharedInstance] getCachedProfilesIfExists:allPersonIds shouldSameCount:YES error:nil];
//    NSString *currentClientID = [[LCChatKit sharedInstance] clientId];
//    LCCKContactListViewController *contactListViewController = [[LCCKContactListViewController alloc] initWithContacts:[NSSet setWithArray:users] userIds:[NSSet setWithArray:allPersonIds] excludedUserIds:[NSSet setWithArray:@[currentClientID]] mode:LCCKContactListModeSingleSelection];
//    contactListViewController.title = @"发送邀请";
//    [contactListViewController setViewDidDismissBlock:^(LCCKBaseViewController *viewController) {
//        [self.inputViewRef open];
//        [self.inputViewRef beginInputing];
//    }];
//    [contactListViewController setSelectedContactCallback:^(UIViewController *viewController, NSString *peerId) {
//        [viewController dismissViewControllerAnimated:YES completion:^{
//            [self.inputViewRef open];
//        }];
//        if (peerId.length > 0) {
//            !self.sendCustomMessageHandler ?: self.sendCustomMessageHandler(peerId, nil);
//        }
//    }];
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:contactListViewController];
//    [self.conversationViewController presentViewController:navigationController animated:YES completion:^{
//        [self.inputViewRef close];
//    }];
//}

@end

