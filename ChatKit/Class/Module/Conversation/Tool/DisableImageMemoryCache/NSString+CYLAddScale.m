//
//  NSString+CYLAddScale.m
//  Kuber
//
//  v2.1.1 Created by Kuber on 16/3/30.
//  Copyright © 2016年 Huaxu Technology. All rights reserved.
//

#import "NSString+CYLAddScale.h"

@implementation NSString (CYLAddScale)

- (NSString *)cyl_stringByAppendingScale:(CGFloat)scale {
    if (fabs(scale - 1) <= __FLT_EPSILON__ || self.length == 0 || [self hasSuffix:@"/"]) return self.copy;
    return [self stringByAppendingFormat:@"@%@x", @(scale)];
}

@end
