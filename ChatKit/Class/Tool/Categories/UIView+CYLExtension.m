//
//  UIView+CYLExtension.m
//  ChatKit
//
//  v2.1.1 Created by ElonChan on 16/6/2.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "UIView+CYLExtension.h"

@implementation UIView (CYLExtension)

- (NSMutableArray*)cyl_allSubViews {
    NSMutableArray *allSubViews = [[NSMutableArray alloc] init];
    [allSubViews addObject:self];
    for (UIView *subview in self.subviews) {
        [allSubViews addObjectsFromArray:(NSArray*)[subview cyl_allSubViews]];
    }
    return allSubViews;
}

- (void)cyl_logViewHierarchy:(CYLViewActionBlock)viewActionBlcok {
    //view action block - freedom to the caller
    viewActionBlcok(self);
    for (UIView *subview in self.subviews) {
        [subview cyl_logViewHierarchy:viewActionBlcok];
    }
}

@end
