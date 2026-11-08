//
//  LCCKChatFaceView.h
//  LCCKChatBarExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/8/21.
//  Copyright (c) 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LCCKShowFaceViewType) {
    LCCKShowEmojiFace = 0,
    LCCKShowRecentFace,
    LCCKShowGifFace,
};
#define kLCCKTopLineBackgroundColor [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f]

@protocol LCCKChatFaceViewDelegate <NSObject>

- (void)faceViewSendFace:(NSString *)faceName;

@end

@interface LCCKChatFaceView : UIView

@property (weak, nonatomic) id<LCCKChatFaceViewDelegate> delegate;
@property (assign, nonatomic) LCCKShowFaceViewType faceViewType;

@end
