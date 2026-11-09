//
//  CYLChatMoreView.h
//  CYLChatBarExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/8/18.
//  Copyright (c) 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYLChatConstants.h"

static CGFloat const kFunctionViewHeight = 210.0f;
@class CYLChatBar;
/**
 *  更多view
 */
@interface CYLChatMoreView : UIView

@property (assign, nonatomic) NSUInteger numberPerLine;
@property (assign, nonatomic) UIEdgeInsets edgeInsets;
@property (weak, nonatomic) CYLChatBar *inputViewRef;

@end
