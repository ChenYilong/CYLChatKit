//
//  UIView+LCCKExtension.h
//  ChatKit
//
//  v2.1.1 Created by ElonChan on 16/6/2.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LCCKViewActionBlock)(UIView *subview);

@interface UIView (LCCKExtension)

- (NSMutableArray*)lcck_allSubViews;

- (void)lcck_logViewHierarchy:(LCCKViewActionBlock)viewActionBlcok;

@end
