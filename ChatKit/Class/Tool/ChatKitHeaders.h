//
//  IMKitHeaders.h
//  LeanCloudIMKit-iOS
//
//  Created by 陈宜龙 on 16/3/11.
//  Copyright © 2016年 ElonChan. All rights reserved.
//

FOUNDATION_EXPORT double LCChatKitVersionNumber;
FOUNDATION_EXPORT const unsigned char LCChatKitVersionString[];

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

#if __has_include(<ChatKit/LCChatKit.h>)

#import <ChatKit/LCCKConstants.h>
#import <ChatKit/LCCKSessionService.h>
#import <ChatKit/LCCKUserSystemService.h>
#import <ChatKit/LCCKSignatureService.h>
#import <ChatKit/LCCKSettingService.h>
#import <ChatKit/LCCKUIService.h>
#import <ChatKit/LCCKConversationService.h>
#import <ChatKit/LCCKConversationListService.h>
#import <ChatKit/LCCKServiceDefinition.h>
#import <ChatKit/LCCKConversationViewController.h>
#import <ChatKit/LCCKConversationListViewController.h>
#import <ChatKit/AVIMConversation+LCCKAddition.h>
#import <ChatKit/UIImageView+LCCKExtension.h>
#import <ChatKit/LCCKBaseTableViewController.h>
#import <ChatKit/LCCKBaseNavigationController.h>
#import <ChatKit/LCCKMenuItem.h>

#else

#import "LCCKConstants.h"
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
#import "AVIMConversation+LCCKAddition.h"
#import "UIImageView+LCCKExtension.h"
#import "LCCKBaseTableViewController.h"
#import "LCCKBaseNavigationController.h"
#import "LCCKMenuItem.h"

#endif



