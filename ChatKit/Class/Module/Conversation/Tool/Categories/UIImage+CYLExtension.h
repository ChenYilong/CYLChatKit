//
//  UIImage+CYLExtension.h
//  LeanCloudChatKit-iOS
//
//  Created by 陈宜龙 on 16/5/7.
//  Copyright © 2016年 ElonChan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSBundle+CYLExtension.h"

@interface UIImage (CYLExtension)

- (UIImage *)cyl_imageByScalingAspectFill;
/*!
 * @attention This will invoke `CGSize kMaxImageViewSize = {.width = 200, .height = 200};`.
 */
- (UIImage *)cyl_imageByScalingAspectFillWithOriginSize:(CGSize)originSize;

- (UIImage *)cyl_imageByScalingAspectFillWithOriginSize:(CGSize)originSize
                                               limitSize:(CGSize)limitSize;

+ (UIImage *)cyl_imageNamed:(NSString *)imageName bundleName:(NSString *)bundleName bundleForClass:(Class)aClass;
@end
