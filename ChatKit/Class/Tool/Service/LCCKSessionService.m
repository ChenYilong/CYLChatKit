//
//  LCCKSessionService.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/1.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "LCCKSessionService.h"

#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

NSString *const LCCKSessionServiceErrorDomain = @"LCCKSessionServiceErrorDomain";

@interface LCCKSessionService()

@property (nonatomic, assign, getter=isRequestingSingleSignOn) BOOL requestingSingleSignOn;

@end

@implementation LCCKSessionService
@synthesize forceReconnectSessionBlock = _forceReconnectSessionBlock;
@synthesize disableSingleSignOn = _disableSingleSignOn;

#pragma mark - IM provider

- (id<LCCKIMProvider>)IMProvider {
    id<LCCKIMProvider> IMProvider = [LCChatKit sharedInstance].IMProvider;
    if (!IMProvider) {
        LCCKLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"Set `-[LCChatKit setIMProvider:]` before using ChatKit.");
    }
    return IMProvider;
}

- (NSString *)clientId {
    return [self.IMProvider clientId];
}

- (id)client {
    id<LCCKIMProvider> IMProvider = self.IMProvider;
    if ([IMProvider respondsToSelector:@selector(client)]) {
        return [IMProvider client];
    }
    return nil;
}

- (BOOL)connect {
    return [self.IMProvider isConnected];
}

- (BOOL)isClientOpened {
    return [self.IMProvider isClientOpened];
}

#pragma mark - open and close

- (void)openWithClientId:(NSString *)clientId callback:(LCCKBooleanResultBlock)callback {
    [self openWithClientId:clientId force:YES callback:callback];
}

- (void)openWithClientId:(NSString *)clientId force:(BOOL)force callback:(LCCKBooleanResultBlock)callback {
    dispatch_async(dispatch_get_main_queue(),^{
        if ([clientId lcck_isSpace] || !clientId) {
            NSInteger code = 0;
            NSString *errorReasonText = @"clientId not valid";
            NSDictionary *errorInfo = @{
                                        @"code":@(code),
                                        NSLocalizedDescriptionKey : errorReasonText,
                                        };
            NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                                 code:code
                                             userInfo:errorInfo];
            !callback ?: callback(NO, error);
            return;
        }
        id<LCCKIMProvider> IMProvider = self.IMProvider;
        if (!IMProvider) {
            NSInteger code = 0;
            NSString *errorReasonText = @"IM provider not set. Set `-[LCChatKit setIMProvider:]` first.";
            NSDictionary *errorInfo = @{
                                        @"code":@(code),
                                        NSLocalizedDescriptionKey : errorReasonText,
                                        };
            NSError *error = [NSError errorWithDomain:LCCKSessionServiceErrorDomain
                                                 code:code
                                             userInfo:errorInfo];
            !callback ?: callback(NO, error);
            return;
        }
        [self openSevice];
        [IMProvider openWithClientId:clientId force:force callback:callback];
    });
}

- (void)closeWithCallback:(LCCKBooleanResultBlock)callback {
    [self.IMProvider closeWithCallback:^(BOOL succeeded, NSError *error) {
        !callback ?: callback(succeeded, error);
        if (succeeded) {
            [self resetService];
        }
    }];
}

- (void)openSevice {
    [LCCKConversationListService sharedInstance];
    [LCCKConversationService sharedInstance];
    [LCCKSessionService sharedInstance];
    [LCCKSettingService sharedInstance];
    [LCCKSignatureService sharedInstance];
    [LCCKUIService sharedInstance];
    [LCCKUserSystemService sharedInstance];
}

- (void)resetService {
    [LCCKSingleton destroyAllInstance];
}

#pragma mark - reconnect

- (void)setForceReconnectSessionBlock:(LCCKForceReconnectSessionBlock)forceReconnectSessionBlock {
    _forceReconnectSessionBlock = forceReconnectSessionBlock;
}

- (void)reconnectForViewController:(UIViewController *)viewController callback:(LCCKBooleanResultBlock)aCallback {
    [self reconnectForViewController:viewController error:nil granted:YES callback:aCallback];
}

- (void)reconnectForViewController:(UIViewController *)viewController error:(NSError *)aError granted:(BOOL)granted callback:(LCCKBooleanResultBlock)aCallback {
    LCCKForceReconnectSessionBlock forceReconnectSessionBlock = _forceReconnectSessionBlock;
    LCCKBooleanResultBlock completionHandler = ^(BOOL succeeded, NSError *error) {
        LCCKHUDActionBlock HUDActionBlock = [LCCKUIService sharedInstance].HUDActionBlock;
        !HUDActionBlock ?: HUDActionBlock(viewController, viewController.view, nil, LCCKMessageHUDActionTypeHide);
        if (succeeded) {
            !HUDActionBlock ?: HUDActionBlock(viewController, viewController.view, LCCKLocalizedStrings(@"connectSucceeded"), LCCKMessageHUDActionTypeSuccess);
        } else {
            !HUDActionBlock ?: HUDActionBlock(viewController, viewController.view, LCCKLocalizedStrings(@"connectFailed"), LCCKMessageHUDActionTypeError);
            LCCKLog(@"%@", error.description);
        }
        !aCallback ?: aCallback(succeeded, error);
    };
    !forceReconnectSessionBlock ?: forceReconnectSessionBlock(aError, granted, viewController, completionHandler);
}

#pragma mark - single sign-on

- (void)handleSingleSignOnError:(NSError *)aError callback:(LCCKBooleanResultBlock)aCallback {
    [self resetService];
    [self requestForceSingleSignOnAuthorizationWithCallback:^(BOOL granted, NSError *theError) {
        [self reconnectForViewController:nil error:aError granted:granted callback:aCallback];
    }];
}

- (void)requestForceSingleSignOnAuthorizationWithCallback:(LCCKRequestAuthorizationBoolResultBlock)callback {
    if (self.isRequestingSingleSignOn) {
        return;
    }
    self.requestingSingleSignOn = YES;
    NSString *title = LCCKLocalizedStrings(@"requestForceSingleSignOnAuthorization");
    LCCKAlertController *alert = [LCCKAlertController alertControllerWithTitle:title
                                                                       message:@""
                                                                preferredStyle:LCCKAlertControllerStyleAlert];
    NSString *cancelActionTitle = LCCKLocalizedStrings(@"cancel") ?: @"取消";
    LCCKAlertAction *cancelAction = [LCCKAlertAction actionWithTitle:cancelActionTitle style:LCCKAlertActionStyleDefault
                                                             handler:^(LCCKAlertAction * action) {
                                                                 NSInteger code = 0;
                                                                 NSString *errorReasonText = @"request force single sign on failed";
                                                                 NSDictionary *errorInfo = @{
                                                                                             @"code":@(code),
                                                                                             NSLocalizedDescriptionKey : errorReasonText,
                                                                                             };
                                                                 NSError *error = [NSError errorWithDomain:LCCKSessionServiceErrorDomain
                                                                                                      code:code
                                                                                                  userInfo:errorInfo];
                                                                 !callback ?: callback(NO, error);
                                                                 self.requestingSingleSignOn = NO;
                                                             }];
    [alert addAction:cancelAction];

    NSString *forceOpenActionTitle = LCCKLocalizedStrings(@"ok") ?: @"确认";
    LCCKAlertAction *forceOpenAction = [LCCKAlertAction actionWithTitle:forceOpenActionTitle style:LCCKAlertActionStyleDefault
                                                                handler:^(LCCKAlertAction * action) {
                                                                    !callback ?: callback(YES, nil);
                                                                    self.requestingSingleSignOn = NO;
                                                                }];
    [alert addAction:forceOpenAction];
    [alert showWithSender:nil controller:nil animated:YES completion:NULL];
}

@end
