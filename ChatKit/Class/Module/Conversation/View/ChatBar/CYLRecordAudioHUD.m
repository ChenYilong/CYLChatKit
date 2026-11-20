//
//  CYLRecordAudioHUD.m
//  CYLChatBarExample
//
//  Created by alex-W on 2017/6/7.
//  Copyright © 2017年 http://codewpf.com/ . All rights reserved.
//

#import "CYLRecordAudioHUD.h"
#import "UIImage+CYLExtension.h"
#import "UIColor+CYLExtension.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

// 录音总时间
const NSInteger CYLRecordMAXTime = 60;
// Title 文字颜色
NSString *const CYLCancelStateTextColor = @"e5e5e5ff";
NSString *const CYLNormalStateTextColor = @"ffffffff";

// 结束 提示文字
NSString *const CYLRecoderResultStateFailTitle = @"转换音频格式失败";
NSString *const CYLRecoderResultStateShortTitle = @"说话时间太短";
NSString *const CYLRecoderResultStateLongTitle = @"说话时间超长";
// 状态 提示文字
NSString *const CYLRecordProgressStateOutSideTitle = @"松开手指，取消发送";
NSString *const CYLRecordProgressStateInSideTitle = @"手指上滑，取消发送";



@interface CYLRecordAudioHUD ()
@property (nonatomic, assign) NSInteger seconds;
@property (nonatomic, assign) CYLRecordResultState resultState;
@property (nonatomic, assign) CYLRecordProgressState progressState;

/** 倒计时 */
@property (nonatomic, strong) NSTimer *timer;

/** 整体控件 黑色透明背景图片 */
@property (nonatomic, strong) UIImageView *bgIV;

/** 提示标题 背景图片 */
@property (nonatomic, strong) UIImageView *titleIV;
/** 提示标题 文本 */
@property (nonatomic, strong) UILabel *titleLabel;

/** 倒计时 文本 */
@property (nonatomic, strong) UILabel *countDownLabel;
/** 警告 图片 */
@property (nonatomic, strong) UIImageView *warningIV;
/** 取消 图片 */
@property (nonatomic, strong) UIImageView *cancelIV;

/** 正常录音 背景 */
@property (nonatomic, strong) UIView *recordBg;
/** 正常录音 麦克风图片  */
@property (nonatomic, strong) UIImageView *microPhoneIV;
/** 正常录音 音量图片 */
@property (nonatomic, strong) UIImageView *volumeLevelIV;

@end


@implementation CYLRecordAudioHUD
#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    // 只需要初始化子控件
    [self titleIV];
    [self titleLabel];
    [self countDownLabel];
    [self warningIV];
    [self cancelIV];
    [self microPhoneIV];
    [self volumeLevelIV];
    
    [self renew];
}

#pragma mark - Private Mehods
- (void)renew {
    self.seconds = 0;
    self.recordBg.hidden = NO;
    self.warningIV.hidden = YES;
    self.cancelIV.hidden = YES;
    self.titleIV.hidden = YES;
    self.countDownLabel.hidden = YES;
    self.titleLabel.text = CYLRecordProgressStateInSideTitle;
    self.countDownLabel.text = [NSString stringWithFormat:@"%ld",CYLRecordMAXTime-self.seconds];
}
- (void)show {    [self timer];
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    _showing = YES;
}

- (void)dismissWithDelay:(BOOL)delay {
    if(!_timer) return;
    _showing = NO;
    NSInteger delayTime = 0;
    if(delay) {
        delayTime = 1.5;
    }
    if(_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(self.superview) {
            [self removeFromSuperview];
            [self renew];
        }
    });
    
}
- (void)timerAction {
    self.seconds++;
    self.countDownLabel.text = [NSString stringWithFormat:@"%ld",CYLRecordMAXTime-self.seconds];
    
    if(CYLRecordMAXTime-self.seconds < 10 && self.cancelIV.hidden == YES) {
        self.countDownLabel.hidden = NO;
        self.recordBg.hidden = YES;
    }
    
    if(self.seconds == CYLRecordMAXTime) {
        [self setResultState:CYLRecoderResultStateLong];
        [[NSNotificationCenter defaultCenter] postNotificationName:kCYLRecordAudioTooLong object:nil];
    }
    
}
#pragma mark - Setters
- (void)setResultState:(CYLRecordResultState)resultState {
    if(self.isShowing == NO) return;
    
    if(resultState == CYLRecoderResultStateSuccess ||
       resultState == CYLRecoderResultStateCancel) {
        [self dismissWithDelay:NO];
    } else {
        self.recordBg.hidden = YES;
        self.cancelIV.hidden = YES;
        self.countDownLabel.hidden = YES;
        self.warningIV.hidden = NO;
        if(resultState == CYLRecoderResultStateFail) {
            self.titleLabel.text = CYLRecoderResultStateFailTitle;
        } else if(resultState == CYLRecoderResultStateShort){
            self.titleLabel.text = CYLRecoderResultStateShortTitle;
        } else if(resultState == CYLRecoderResultStateLong) {
            self.titleLabel.text = CYLRecoderResultStateLongTitle;
        }
        [self dismissWithDelay:YES];
    }
}

- (void)setProgressState:(CYLRecordProgressState)progressState {
    if(self.isShowing == NO) return;

    switch (progressState) {
        case CYLRecordProgressStateOutSide:
            self.titleLabel.text = CYLRecordProgressStateOutSideTitle;
            self.titleIV.hidden = NO;
            self.cancelIV.hidden = NO;
            self.recordBg.hidden = YES;
            self.countDownLabel.hidden = YES;
            self.titleLabel.textColor = [UIColor CJ_16_Color:CYLCancelStateTextColor];
            break;
        case CYLRecordProgressStateInSide:
            self.titleLabel.text = CYLRecordProgressStateInSideTitle;
            self.titleIV.hidden = YES;
            self.cancelIV.hidden = YES;
            if(self.seconds > CYLRecordMAXTime - 10) {
                self.countDownLabel.hidden = NO;
            } else {
                self.recordBg.hidden = NO;
            }
            self.titleLabel.textColor = [UIColor CJ_16_Color:CYLNormalStateTextColor];
            break;
    }
}


#pragma mark - Getters
- (NSTimer *)timer {
    if(_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:1
                                              target:self
                                            selector:@selector(timerAction)
                                            userInfo:nil
                                             repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    return _timer;
}

- (UIImageView *)bgIV {
    if(!_bgIV) {
        _bgIV = [UIImageView new];
        _bgIV.image = [self imageInBundlePathForImageName:@"chat_record_allbg"];
        [_bgIV sizeToFit];
        [self addSubview:_bgIV];
        [_bgIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    return _bgIV;
}

- (UIImageView *)titleIV {
    if(!_titleIV) {
        _titleIV = [[UIImageView alloc] initWithFrame:CGRectMake(7.5f, 117, 135, 25)];
        _titleIV.image = [self imageInBundlePathForImageName:@"chat_record_titlebg"];
        _titleIV.hidden = YES;
        [self.bgIV addSubview:_titleIV];
    }
    return _titleIV;
}
- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.5f, 117, 135, 25)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor CJ_16_Color:CYLNormalStateTextColor];
        [self.bgIV addSubview:_titleLabel];
    }
    return _titleLabel;
}
- (UILabel *)countDownLabel {
    if(!_countDownLabel){
        _countDownLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 16, 100, 100)];
        _countDownLabel.textAlignment = NSTextAlignmentCenter;
        _countDownLabel.font = [UIFont systemFontOfSize:80];
        _countDownLabel.textColor = [UIColor CJ_16_Color:CYLNormalStateTextColor];
        _countDownLabel.hidden = YES;
        [self.bgIV addSubview:_countDownLabel];
    }
    return _countDownLabel;
}

- (UIImageView *)warningIV {
    if(!_warningIV) {
        _warningIV = [[UIImageView alloc] initWithFrame:CGRectMake(71.5, 41.5f, 7, 55)];
        _warningIV.image = [self imageInBundlePathForImageName:@"chat_record_warning"];
        _warningIV.hidden = YES;
        [self.bgIV addSubview:_warningIV];
    }
    return _warningIV;
}

- (UIImageView *)cancelIV {
    if(!_cancelIV) {
        _cancelIV = [[UIImageView alloc] initWithFrame:CGRectMake(49, 41, 52, 52)];
        _cancelIV.image = [self imageInBundlePathForImageName:@"chat_record_cancel"];
        _cancelIV.hidden = YES;
        [self.bgIV addSubview:_cancelIV];
    }
    return _cancelIV;
}

- (UIView *)recordBg {
    if(!_recordBg) {
        _recordBg = [[UIView alloc] initWithFrame:CGRectMake(42, 30, 66, 66)];
        _recordBg.backgroundColor = [UIColor clearColor];
        _recordBg.hidden = YES;
        [self.bgIV addSubview:_recordBg];
    }
    return _recordBg;
}

- (UIImageView *)microPhoneIV {
    if(!_microPhoneIV) {
        _microPhoneIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 39, 66)];
        _microPhoneIV.image = [self imageInBundlePathForImageName:@"chat_record_microphone"];
        [self.recordBg addSubview:_microPhoneIV];
    }
    return _microPhoneIV;
}

- (UIImageView *)volumeLevelIV {
    if(!_volumeLevelIV) {
        _volumeLevelIV = [[UIImageView alloc] initWithFrame:CGRectMake(48, 15, 18, 51)];
        _volumeLevelIV.image = [self imageInBundlePathForImageName:@"chat_record_volume_0"];
        [self.recordBg addSubview:_volumeLevelIV];
    }
    return _volumeLevelIV;
}

- (UIImage *)imageInBundlePathForImageName:(NSString *)imageName {
    UIImage *image = [UIImage cyl_imageNamed:imageName bundleName:@"CYLRecordAudioHUD" bundleForClass:[self class]];
    return image;
}

#pragma mark - Class Methods
+ (CYLRecordAudioHUD *)instance {
    static dispatch_once_t onceToken;
    static CYLRecordAudioHUD *_instace;
    dispatch_once(&onceToken, ^{
        _instace = [[CYLRecordAudioHUD alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
        _instace.backgroundColor = [UIColor clearColor];
        
    });
    return _instace;
}

/**
显示录音指示器
*/
+ (void)show {
    [[CYLRecordAudioHUD instance] show];
}

/**
 隐藏录音指示器，根据结果
 
 @param recderState 结果
 */
+ (void)dismissWithState:(CYLRecordResultState)resultState {
    [[CYLRecordAudioHUD instance] setResultState:resultState];
}

/**
 修改录音指示器，根据状态
 
 @param progressState 状态
 */
+ (void)changeProgressState:(CYLRecordProgressState)progressState {
    [[CYLRecordAudioHUD instance] setProgressState:progressState];
}

/**
 修改音量
 
 @param level 音量 0 - 120
 */
+ (void)changeVolume:(NSInteger)level {
    // 转换为 0~8
    NSInteger l = level/10 - 2;
    if(l < 0) l = 0;
    if(l > 8) l = 8;
    [CYLRecordAudioHUD instance].volumeLevelIV.image = [[CYLRecordAudioHUD instance] imageInBundlePathForImageName:[NSString stringWithFormat:@"chat_record_volume_%ld",l]];
}

+ (NSInteger)seconds{
    return [[CYLRecordAudioHUD instance] seconds];
}




@end
