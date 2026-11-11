//
//  CYLChatBaseViewController.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan  on 18/6/26.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "CYLChatBaseViewController.h"
#import "CYLUIService.h"
#import "UIImage+CYLExtension.h"

@interface CYLChatBaseViewController ()

@property (nonatomic, copy) CYLBarButtonItemActionBlock barButtonItemAction;

@end

@implementation CYLChatBaseViewController
@synthesize viewDidLoadBlock = _viewDidLoadBlock;
@synthesize viewWillAppearBlock = _viewWillAppearBlock;
@synthesize viewDidAppearBlock = _viewDidAppearBlock;
@synthesize viewWillDisappearBlock = _viewWillDisappearBlock;
@synthesize viewDidDisappearBlock = _viewDidDisappearBlock;
@synthesize viewDidDismissBlock = _viewDidDismissBlock;
@synthesize viewControllerWillDeallocBlock = _viewControllerWillDeallocBlock;
@synthesize didReceiveMemoryWarningBlock = _didReceiveMemoryWarningBlock;

#pragma mark -
#pragma mark - UIViewController Life Event Block

- (void)setViewDidLoadBlock:(CYLViewDidLoadBlock)viewDidLoadBlock {
    _viewDidLoadBlock = viewDidLoadBlock;
}

- (void)setViewWillAppearBlock:(CYLViewWillAppearBlock)viewWillAppearBlock {
    _viewWillAppearBlock = viewWillAppearBlock;
}

- (void)setViewDidAppearBlock:(CYLViewDidAppearBlock)viewDidAppearBlock {
    _viewDidAppearBlock = viewDidAppearBlock;
}

- (void)setViewWillDisappearBlock:(CYLViewWillDisappearBlock)viewWillDisappearBlock {
    _viewWillDisappearBlock = viewWillDisappearBlock;
}

- (void)setViewDidDisappearBlock:(CYLViewDidDisappearBlock)viewDidDisappearBlock {
    _viewDidDisappearBlock = viewDidDisappearBlock;
}

- (void)setViewDidDismissBlock:(CYLViewDidDismissBlock)viewDidDismissBlock {
    _viewDidDismissBlock = viewDidDismissBlock;
}


- (void)setViewControllerWillDeallocBlock:(CYLViewControllerWillDeallocBlock)viewControllerWillDeallocBlock {
    _viewControllerWillDeallocBlock = viewControllerWillDeallocBlock;
}

- (void)setViewDidReceiveMemoryWarningBlock:(CYLViewDidReceiveMemoryWarningBlock)didReceiveMemoryWarningBlock {
    _didReceiveMemoryWarningBlock = didReceiveMemoryWarningBlock;
}

- (void)clickedBarButtonItemAction:(UIBarButtonItem *)sender event:(UIEvent *)event {
    if (self.barButtonItemAction) {
        self.barButtonItemAction(self, sender, event);
    }
}

#pragma mark - Public Method

- (void)configureBarButtonItemStyle:(CYLBarButtonItemStyle)style action:(CYLBarButtonItemActionBlock)action {
    NSString *icon;
    switch (style) {
        case CYLBarButtonItemStyleSetting: {
            icon = @"barbuttonicon_set";
            break;
        }
        case CYLBarButtonItemStyleMore: {
            icon = @"barbuttonicon_more";
            break;
        }
        case CYLBarButtonItemStyleAdd: {
            icon = @"barbuttonicon_add";
            break;
        }
        case CYLBarButtonItemStyleAddFriends:
            icon = @"barbuttonicon_addfriends";
            break;
        case CYLBarButtonItemStyleSingleProfile:
            icon = @"barbuttonicon_InfoSingle";
            break;
        case CYLBarButtonItemStyleGroupProfile:
            icon = @"barbuttonicon_InfoMulti";
            break;
        case CYLBarButtonItemStyleShare:
            icon = @"barbuttonicon_Operate";
            break;
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage cyl_imageNamed:icon bundleName:@"BarButtonIcon" bundleForClass:[self class]] style:UIBarButtonItemStylePlain target:self action:@selector(clickedBarButtonItemAction:event:)];
    self.barButtonItemAction = action;
}

#pragma mark - alert and async utils

- (void)alert:(NSString *)message {
    CYLShowNotificationBlock showNotificationBlock = [CYLUIService sharedInstance].showNotificationBlock;
    !showNotificationBlock ?: showNotificationBlock(self, message, nil, CYLMessageNotificationTypeError);
}

- (BOOL)alertCYLIMError:(NSError *)error {
    if (error) {
        if (error.code == CYLIMErrorCodeConnectionLost) {
            [self alert:@"未能连接聊天服务"];
        } else if ([error.domain isEqualToString:NSURLErrorDomain]) {
            [self alert:@"网络连接发生错误"];
        } else {
            [self alert:[NSString stringWithFormat:@"%@", error]];
        }
        return YES;
    }
    return NO;
}

- (BOOL)filterCYLIMError:(NSError *)error {
    return [self alertCYLIMError:error] == NO;
}

@end
