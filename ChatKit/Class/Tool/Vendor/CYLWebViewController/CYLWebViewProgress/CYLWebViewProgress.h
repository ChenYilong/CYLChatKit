//
//  CYLWebViewProgress.h
//
//  Created by Satoshi Aasano on 4/20/13.
//  Copyright (c) 2013 Satoshi Asano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#undef njk_weak
#if __has_feature(objc_arc_weak)
#define njk_weak weak
#else
#define njk_weak unsafe_unretained
#endif

extern const float CYLInitialProgressValue;
extern const float CYLInteractiveProgressValue;
extern const float CYLFinalProgressValue;

typedef void (^CYLWebViewProgressBlock)(float progress);
@protocol CYLWebViewProgressDelegate;
@interface CYLWebViewProgress : NSObject<UIWebViewDelegate>
@property (nonatomic, njk_weak) id<CYLWebViewProgressDelegate>progressDelegate;
@property (nonatomic, njk_weak) id<UIWebViewDelegate>webViewProxyDelegate;
@property (nonatomic, copy) CYLWebViewProgressBlock progressBlock;
@property (nonatomic, readonly) float progress; // 0.0..1.0

- (void)reset;
@end

@protocol CYLWebViewProgressDelegate <NSObject>
- (void)webViewProgress:(CYLWebViewProgress *)webViewProgress updateProgress:(float)progress;
@end

