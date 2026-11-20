//
//  UIImageView+CYLExtension.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/5/16.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "UIImageView+CYLExtension.h"
#import <objc/runtime.h>

#if __has_include(<CYLDeallocBlockExecutor/CYLDeallocBlockExecutor.h>)
#import <CYLDeallocBlockExecutor/CYLDeallocBlockExecutor.h>
#else
#import "CYLDeallocBlockExecutor.h"
#endif

#pragma mark -
#pragma mark - Private Methods

@interface UIImage (__Privete_CornerRadius)

@property (nonatomic, assign) BOOL cyl_cornerRadius;
@end

@implementation UIImage (__Privete_CornerRadius)

- (BOOL)cyl_cornerRadius {
    NSNumber *cyl_cornerRadiusObject = objc_getAssociatedObject(self, @selector(cyl_cornerRadius));
    return [cyl_cornerRadiusObject boolValue];
}

- (void)setCyl_cornerRadius:(BOOL)cyl_cornerRadius {
    NSNumber *cyl_cornerRadiusObject = [NSNumber numberWithBool:cyl_cornerRadius];
    objc_setAssociatedObject(self, @selector(cyl_cornerRadius), cyl_cornerRadiusObject, OBJC_ASSOCIATION_ASSIGN);
};

@end


#pragma mark -
#pragma mark - Helper Class Method

@interface CYLImageObserver : NSObject

@property (nonatomic, assign) UIImageView *originImageView;
@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic, assign) CGFloat cornerRadius;

- (instancetype)initWithImageView:(UIImageView *)imageView;

@end

@implementation CYLImageObserver

- (instancetype)initWithImageView:(UIImageView *)imageView {
    if (self = [super init]) {
        self.originImageView = imageView;
        [imageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
        [imageView addObserver:self forKeyPath:@"contentMode" options:NSKeyValueObservingOptionNew context:nil];
        [self cyl_willDeallocWithSelfCallback:^(__unsafe_unretained CYLImageObserver *owner, NSUInteger identifier) {
            [owner.originImageView removeObserver:owner forKeyPath:@"image"];
            [owner.originImageView removeObserver:owner forKeyPath:@"contentMode"];
        }];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString*, id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"image"]) {
        UIImage *newImage = change[@"new"];
        if (![newImage isKindOfClass:[UIImage class]] || newImage.cyl_cornerRadius) {
            return;
        }
        [self updateImageView];
    }
    if ([keyPath isEqualToString:@"contentMode"]) {
        self.originImageView.image = self.originImage;
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (_cornerRadius == cornerRadius) {
        return;
    }
    _cornerRadius = cornerRadius;
    if (_cornerRadius > 0) {
        [self updateImageView];
    }
}

- (void)updateImageView {
    self.originImage = self.originImageView.image;
    if (!self.originImage) {
        return;
    }
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(self.originImageView.bounds.size, NO, [UIScreen mainScreen].scale);
    CGContextRef currnetContext = UIGraphicsGetCurrentContext();
    if (currnetContext) {
        CGContextAddPath(currnetContext, [UIBezierPath bezierPathWithRoundedRect:self.originImageView.bounds cornerRadius:self.cornerRadius].CGPath);
        CGContextClip(currnetContext);
        [self.originImageView.layer renderInContext:currnetContext];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    if ([image isKindOfClass:[UIImage class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            image.cyl_cornerRadius = YES;
            self.originImageView.image = image;
        });
    }
}

@end


#pragma mark -
#pragma mark - public Methods

@implementation UIImageView (CYLExtension)

- (CGFloat)cyl_cornerRadius {
    return [self cyl_imageObserver].cornerRadius;
}

- (void)setCyl_cornerRadius:(CGFloat)aliCornerRadius {
    [self cyl_imageObserver].cornerRadius = aliCornerRadius;
}

- (CYLImageObserver *)cyl_imageObserver {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    CYLImageObserver *imageObserver = objc_getAssociatedObject(self, @selector(imageObserver));
#pragma clang diagnostic pop
    
    if (!imageObserver) {
        imageObserver = [[CYLImageObserver alloc] initWithImageView:self];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        objc_setAssociatedObject(self, @selector(imageObserver), imageObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#pragma clang diagnostic pop
    }
    return imageObserver;
}

@end
