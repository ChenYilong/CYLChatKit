//
//  CYLSessionService.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/1.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "CYLSessionService.h"

#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

NSString *const CYLSessionServiceErrorDomain = @"CYLSessionServiceErrorDomain";

@interface CYLSessionService()

@property (nonatomic, assign, getter=isRequestingSingleSignOn) BOOL requestingSingleSignOn;

@end

@implementation CYLSessionService
@synthesize forceReconnectSessionBlock = _forceReconnectSessionBlock;
@synthesize disableSingleSignOn = _disableSingleSignOn;

#pragma mark - IM provider

- (id<CYLIMProvider>)IMProvider {
    id<CYLIMProvider> IMProvider = [LCChatKit sharedInstance].IMProvider;
    if (!IMProvider) {
        CYLLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"Set `-[LCChatKit setIMProvider:]` before using ChatKit.");
    }
    return IMProvider;
}

- (NSString *)clientId {
    return [self.IMProvider clientId];
}

- (id)client {
    id<CYLIMProvider> IMProvider = self.IMProvider;
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

- (void)openWithClientId:(NSString *)clientId callback:(CYLBooleanResultBlock)callback {
    [self openWithClientId:clientId force:YES callback:callback];
}

- (void)openWithClientId:(NSString *)clientId force:(BOOL)force callback:(CYLBooleanResultBlock)callback {
    dispatch_async(dispatch_get_main_queue(),^{
        if ([clientId cyl_isSpace] || !clientId) {
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
        id<CYLIMProvider> IMProvider = self.IMProvider;
        if (!IMProvider) {
            NSInteger code = 0;
            NSString *errorReasonText = @"IM provider not set. Set `-[LCChatKit setIMProvider:]` first.";
            NSDictionary *errorInfo = @{
                                        @"code":@(code),
                                        NSLocalizedDescriptionKey : errorReasonText,
                                        };
            NSError *error = [NSError errorWithDomain:CYLSessionServiceErrorDomain
                                                 code:code
                                             userInfo:errorInfo];
            !callback ?: callback(NO, error);
            return;
        }
        [self openSevice];
        [IMProvider openWithClientId:clientId force:force callback:callback];
    });
}

- (void)closeWithCallback:(CYLBooleanResultBlock)callback {
    [self.IMProvider closeWithCallback:^(BOOL succeeded, NSError *error) {
        !callback ?: callback(succeeded, error);
        if (succeeded) {
            [self resetService];
        }
    }];
}

- (void)openSevice {
    [CYLConversationListService sharedInstance];
    [CYLConversationService sharedInstance];
    [CYLSessionService sharedInstance];
    [CYLSettingService sharedInstance];
    [CYLSignatureService sharedInstance];
    [CYLUIService sharedInstance];
    [CYLUserSystemService sharedInstance];
}

- (void)resetService {
    [CYLSingleton destroyAllInstance];
}

#pragma mark - reconnect

- (void)setForceReconnectSessionBlock:(CYLForceReconnectSessionBlock)forceReconnectSessionBlock {
    _forceReconnectSessionBlock = forceReconnectSessionBlock;
}

- (void)reconnectForViewController:(UIViewController *)viewController callback:(CYLBooleanResultBlock)aCallback {
    [self reconnectForViewController:viewController error:nil granted:YES callback:aCallback];
}

- (void)reconnectForViewController:(UIViewController *)viewController error:(NSError *)aError granted:(BOOL)granted callback:(CYLBooleanResultBlock)aCallback {
    CYLForceReconnectSessionBlock forceReconnectSessionBlock = _forceReconnectSessionBlock;
    CYLBooleanResultBlock completionHandler = ^(BOOL succeeded, NSError *error) {
        CYLHUDActionBlock HUDActionBlock = [CYLUIService sharedInstance].HUDActionBlock;
        !HUDActionBlock ?: HUDActionBlock(viewController, viewController.view, nil, CYLMessageHUDActionTypeHide);
        if (succeeded) {
            !HUDActionBlock ?: HUDActionBlock(viewController, viewController.view, CYLLocalizedStrings(@"connectSucceeded"), CYLMessageHUDActionTypeSuccess);
        } else {
            !HUDActionBlock ?: HUDActionBlock(viewController, viewController.view, CYLLocalizedStrings(@"connectFailed"), CYLMessageHUDActionTypeError);
            CYLLog(@"%@", error.description);
        }
        !aCallback ?: aCallback(succeeded, error);
    };
    !forceReconnectSessionBlock ?: forceReconnectSessionBlock(aError, granted, viewController, completionHandler);
}

#pragma mark - single sign-on

- (void)handleSingleSignOnError:(NSError *)aError callback:(CYLBooleanResultBlock)aCallback {
    [self resetService];
    [self requestForceSingleSignOnAuthorizationWithCallback:^(BOOL granted, NSError *theError) {
        [self reconnectForViewController:nil error:aError granted:granted callback:aCallback];
    }];
}

- (void)requestForceSingleSignOnAuthorizationWithCallback:(CYLRequestAuthorizationBoolResultBlock)callback {
    if (self.isRequestingSingleSignOn) {
        return;
    }
    self.requestingSingleSignOn = YES;
    NSString *title = CYLLocalizedStrings(@"requestForceSingleSignOnAuthorization");
    CYLAlertController *alert = [CYLAlertController alertControllerWithTitle:title
                                                                       message:@""
                                                                preferredStyle:CYLAlertControllerStyleAlert];
    NSString *cancelActionTitle = CYLLocalizedStrings(@"cancel") ?: @"取消";
    CYLAlertAction *cancelAction = [CYLAlertAction actionWithTitle:cancelActionTitle style:CYLAlertActionStyleDefault
                                                             handler:^(CYLAlertAction * action) {
                                                                 NSInteger code = 0;
                                                                 NSString *errorReasonText = @"request force single sign on failed";
                                                                 NSDictionary *errorInfo = @{
                                                                                             @"code":@(code),
                                                                                             NSLocalizedDescriptionKey : errorReasonText,
                                                                                             };
                                                                 NSError *error = [NSError errorWithDomain:CYLSessionServiceErrorDomain
                                                                                                      code:code
                                                                                                  userInfo:errorInfo];
                                                                 !callback ?: callback(NO, error);
                                                                 self.requestingSingleSignOn = NO;
                                                             }];
    [alert addAction:cancelAction];

    NSString *forceOpenActionTitle = CYLLocalizedStrings(@"ok") ?: @"确认";
    CYLAlertAction *forceOpenAction = [CYLAlertAction actionWithTitle:forceOpenActionTitle style:CYLAlertActionStyleDefault
                                                                handler:^(CYLAlertAction * action) {
                                                                    !callback ?: callback(YES, nil);
                                                                    self.requestingSingleSignOn = NO;
                                                                }];
    [alert addAction:forceOpenAction];
    [alert showWithSender:nil controller:nil animated:YES completion:NULL];
}

@end
