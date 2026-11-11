//
//  CYLSendImageView.m
//  CYLChatBarExample
//
//  Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/11/23.
//  Copyright © 2015年 https://LeanCloud.cn . All rights reserved.
//

#import "CYLSendImageView.h"

@interface CYLSendImageView ()

@property (nonatomic, weak) UIActivityIndicatorView *indicatorView;

@end

@implementation CYLSendImageView

- (instancetype)init {
    if ([super init]) {
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicatorView.hidden = YES;
        [self addSubview:self.indicatorView = indicatorView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.indicatorView.frame = self.bounds;
}

#pragma mark - Setters
- (void)setMessageSendState:(CYLMessageSendState)messageSendState {
    _messageSendState = messageSendState;
    if (_messageSendState == CYLMessageSendStateSending) {
        dispatch_async(dispatch_get_main_queue(),^{
            [self.indicatorView startAnimating];
        });
        self.indicatorView.hidden = NO;
    } else {
        dispatch_async(dispatch_get_main_queue(),^{
            [self.indicatorView stopAnimating];
        });
        self.indicatorView.hidden = YES;
    }
    
    switch (_messageSendState) {
        case CYLMessageSendStateSending:
        case CYLMessageSendStateFailed:
            self.hidden = NO;
            break;
        default:
            self.hidden = YES;
            break;
    }
}

//- (void)setMessageSendState:(CYLMessageSendState)messageSendState {
//    _messageSendState = messageSendState;
//    if (_messageSendState == CYLMessageSendStateSending) {
//        dispatch_async(dispatch_get_main_queue(),^{
//            if (!self.indicatorView.isAnimating) {
//                [self.indicatorView startAnimating];
//            }
//        });
//        self.indicatorView.hidden = NO;
//    } else {
//        dispatch_async(dispatch_get_main_queue(),^{
//            if (self.indicatorView.isAnimating) {
//                [self.indicatorView stopAnimating];
//            }
//        });
//        self.indicatorView.hidden = YES;
//    }
//    
//    switch (_messageSendState) {
//        case CYLMessageSendStateSending:
//        case CYLMessageSendStateFailed:
//            self.hidden = NO;
//            break;
//        default:
//            self.hidden = YES;
//            break;
//    }
//}


@end
