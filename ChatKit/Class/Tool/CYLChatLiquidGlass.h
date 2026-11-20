//
//  CYLChatLiquidGlass.h
//  CYLChatKit
//
//  The only place that touches the iOS 26 Liquid Glass material (`UIGlassEffect`). Everything here is guarded, so the
//  library still builds with an older SDK and does nothing on an older system:
//  - compile time: `#if defined(__IPHONE_26_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_26_0`
//  - run time: `if (@available(iOS 26.0, *))`, plus the app's own opt-out, `UIDesignRequiresCompatibility`
//  Call sites need no guards of their own: they ask this class and keep their existing styling when it answers no.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYLChatLiquidGlass : NSObject

/*!
 * Whether the app is drawn with Liquid Glass: built with the iOS 26 SDK or later, and running on iOS 27 or later, or on
 * iOS 26 unless `UIDesignRequiresCompatibility` is YES in the app's Info.plist. Always NO otherwise. The same rule as
 * CYLTabBarController's `+[CYLConstants isLiquidGlassActive]`.
 */
+ (BOOL)isActive;

/*!
 * Adds a Liquid Glass backdrop with the system's default capsule shape directly behind `view`, matching its frame, and
 * returns it. Returns nil, and changes nothing, when `+isActive` is NO; the caller then keeps its opaque styling. The
 * backdrop ignores touches.
 *
 * @param view      the view that sits on the glass; it must already be in `container`
 * @param container the superview of `view`
 */
+ (nullable UIView *)installBackdropBehindView:(UIView *)view inContainer:(UIView *)container;

@end

NS_ASSUME_NONNULL_END
