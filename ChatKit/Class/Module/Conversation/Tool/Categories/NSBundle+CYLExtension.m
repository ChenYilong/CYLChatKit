//
//  NSBundle+CYLExtension.m
//  ChatKit
//
//  Created by 陈宜龙 on 16/5/19.
//  Copyright © 2016年 ElonChan. All rights reserved.
//

#import "NSBundle+CYLExtension.h"

@implementation NSBundle (CYLExtension)

+ (NSString *)cyl_bundlePathForbundleName:(NSString *)bundleName class:(Class)aClass {
    NSString *pathComponent = [NSString stringWithFormat:@"%@.bundle", bundleName];
    NSString *bundlePath =[[[NSBundle bundleForClass:aClass] resourcePath] stringByAppendingPathComponent:pathComponent];
    return bundlePath;
}

+ (NSBundle *)cyl_bundleForbundleName:(NSString *)bundleName class:(Class)aClass {
    NSString *bundlePath = [NSBundle cyl_bundlePathForbundleName:bundleName class:aClass];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    return bundle;
}
@end
