//
//  ChatKitHeaders.h
//  LeanCloudIMKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/11.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#if __has_include(<AVOSCloud/AVOSCloud.h>)
    #import <AVOSCloud/AVOSCloud.h>
#else
    #import "AVOSCloud.h"
#endif

#if __has_include(<AVOSCloudIM/AVOSCloudIM.h>)
    #import <AVOSCloudIM/AVOSCloudIM.h>
#else
    #import "AVOSCloudIM.h"
#endif


#if __has_include(<CYLChatKit/LCChatKit.h>)

    #import <CYLChatKit/LCCKSessionService.h>
    #import <CYLChatKit/LCCKUserSystemService.h>
    #import <CYLChatKit/LCCKSignatureService.h>
    #import <CYLChatKit/LCCKSettingService.h>
    #import <CYLChatKit/LCCKUIService.h>
    #import <CYLChatKit/LCCKConversationService.h>
    #import <CYLChatKit/LCCKConversationListService.h>
    #import <CYLChatKit/LCCKServiceDefinition.h>
    #import <CYLChatKit/LCCKConversationViewController.h>
    #import <CYLChatKit/LCCKConversationListViewController.h>
    #import <CYLChatKit/AVIMConversation+LCCKExtension.h>
    #import <CYLChatKit/UIImageView+LCCKExtension.h>
    #import <CYLChatKit/LCCKBaseTableViewController.h>
    #import <CYLChatKit/LCCKBaseNavigationController.h>
    #import <CYLChatKit/LCCKMenuItem.h>
    #import <CYLChatKit/UIImage+LCCKExtension.h>
    #import <CYLChatKit/NSString+LCCKExtension.h>
    #import <CYLChatKit/NSObject+LCCKIsFirstLaunch.h>
    #import <CYLChatKit/LCCKContactListViewController.h>
    #import <CYLChatKit/LCCKBaseViewController.h>
    #import <CYLChatKit/LCCKBaseTableViewController.h>
    #import <CYLChatKit/LCCKBaseNavigationController.h>
    #import <CYLChatKit/LCCKBaseConversationViewController.h>
    #import <CYLChatKit/LCCKContact.h>
    #import <CYLChatKit/AVIMTypedMessage+LCCKExtension.h>
    #import <CYLChatKit/LCCKInputViewPlugin.h>
    #import <CYLChatKit/LCCKInputViewPluginPickImage.h>
    #import <CYLChatKit/LCCKInputViewPluginTakePhoto.h>
    #import <CYLChatKit/LCCKInputViewPluginLocation.h>
    #import <CYLChatKit/LCCKAlertController.h>
    #import <CYLChatKit/NSFileManager+LCCKExtension.h>
    #import <CYLChatKit/NSObject+LCCKExtension.h>
    #import <CYLChatKit/LCCKChatMessageCell.h>
    #import <CYLChatKit/LCCKConstants.h>

#else

    #import "LCCKSessionService.h"
    #import "LCCKUserSystemService.h"
    #import "LCCKSignatureService.h"
    #import "LCCKSettingService.h"
    #import "LCCKUIService.h"
    #import "LCCKConversationService.h"
    #import "LCCKConversationListService.h"
    #import "LCCKServiceDefinition.h"
    #import "LCCKConversationViewController.h"
    #import "LCCKConversationListViewController.h"
    #import "AVIMConversation+LCCKExtension.h"
    #import "UIImageView+LCCKExtension.h"
    #import "LCCKBaseTableViewController.h"
    #import "LCCKBaseNavigationController.h"
    #import "LCCKMenuItem.h"
    #import "UIImage+LCCKExtension.h"
    #import "NSString+LCCKExtension.h"
    #import "NSObject+LCCKIsFirstLaunch.h"
    #import "LCCKContactListViewController.h"
    #import "LCCKBaseViewController.h"
    #import "LCCKBaseTableViewController.h"
    #import "LCCKBaseNavigationController.h"
    #import "LCCKBaseConversationViewController.h"
    #import "LCCKContact.h"
    #import "AVIMTypedMessage+LCCKExtension.h"
    #import "LCCKInputViewPlugin.h"
    #import "LCCKInputViewPluginPickImage.h"
    #import "LCCKInputViewPluginTakePhoto.h"
    #import "LCCKInputViewPluginLocation.h"
    #import "LCCKAlertController.h"
    #import "NSFileManager+LCCKExtension.h"
    #import "NSObject+LCCKExtension.h"
    #import "LCCKChatMessageCell.h"
    #import "LCCKConstants.h"

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


