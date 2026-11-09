//
//  NSBundle+CYLExtension.h
//  ChatKit
//
//  Created by 陈宜龙 on 16/5/19.
//  Copyright © 2016年 ElonChan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (CYLExtension)

+ (NSString *)cyl_bundlePathForbundleName:(NSString *)bundleName class:(Class)aClass;
+ (NSBundle *)cyl_bundleForbundleName:(NSString *)bundleName class:(Class)aClass;

@end
