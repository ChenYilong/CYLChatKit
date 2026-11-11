//
//  NSBundle+CYLExtension.h
//  ChatKit
//
//  v2.1.1 Created by ElonChan on 16/5/19.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (CYLExtension)

+ (NSBundle *)cyl_bundleForName:(NSString *)bundleName class:(Class)aClass;

/*!

 * Path of `<bundleName>.bundle` inside the bundle that contains `aClass`, ignoring customized bundles.

 */
+ (NSString *)cyl_bundlePathForbundleName:(NSString *)bundleName class:(Class)aClass;
/*!
 * `<bundleName>.bundle` inside the bundle that contains `aClass`, ignoring customized bundles.
 */
+ (NSBundle *)cyl_bundleForbundleName:(NSString *)bundleName class:(Class)aClass;

@end
