//
//  CYLTextFullScreenViewController.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/23.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "CYLChatBaseViewController.h"
@class CYLMessage;
typedef void (^CYLRemoveFromWindowHandler)(void);
@interface CYLTextFullScreenViewController : CYLChatBaseViewController

@property (nonatomic, copy, readonly) NSString *text;

- (instancetype)initWithText:(NSString *)text;
- (void)setRemoveFromWindowHandler:(CYLRemoveFromWindowHandler)removeFromWindowHandler;
@end
