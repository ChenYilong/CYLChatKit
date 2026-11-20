//
//  ChatKitHeaders.h
//  LeanCloudIMKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/11.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

// ChatKit does not import any IM SDK. The IM backend is provided by the app through `CYLIMProvider`.
#import <UIKit/UIKit.h>


#if __has_include(<CYLChatKit/CYLChatKit.h>)

    #import <CYLChatKit/CYLSessionService.h>
    #import <CYLChatKit/CYLUserSystemService.h>
    #import <CYLChatKit/CYLSignatureService.h>
    #import <CYLChatKit/CYLSettingService.h>
    #import <CYLChatKit/CYLUIService.h>
    #import <CYLChatKit/CYLConversationService.h>
    #import <CYLChatKit/CYLConversationListService.h>
    #import <CYLChatKit/CYLServiceDefinition.h>
    #import <CYLChatKit/CYLConversationViewController.h>
    #import <CYLChatKit/CYLConversationListViewController.h>
    #import <CYLChatKit/CYLConversationProtocol.h>
    #import <CYLChatKit/CYLIMMessageProtocol.h>
    #import <CYLChatKit/CYLIMProvider.h>
    #import <CYLChatKit/UIImageView+CYLExtension.h>
    #import <CYLChatKit/UIImageView+CYLCornerRadius.h>
    #import <CYLChatKit/CYLChatBaseTableViewController.h>
    #import <CYLChatKit/CYLChatBaseNavigationController.h>
    #import <CYLChatKit/CYLMenuItem.h>
    #import <CYLChatKit/UIImage+CYLExtension.h>
    #import <CYLChatKit/NSString+CYLExtension.h>
    #import <CYLChatKit/NSObject+CYLIsFirstLaunch.h>
    #import <CYLChatKit/CYLContactListViewController.h>
    #import <CYLChatKit/CYLChatBaseViewController.h>
    #import <CYLChatKit/CYLChatBaseTableViewController.h>
    #import <CYLChatKit/CYLChatBaseNavigationController.h>
    #import <CYLChatKit/CYLBaseConversationViewController.h>
    #import <CYLChatKit/CYLContact.h>
    #import <CYLChatKit/CYLInputViewPlugin.h>
    #import <CYLChatKit/CYLInputViewPluginPickImage.h>
    #import <CYLChatKit/CYLInputViewPluginTakePhoto.h>
    #import <CYLChatKit/CYLInputViewPluginLocation.h>
    #import <CYLChatKit/CYLAlertController.h>
    #import <CYLChatKit/NSFileManager+CYLExtension.h>
    #import <CYLChatKit/NSObject+CYLExtension.h>
    #import <CYLChatKit/CYLChatMessageCell.h>
    #import <CYLChatKit/CYLChatConstants.h>
#import <CYLChatKit/CYLPhotoBrowser.h>
#else

    #import "CYLSessionService.h"
    #import "CYLUserSystemService.h"
    #import "CYLSignatureService.h"
    #import "CYLSettingService.h"
    #import "CYLUIService.h"
    #import "CYLConversationService.h"
    #import "CYLConversationListService.h"
    #import "CYLServiceDefinition.h"
    #import "CYLConversationViewController.h"
    #import "CYLConversationListViewController.h"
    #import "CYLConversationProtocol.h"
    #import "CYLIMMessageProtocol.h"
    #import "CYLIMProvider.h"
    #import "UIImageView+CYLExtension.h"
    #import "UIImageView+CYLCornerRadius.h"
    #import "CYLChatBaseTableViewController.h"
    #import "CYLChatBaseNavigationController.h"
    #import "CYLMenuItem.h"
    #import "UIImage+CYLExtension.h"
    #import "NSString+CYLExtension.h"
    #import "NSObject+CYLIsFirstLaunch.h"
    #import "CYLContactListViewController.h"
    #import "CYLChatBaseViewController.h"
    #import "CYLChatBaseTableViewController.h"
    #import "CYLChatBaseNavigationController.h"
    #import "CYLBaseConversationViewController.h"
    #import "CYLContact.h"
    #import "CYLInputViewPlugin.h"
    #import "CYLInputViewPluginPickImage.h"
    #import "CYLInputViewPluginTakePhoto.h"
    #import "CYLInputViewPluginLocation.h"
    #import "CYLAlertController.h"
    #import "NSFileManager+CYLExtension.h"
    #import "NSObject+CYLExtension.h"
    #import "CYLChatMessageCell.h"
    #import "CYLChatConstants.h"
    #import "CYLPhotoBrowser.h"

#endif

#if __has_include(<SDWebImage/UIImageView+WebCache.h>)
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIButton+WebCache.h>

#else
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#endif

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif


#if __has_include(<MBProgressHUD/MBProgressHUD.h>)
#import <MBProgressHUD/MBProgressHUD.h>

#else
#import "MBProgressHUD.h"
#endif


