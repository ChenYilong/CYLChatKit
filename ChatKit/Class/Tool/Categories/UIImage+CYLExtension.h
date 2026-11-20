//
//  UIImage+CYLExtension.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/5/7.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
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

- (UIImage *)cyl_scalingPatternImageToSize:(CGSize)size;

@end
