//
//  CYLRecordAudioHUD.h
//  CYLChatBarExample
//
//  Created by alex-W on 2017/6/7.
//  Copyright © 2017年 http://codewpf.com/ . All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCYLRecordAudioTooLong @"kCYLRecordAudioTooLong"

/**
 音频记录结果

 - CYLRecoderResultStateSuccess: 成功
 - CYLRecoderResultStateFail: 失败 转换音频格式错误
 - CYLRecoderResultStateShort: 失败 音频时长太短不发送
 - CYLRecoderResultStateLong: 成功 音频时长太长结束并发送
 - CYLRecoderResultStateCancel: 取消
 */
typedef NS_ENUM(NSUInteger, CYLRecordResultState) {
    CYLRecoderResultStateSuccess ,
    CYLRecoderResultStateFail ,
    CYLRecoderResultStateShort ,
    CYLRecoderResultStateLong ,
    CYLRecoderResultStateCancel ,
};


/**
 音频记录状态

 - CYLRecordProgressStateOutSide: 手指松开，取消发送
 - CYLRecordProgressStateInSide: 手指上滑，取消发送
 */
typedef NS_ENUM(NSUInteger, CYLRecordProgressState) {
    CYLRecordProgressStateOutSide,
    CYLRecordProgressStateInSide,
};

@interface CYLRecordAudioHUD : UIView
/** 是否正在显示 */
@property (nonatomic, assign, readonly, getter=isShowing) BOOL showing;
/**
 HUD 单例

 @return 单例
 */
+ (CYLRecordAudioHUD *)instance;

/**
 显示录音指示器
 */
+ (void)show;

/**
 隐藏录音指示器，根据结果

 @param recderState 结果
 */
+ (void)dismissWithState:(CYLRecordResultState)resultState;


/**
 修改录音指示器，根据状态

 @param progressState 状态
 */
+ (void)changeProgressState:(CYLRecordProgressState)progressState;


/**
 修改音量

 @param level 音量
 */
+ (void)changeVolume:(NSInteger)level;


/**
 录音总时间

 @return 录音总时间
 */
+ (NSInteger)seconds;

@end



