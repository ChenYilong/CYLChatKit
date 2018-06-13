//
//  LCCKContentView.m
//  LCCKChatExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/11/13.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//

#import "LCCKContentView.h"

@implementation LCCKContentView

- (instancetype)init {
    if (self = [super init]) {
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.fillColor = [UIColor grayColor].CGColor;
        maskLayer.contentsCenter = CGRectMake(.7f, .7f, .1f, .1f);
        maskLayer.contentsScale = [UIScreen mainScreen].scale;
        self.layer.mask = maskLayer;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.maskView.frame = CGRectInset(self.bounds, 0, 0);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.layer.mask.frame = CGRectInset(self.bounds, 0, 0);
    [CATransaction commit];
}

@end
