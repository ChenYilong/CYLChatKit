//
//  CYLChatFaceView.h
//  CYLChatBarExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/8/21.
//  Copyright (c) 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CYLShowFaceViewType) {
    CYLShowEmojiFace = 0,
    CYLShowRecentFace,
    CYLShowGifFace,
};
#define kCYLTopLineBackgroundColor [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f]

@protocol CYLChatFaceViewDelegate <NSObject>

- (void)faceViewSendFace:(NSString *)faceName;

@end

@interface CYLChatFaceView : UIView

@property (weak, nonatomic) id<CYLChatFaceViewDelegate> delegate;
@property (assign, nonatomic) CYLShowFaceViewType faceViewType;

@end
