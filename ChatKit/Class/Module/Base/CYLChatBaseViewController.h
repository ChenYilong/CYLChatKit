//
//  CYLChatBaseViewController.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 18/6/26.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CYLChatBaseViewController;
@protocol CYLViewControllerEventProtocol <NSObject>

/**
 *  页面需要透出的通用事件，例如viewDidLoad，viewWillAppear，viewDidAppear等
 */
typedef void(^CYLViewDidLoadBlock)(__kindof CYLChatBaseViewController *viewController);
typedef void(^CYLViewWillAppearBlock)(__kindof CYLChatBaseViewController *viewController, BOOL aAnimated);
typedef void(^CYLViewDidAppearBlock)(__kindof CYLChatBaseViewController *viewController, BOOL aAnimated);
typedef void(^CYLViewWillDisappearBlock)(__kindof CYLChatBaseViewController *viewController, BOOL aAnimated);
typedef void(^CYLViewDidDisappearBlock)(__kindof CYLChatBaseViewController *viewController, BOOL aAnimated);
typedef void(^CYLViewDidDismissBlock)(__kindof CYLChatBaseViewController *viewController);
typedef void(^CYLViewControllerWillDeallocBlock) (__kindof CYLChatBaseViewController *viewController);
typedef void(^CYLViewDidReceiveMemoryWarningBlock)(__kindof CYLChatBaseViewController *viewController);

@property (nonatomic, copy) CYLViewDidLoadBlock viewDidLoadBlock;
@property (nonatomic, copy) CYLViewWillAppearBlock viewWillAppearBlock;
@property (nonatomic, copy) CYLViewDidAppearBlock viewDidAppearBlock;
@property (nonatomic, copy) CYLViewWillDisappearBlock viewWillDisappearBlock;
@property (nonatomic, copy) CYLViewDidDisappearBlock viewDidDisappearBlock;
@property (nonatomic, copy) CYLViewDidDismissBlock viewDidDismissBlock;
@property (nonatomic, copy) CYLViewControllerWillDeallocBlock viewControllerWillDeallocBlock;
@property (nonatomic, copy) CYLViewDidReceiveMemoryWarningBlock didReceiveMemoryWarningBlock;

/**
 *  View的相关事件调出
 */
- (void)setViewDidLoadBlock:(CYLViewDidLoadBlock)viewDidLoadBlock;
- (void)setViewWillAppearBlock:(CYLViewWillAppearBlock)viewWillAppearBlock;
- (void)setViewDidAppearBlock:(CYLViewDidAppearBlock)viewDidAppearBlock;
- (void)setViewWillDisappearBlock:(CYLViewWillDisappearBlock)viewWillDisappearBlock;
- (void)setViewDidDisappearBlock:(CYLViewDidDisappearBlock)viewDidDisappearBlock;
- (void)setViewDidDismissBlock:(CYLViewDidDismissBlock)viewDidDismissBlock;
- (void)setViewControllerWillDeallocBlock:(CYLViewControllerWillDeallocBlock)viewControllerWillDeallocBlock;
- (void)setViewDidReceiveMemoryWarningBlock:(CYLViewDidReceiveMemoryWarningBlock)didReceiveMemoryWarningBlock;

@end

typedef void(^CYLBarButtonItemActionBlock)(__kindof CYLChatBaseViewController *viewController, UIBarButtonItem *sender, UIEvent *event);

typedef NS_ENUM(NSInteger, CYLBarButtonItemStyle) {
    CYLBarButtonItemStyleSetting = 0,
    CYLBarButtonItemStyleMore,
    CYLBarButtonItemStyleAdd,
    CYLBarButtonItemStyleAddFriends,
    CYLBarButtonItemStyleShare,
    CYLBarButtonItemStyleSingleProfile,
    CYLBarButtonItemStyleGroupProfile,
};

@interface CYLChatBaseViewController : UIViewController <CYLViewControllerEventProtocol>

- (void)configureBarButtonItemStyle:(CYLBarButtonItemStyle)style action:(CYLBarButtonItemActionBlock)action;

- (void)alert:(NSString *)message;

/*!
 * Shows an alert for an IM error. The historical name is kept for compatibility;
 * it handles errors from any `CYLIMProvider`. See `CYLIMErrorCodeConnectionLost`.
 */
- (BOOL)alertAVIMError:(NSError *)error;

- (BOOL)filterAVIMError:(NSError *)error;

@end
