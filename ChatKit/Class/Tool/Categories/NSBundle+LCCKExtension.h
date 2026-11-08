//
//  NSBundle+LCCKExtension.h
//  ChatKit
//
//  v2.1.1 Created by ElonChan on 16/5/19.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (LCCKExtension)

+ (NSBundle *)lcck_bundleForName:(NSString *)bundleName class:(Class)aClass;

@end
