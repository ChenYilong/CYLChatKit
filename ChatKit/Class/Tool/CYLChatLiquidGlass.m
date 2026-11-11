//
//  CYLChatLiquidGlass.m
//  CYLChatKit
//

#import "CYLChatLiquidGlass.h"

@implementation CYLChatLiquidGlass

+ (BOOL)isActive {
#if defined(__IPHONE_26_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_26_0
    static BOOL active = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 27.0, *)) {
            active = YES;
        } else if (@available(iOS 26.0, *)) {
            active = ![[NSBundle.mainBundle objectForInfoDictionaryKey:@"UIDesignRequiresCompatibility"] boolValue];
        }
    });
    return active;
#else
    // Built with an SDK before iOS 26: the app never gets Liquid Glass, whatever system it runs on.
    return NO;
#endif
}

+ (UIView *)installBackdropBehindView:(UIView *)view inContainer:(UIView *)container {
#if defined(__IPHONE_26_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_26_0
    if (@available(iOS 26.0, *)) {
        if ([self isActive]) {
            UIVisualEffectView *backdrop = [[UIVisualEffectView alloc] initWithEffect:[UIGlassEffect effectWithStyle:UIGlassEffectStyleRegular]];
            backdrop.translatesAutoresizingMaskIntoConstraints = NO;
            backdrop.userInteractionEnabled = NO;
            [container insertSubview:backdrop belowSubview:view];
            [NSLayoutConstraint activateConstraints:@[
                [backdrop.topAnchor constraintEqualToAnchor:view.topAnchor],
                [backdrop.bottomAnchor constraintEqualToAnchor:view.bottomAnchor],
                [backdrop.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
                [backdrop.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
            ]];
            return backdrop;
        }
    }
#endif
    return nil;
}

@end
