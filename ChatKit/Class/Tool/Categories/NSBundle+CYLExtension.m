//
//  NSBundle+CYLExtension.m
//  ChatKit
//
//  v2.1.1 Created by ElonChan on 16/5/19.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "NSBundle+CYLExtension.h"

@implementation NSBundle (CYLExtension)

+ (NSString *)cyl_bundlePathForBundleName:(NSString *)bundleName class:(Class)aClass {
    NSString *pathComponent = [NSString stringWithFormat:@"%@.bundle", bundleName];
    NSString *bundlePath = [[[NSBundle bundleForClass:aClass] resourcePath] stringByAppendingPathComponent:pathComponent];
    return bundlePath;
}

+ (NSString *)cyl_customizedBundlePathForBundleName:(NSString *)bundleName {
    NSString *customizedBundlePathComponent = [NSString stringWithFormat:@"CustomizedChatKit.%@.bundle", bundleName];
    NSString *customizedBundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:customizedBundlePathComponent];
    return customizedBundlePath;
}

+ (NSBundle *)cyl_bundleForName:(NSString *)bundleName class:(Class)aClass {
    NSString *customizedBundlePath = [NSBundle cyl_customizedBundlePathForBundleName:bundleName];
    NSBundle *customizedBundle = [NSBundle bundleWithPath:customizedBundlePath];
    if (customizedBundle) {
        return customizedBundle;
    }
    NSString *bundlePath = [NSBundle cyl_bundlePathForBundleName:bundleName class:aClass];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    return bundle;
}

+ (NSString *)cyl_bundlePathForbundleName:(NSString *)bundleName class:(Class)aClass {
    NSString *pathComponent = [NSString stringWithFormat:@"%@.bundle", bundleName];
    return [[[NSBundle bundleForClass:aClass] resourcePath] stringByAppendingPathComponent:pathComponent];
}

+ (NSBundle *)cyl_bundleForbundleName:(NSString *)bundleName class:(Class)aClass {
    return [NSBundle bundleWithPath:[NSBundle cyl_bundlePathForbundleName:bundleName class:aClass]];
}

@end
