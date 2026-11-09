//
//  UIView+CYLExtension.h
//  ChatKit
//
//  v2.1.1 Created by ElonChan on 16/6/2.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CYLViewActionBlock)(UIView *subview);

@interface UIView (CYLExtension)

- (NSMutableArray*)cyl_allSubViews;

- (void)cyl_logViewHierarchy:(CYLViewActionBlock)viewActionBlcok;

@end
