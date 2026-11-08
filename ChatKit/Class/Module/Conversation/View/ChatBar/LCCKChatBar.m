//
//  LCCKChatBar.m
//  LCCKChatBarExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/8/17.
//  Copyright (c) 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//

#import "LCCKChatBar.h"
#import "LCCKChatMoreView.h"
#import "LCCKChatFaceView.h"
#import "LCCKProgressHUD.h"
#import "Mp3Recorder.h"
#import <AVFoundation/AVFoundation.h>
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#import "LCCKUIService.h"
#import "UIImage+LCCKExtension.h"
#import "NSString+LCCKExtension.h"
#import "LCCKConversationService.h"

NSString *const kLCCKBatchDeleteTextPrefix = @"kLCCKBatchDeleteTextPrefix";
NSString *const kLCCKBatchDeleteTextSuffix = @"kLCCKBatchDeleteTextSuffix";

@interface LCCKChatBar () <UITextViewDelegate, UINavigationControllerDelegate, Mp3RecorderDelegate, LCCKChatFaceViewDelegate>

@property (strong, nonatomic) Mp3Recorder *MP3;
@property (strong, nonatomic) NSTimer *recordingTimeoutTimer;
@property (assign, nonatomic) BOOL recordingDidReachTimeLimit;
@property (assign, nonatomic) BOOL recordButtonTracking;
@property (assign, nonatomic, getter=isRecording) BOOL recording;
@property (nonatomic, strong) UIView *inputBarBackgroundView; /**< 输入栏目背景视图 */
@property (strong, nonatomic) UIButton *voiceButton; /**< 切换录音模式按钮 */
@property (strong, nonatomic) UIButton *voiceRecordButton; /**< 录音按钮 */

@property (strong, nonatomic) UIButton *faceButton; /**< 表情按钮 */
@property (strong, nonatomic) UIButton *moreButton; /**< 更多按钮 */
@property (weak, nonatomic) LCCKChatFaceView *faceView; /**< 当前活跃的底部view,用来指向faceView */
@property (weak, nonatomic) LCCKChatMoreView *moreView; /**< 当前活跃的底部view,用来指向moreView */

@property (assign, nonatomic, readonly) CGFloat bottomHeight;
@property (strong, nonatomic, readonly) UIViewController *rootViewController;

@property (assign, nonatomic) CGSize keyboardSize;

@property (assign, nonatomic) CGFloat oldTextViewHeight;
@property (nonatomic, assign, getter=shouldAllowTextViewContentOffset) BOOL allowTextViewContentOffset;
@property (nonatomic, assign, getter=isClosed) BOOL close;
@property (nonatomic, assign) CGFloat volumeTimeLength;

#pragma mark - MessageInputView Customize UI
///=============================================================================
/// @name MessageInputView Customize UI
///=============================================================================

@property (nonatomic, strong) UIColor *messageInputViewBackgroundColor;
@property (nonatomic, strong) UIColor *messageInputViewTextFieldTextColor;
@property (nonatomic, strong) UIColor *messageInputViewTextFieldBackgroundColor;
@property (nonatomic, strong) UIColor *messageInputViewRecordTextColor;
//TODO:MessageInputView-Tint-Color
@property (nonatomic, strong) NSMutableSet<NSString *> *mentionSet;

@end

@implementation LCCKChatBar

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setupConstraints {
    CGFloat offset = 5 * 2;
    [self.inputBarBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self).priorityLow();
    }];
    // Related iPhone X input-bar layout report: https://github.com/leancloud/ChatKit-OC/issues/361
    [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.inputBarBackgroundView.mas_left).with.offset(offset);
        make.bottom.equalTo(self.inputBarBackgroundView.mas_bottom).with.offset(-LCCKChatBarBottomOffset);
        make.width.equalTo(self.voiceButton.mas_height);
    }];
    
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.inputBarBackgroundView.mas_right).with.offset(-offset);
        make.bottom.equalTo(self.textView);
        //        make.centerY.equalTo(self.textView);
        make.width.equalTo(@(60));
        make.height.equalTo(@(kLCCKChatBarTextViewFrameMinHeight));
    }];
    
    [self.faceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.moreButton.mas_left).with.offset(-offset);
        make.bottom.equalTo(self.inputBarBackgroundView.mas_bottom).with.offset(-LCCKChatBarBottomOffset);
        make.width.equalTo(self.faceButton.mas_height);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.inputBarBackgroundView.mas_left).with.offset(offset);
        make.right.equalTo(self.moreButton.mas_left).with.offset(-offset);
        
        make.top.equalTo(self.inputBarBackgroundView).with.offset(LCCKChatBarTextViewBottomOffset);
        make.bottom.equalTo(self.inputBarBackgroundView).with.offset(-LCCKChatBarTextViewBottomOffset);
        make.height.mas_greaterThanOrEqualTo(kLCCKChatBarTextViewFrameMinHeight);
    }];
    
    CGFloat voiceRecordButtoInsets = -5.f;
    [self.voiceRecordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.textView).insets(UIEdgeInsetsMake(voiceRecordButtoInsets, voiceRecordButtoInsets, voiceRecordButtoInsets, voiceRecordButtoInsets));
    }];
    
    [self.faceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.left.mas_equalTo(self);
        make.height.mas_equalTo(kFunctionViewHeight);
        make.top.mas_equalTo(self.mas_bottom);
    }];
    
    [self.moreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.left.mas_equalTo(self);
        make.height.mas_equalTo(kFunctionViewHeight);
        make.top.mas_equalTo(self.mas_bottom);
    }];
}

- (void)dealloc {
    [self invalidateRecordingTimeoutTimer];
    self.delegate = nil;
    _faceView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark -
#pragma mark - Setter Method

- (void)setCachedText:(NSString *)cachedText {
    _cachedText = [cachedText copy];
    if ([_cachedText isEqualToString:@""]) {
        [self updateChatBarConstraintsIfNeededShouldCacheText:NO];
        self.allowTextViewContentOffset = YES;
        return;
    }
    if ([_cachedText lcck_isSpace]) {
        _cachedText = @"";
        return;
    }
}

- (UIViewController *)controllerRef {
    return (UIViewController *)self.delegate;
}

- (void)setDelegate:(id<LCCKChatBarDelegate>)delegate {
    _delegate = delegate;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (range.location == [textView.text length]) {
        self.allowTextViewContentOffset = YES;
    } else {
        self.allowTextViewContentOffset = NO;
    }
    
    //    if ([text isEqualToString:@"\n"]) {
    //        [self sendTextMessage:textView.text];
    //        return NO;
    //    } else
    
    if (text.length == 0){
        NSArray *defaultRegulations = @[
                                        //判断删除的文字是否符合表情文字规则
                                        @{
                                            kLCCKBatchDeleteTextPrefix : @"[",
                                            kLCCKBatchDeleteTextSuffix : @"]",
                                            },
                                        //判断删除的文字是否符合提醒群成员的文字规则
                                        @{
                                            kLCCKBatchDeleteTextPrefix : @"@",
                                            kLCCKBatchDeleteTextSuffix : @" ",
                                            },
                                        ];
        NSArray *additionRegulation;
        if ([self.delegate respondsToSelector:@selector(regulationForBatchDeleteText)]) {
            additionRegulation = [self.delegate regulationForBatchDeleteText];
        }
        if (additionRegulation.count > 0) {
            defaultRegulations = [defaultRegulations arrayByAddingObjectsFromArray:additionRegulation];
        }
        for (NSDictionary *regulation in defaultRegulations) {
            NSString *prefix = regulation[kLCCKBatchDeleteTextPrefix];
            NSString *suffix = regulation[kLCCKBatchDeleteTextSuffix];
            if (![self textView:textView shouldChangeTextInRange:range deleteBatchOfTextWithPrefix:prefix suffix:suffix]) {
                return  NO;
            }
        }
        return YES;
    } else if ([text isEqualToString:@"@"]) {
        if ([self.delegate respondsToSelector:@selector(didInputAtSign:)]) {
            [self.delegate didInputAtSign:self];
        }
        return YES;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 0) {
//        [self.moreButton cyl_setHighlighted:YES];
    } else {
//        [self.moreButton cyl_setHighlighted:NO];
    }
    [self textViewDidChange:textView shouldCacheText:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range deleteBatchOfTextWithPrefix:(NSString *)prefix
          suffix:(NSString *)suffix {
    NSString *substringOfText = [textView.text substringWithRange:range];
    if ([substringOfText isEqualToString:suffix]) {
        NSUInteger location = range.location;
        NSUInteger length = range.length;
        NSString *subText;
        while (YES) {
            if (location == 0) {
                return YES;
            }
            location -- ;
            length ++ ;
            subText = [textView.text substringWithRange:NSMakeRange(location, length)];
            if (([subText hasPrefix:prefix] && [subText hasSuffix:suffix])) {
                //这里注意，批量删除的字符串，除了前缀和后缀，中间不能有空格出现
                NSString *string = [textView.text substringWithRange:NSMakeRange(location, length-1)];
                if (![string lcck_containsString:@" "]) {
                    break;
                }
            }
        }
        
        if ([prefix isEqualToString:@"@"] && [suffix isEqualToString:@" "]) {
            NSString *atPeerId = [textView.text substringWithRange:NSMakeRange(location, length)];
            NSString *peerId = [[atPeerId substringToIndex:atPeerId.length - 1] substringFromIndex:1];
            [self.mentionSet removeObject:peerId];
        }
        
        textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
        [textView setSelectedRange:NSMakeRange(location, 0)];
        [self textViewDidChange:self.textView];
        return NO;
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.faceButton.selected = self.moreButton.selected = self.voiceButton.selected = NO;
    [self showFaceView:NO];
    [self showMoreView:NO];
    [self showVoiceView:NO];
    return YES;
}

#pragma mark -
#pragma mark - Private Methods

- (void)updateChatBarConstraintsIfNeeded {
    NSString *reason = [NSString stringWithFormat:@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"Should update on main thread"];
    NSAssert([NSThread mainThread], reason);
    BOOL shouldCacheText = NO;
    BOOL shouldScrollToBottom = YES;
    LCCKFunctionViewShowType functionViewShowType = self.showType;
    switch (functionViewShowType) {
        case LCCKFunctionViewShowNothing: {
            shouldScrollToBottom = NO;
            shouldCacheText = YES;
        }
            break;
        case LCCKFunctionViewShowFace:
        case LCCKFunctionViewShowMore:
        case LCCKFunctionViewShowKeyboard: {
            shouldCacheText = YES;
        }
            break;
        case LCCKFunctionViewShowVoice:
            shouldCacheText = NO;
            break;
    }
    [self updateChatBarConstraintsIfNeededShouldCacheText:shouldCacheText];
    [self chatBarFrameDidChangeShouldScrollToBottom:shouldScrollToBottom];
}

- (void)updateChatBarConstraintsIfNeededShouldCacheText:(BOOL)shouldCacheText {
    [self textViewDidChange:self.textView shouldCacheText:shouldCacheText];
}

- (void)updateChatBarKeyBoardConstraints {
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-self.keyboardSize.height);
    }];
    [UIView animateWithDuration:LCCKAnimateDuration animations:^{
        [self layoutIfNeeded];
    } completion:nil];
}

#pragma mark -
#pragma mark - Private Methods     #pragma mark - Private Methods

- (void)startRecordVoice {
    self.recordButtonTracking = YES;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (audioSession.recordPermission == AVAudioSessionRecordPermissionGranted) {
        [self beginRecordingVoice];
        return;
    }
    if (audioSession.recordPermission == AVAudioSessionRecordPermissionDenied) {
        self.recordButtonTracking = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:LCCKNotificationRecordNoPower object:nil];
        return;
    }

    // Do not start recording until the asynchronous authorization result is known.
    // https://github.com/leancloud/ChatKit-OC/issues/269
    __weak typeof(self) weakSelf = self;
    [audioSession requestRecordPermission:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) {
                return;
            }
            if (!granted) {
                self.recordButtonTracking = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:LCCKNotificationRecordNoPower object:nil];
                return;
            }
            // Permission dialogs interrupt the original hold gesture. Require a new explicit press
            // so tapping "Allow" cannot start an accidental zero-length recording.
            // https://github.com/leancloud/ChatKit-OC/issues/269
            self.recordButtonTracking = NO;
        });
    }];
}

#pragma mark - 核心方法
///=============================================================================
/// @name 核心方法
///=============================================================================

/*!
 * updateChatBarConstraintsIfNeeded: WhenTextViewHeightDidChanged
 * 只要文本修改了就会调用，特殊情况，也会调用：刚刚进入对话追加草稿、键盘类型切换、添加表情信息
 */
- (void)textViewDidChange:(UITextView *)textView
          shouldCacheText:(BOOL)shouldCacheText {
    if (shouldCacheText) {
        self.cachedText = self.textView.text;
    }
    CGRect textViewFrame = self.textView.frame;
    CGSize textSize = [self.textView sizeThatFits:CGSizeMake(CGRectGetWidth(textViewFrame), 1000.0f)];
    // from iOS 7, the content size will be accurate only if the scrolling is enabled.
    textView.scrollEnabled = (textSize.height > kLCCKChatBarTextViewFrameMinHeight);
    // textView 控件的高度在 kLCCKChatBarTextViewFrameMinHeight 和 kLCCKChatBarMaxHeight-offset 之间
    CGFloat newTextViewHeight = MAX(kLCCKChatBarTextViewFrameMinHeight, MIN(kLCCKChatBarTextViewFrameMaxHeight, textSize.height));
    BOOL textViewHeightChanged = (self.oldTextViewHeight != newTextViewHeight);
    if (textViewHeightChanged) {
        //FIXME:如果有草稿，且超出了最低高度，会产生约束警告。
        self.oldTextViewHeight = newTextViewHeight;
        [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
            CGFloat height = newTextViewHeight;
            make.height.mas_equalTo(height);
        }];
        [self chatBarFrameDidChangeShouldScrollToBottom:YES];
    }
    
    void(^setContentOffBlock)() = ^() {
        if (textView.scrollEnabled && self.allowTextViewContentOffset) {
            if (newTextViewHeight == kLCCKChatBarTextViewFrameMaxHeight) {
                [textView setContentOffset:CGPointMake(0, textView.contentSize.height - newTextViewHeight) animated:YES];
            } else {
                [textView setContentOffset:CGPointZero animated:YES];
            }
        }
    };
    
    //FIXME:issue #178
    //在输入换行的时候，textView的内容向上偏移，再下次输入后恢复正常，原因是高度变化后，textView更新约束，重新设置了contentOffset；我是在设置contentOffset做了0.01秒的延迟，发现能解决这个问题
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        setContentOffBlock();
    });
}

#pragma mark - MP3RecordedDelegate

- (void)endConvertWithMP3FileName:(NSString *)fileName {
    self.recording = NO;
    self.recordButtonTracking = NO;
    [self invalidateRecordingTimeoutTimer];
    if (fileName) {
        [LCCKProgressHUD dismissWithProgressState:LCCKProgressSuccess];
        [self sendVoiceMessage:fileName seconds:[LCCKProgressHUD seconds]];
    } else {
        [LCCKProgressHUD dismissWithProgressState:LCCKProgressError];
    }
}

- (void)failRecord {
    self.recording = NO;
    self.recordButtonTracking = NO;
    [self invalidateRecordingTimeoutTimer];
    self.voiceRecordButton.selected = NO;
    self.voiceRecordButton.highlighted = NO;
    [LCCKProgressHUD dismissWithProgressState:LCCKProgressError];
}

- (void)beginConvert {
    [LCCKProgressHUD changeSubTitle:@"正在转换..."];
}

- (void)realTimeVolumeSize:(float)size timeLength:(NSTimeInterval)timeLength {
    [LCCKProgressHUD realtimeChangeVolumeImageView:size timeLength:timeLength];
    self.volumeTimeLength = MIN(MAX(timeLength, 0), kLCCKVolumeMaxTimeLength * 10) / 10.0;
    if (self.volumeTimeLength >= kLCCKVolumeMaxTimeLength) {
        [self recordingTimeLimitDidExpire];
    }
}

#pragma mark - LCCKChatFaceViewDelegate

- (void)faceViewSendFace:(NSString *)faceName {
    if ([faceName isEqualToString:@"[删除]"]) {
        [self textView:self.textView shouldChangeTextInRange:NSMakeRange(self.textView.text.length - 1, 1) replacementText:@""];
    } else if ([faceName isEqualToString:@"发送"]) {
        NSString *text = self.textView.text;
        if (!text || text.length == 0) {
            return;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:sendMessage:mentionList:)]) {
            [self.delegate chatBar:self sendMessage:text mentionList:@[]];
        }
        self.textView.text = @"";
        self.cachedText = @"";
        self.showType = LCCKFunctionViewShowFace;
    } else {
        [self appendString:faceName beginInputing:NO];
    }
}

#pragma mark - Public Methods

- (void)close {
    //关闭
    self.close = YES;
}

- (void)open {
    self.close = NO;
}

- (void)endInputing {
    if (self.voiceButton.selected) {
        return;
    }
    self.faceButton.selected = self.moreButton.selected = self.voiceButton.selected = NO;
    self.showType = LCCKFunctionViewShowNothing;
}

- (void)appendString:(NSString *)string beginInputing:(BOOL)beginInputing {
    self.allowTextViewContentOffset = YES;
    if (self.textView.text.length > 0 && [string hasPrefix:@"@"] && ![self.textView.text hasSuffix:@" "]) {
        self.textView.text = [self.textView.text stringByAppendingString:@" "];
    }
    NSString *textViewText;
    //特殊情况：处于语音按钮显示时，self.textView.text无信息，但self.cachedText有信息
    if (self.textView.text.length == 0 && self.cachedText.length > 0) {
        textViewText = self.cachedText;
    } else {
        textViewText = self.textView.text;
    }
    NSString *appendedString = [textViewText stringByAppendingString:string];
    self.cachedText = appendedString;
    self.textView.text = appendedString;
    if (beginInputing && self.keyboardSize.height == 0) {
        [self beginInputing];
    } else {
        [self updateChatBarConstraintsIfNeeded];
    }
}

- (void)appendString:(NSString *)string {
    [self appendString:string beginInputing:YES];
}

- (void)appendString:(NSString *)string mentionList:(NSArray<NSString *> *)mentionList
{
    [self.mentionSet addObjectsFromArray:mentionList];
    [self appendString:string beginInputing:YES];
}

- (void)beginInputing {
    [self.textView becomeFirstResponder];
}

#pragma mark - Private Methods

- (void)keyboardWillHide:(NSNotification *)notification {
    NSString *reason = [NSString stringWithFormat:@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"Should update on main thread"];
    NSAssert([NSThread mainThread], reason);
    if (self.isClosed) {
        return;
    }
    self.keyboardSize = CGSizeZero;
    if (_showType == LCCKFunctionViewShowKeyboard) {
        _showType = LCCKFunctionViewShowNothing;
    }
    [self updateChatBarKeyBoardConstraints];
    [self updateChatBarConstraintsIfNeeded];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSString *reason = [NSString stringWithFormat:@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"Should update on main thread"];
    NSAssert([NSThread mainThread], reason);
    if (self.isClosed) {
        return;
    }
    CGFloat oldHeight = self.keyboardSize.height;
    self.keyboardSize = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //兼容搜狗输入法：一次键盘事件会通知两次，且键盘高度不一。
    if (self.keyboardSize.height != oldHeight) {
        _showType = LCCKFunctionViewShowNothing;
    }
    if (self.keyboardSize.height == 0) {
        _showType = LCCKFunctionViewShowNothing;
        return;
    }
    self.allowTextViewContentOffset = YES;
    [self updateChatBarKeyBoardConstraints];
    self.showType = LCCKFunctionViewShowKeyboard;
}

/**
 *  lazy load inputBarBackgroundView
 *
 *  @return UIView
 */
- (UIView *)inputBarBackgroundView {
    if (_inputBarBackgroundView == nil) {
        UIView *inputBarBackgroundView = [[UIView alloc] init];
        _inputBarBackgroundView = inputBarBackgroundView;
    }
    return _inputBarBackgroundView;
}

- (void)setup {
    self.close = NO;
    self.oldTextViewHeight = kLCCKChatBarTextViewFrameMinHeight;
    self.allowTextViewContentOffset = YES;
    self.MP3 = [[Mp3Recorder alloc] initWithDelegate:self];
    [self faceView];
    [self moreView];
    [self addSubview:self.inputBarBackgroundView];
    
    [self.inputBarBackgroundView addSubview:self.voiceButton];
    [self.inputBarBackgroundView addSubview:self.moreButton];
    [self.inputBarBackgroundView addSubview:self.faceButton];
    [self.inputBarBackgroundView addSubview:self.textView];
    [self.inputBarBackgroundView addSubview:self.voiceRecordButton];
    
    UIImageView *topLine = [[UIImageView alloc] init];
    topLine.backgroundColor = kLCCKTopLineBackgroundColor;
    [self.inputBarBackgroundView addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.equalTo(self.inputBarBackgroundView);
        make.height.mas_equalTo(.5f);
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(confirmRecordVoice) name:kLCCKRecordAudioTooLong object:nil];
    //修复录音时点击Home键 在返回App后 仍然显示录音动效的问题
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeBackgroundCancelRecordVoice) name:UIApplicationDidEnterBackgroundNotification object:nil];
    self.backgroundColor = self.messageInputViewBackgroundColor;
    [self setupConstraints];
    self.mentionSet = [NSMutableSet set];
}


- (void)beginRecordingVoice {
    if (!self.recordButtonTracking || self.isRecording) {
        return;
    }
    self.recordingDidReachTimeLimit = NO;
    self.volumeTimeLength = 0;
    self.recording = YES;
    self.voiceRecordButton.selected = YES;
    [LCCKProgressHUD show];

    NSTimer *timer = [NSTimer timerWithTimeInterval:kLCCKVolumeMaxTimeLength
                                             target:self
                                           selector:@selector(recordingTimeoutTimerDidFire:)
                                           userInfo:nil
                                            repeats:NO];
    self.recordingTimeoutTimer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [self.MP3 startRecord];
}

- (void)cancelRecordVoice {
    self.recordButtonTracking = NO;
    [self invalidateRecordingTimeoutTimer];
    if (!self.isRecording) {
        return;
    }
    self.recording = NO;
    self.voiceRecordButton.selected = NO;
    self.voiceRecordButton.highlighted = NO;
    [LCCKProgressHUD dismissWithMessage:@"取消录音"];
    [self.MP3 cancelRecord];
}

- (void)confirmRecordVoice {
    self.recordButtonTracking = NO;
    if (!self.isRecording) {
        return;
    }
    [self invalidateRecordingTimeoutTimer];
    self.recording = NO;
    self.voiceRecordButton.selected = NO;
    self.voiceRecordButton.highlighted = NO;
    [self.MP3 stopRecord];
}

- (void)recordingTimeLimitDidExpire {
    if (!self.isRecording || self.recordingDidReachTimeLimit) {
        return;
    }
    [self invalidateRecordingTimeoutTimer];
    self.recordingDidReachTimeLimit = YES;
    self.recording = NO;
    self.recordButtonTracking = NO;
    self.voiceRecordButton.selected = NO;
    self.voiceRecordButton.highlighted = NO;
    // Stop at the supported maximum instead of allowing an unbounded negative countdown.
    // https://github.com/leancloud/ChatKit-OC/issues/414
    [self.MP3 stopRecord];
}

- (void)recordingTimeoutTimerDidFire:(NSTimer *)timer {
    if (timer == self.recordingTimeoutTimer) {
        [self recordingTimeLimitDidExpire];
    }
}

- (void)invalidateRecordingTimeoutTimer {
    [self.recordingTimeoutTimer invalidate];
    self.recordingTimeoutTimer = nil;
}

- (void)updateCancelRecordVoice {
    if (self.isRecording) {
        [LCCKProgressHUD changeSubTitle:@"松开手指,取消发送"];
    }
}

- (void)updateContinueRecordVoice {
    if (self.isRecording) {
        [LCCKProgressHUD changeSubTitle:@"手指上滑,取消发送"];
    }
}

- (void)setShowType:(LCCKFunctionViewShowType)showType {
    if (_showType == showType) {
        return;
    }
    _showType = showType;
    //显示对应的View
    [self showMoreView:showType == LCCKFunctionViewShowMore && self.moreButton.selected];
    [self showVoiceView:showType == LCCKFunctionViewShowVoice && self.voiceButton.selected];
    [self showFaceView:showType == LCCKFunctionViewShowFace && self.faceButton.selected];
    
    switch (showType) {
        case LCCKFunctionViewShowNothing: {
            self.textView.text = self.cachedText;
            [self.textView resignFirstResponder];
        }
            break;
        case LCCKFunctionViewShowVoice: {
            self.cachedText = self.textView.text;
            self.textView.text = nil;
            [self.textView resignFirstResponder];
        }
            break;
        case LCCKFunctionViewShowMore:
        case LCCKFunctionViewShowFace:
            self.textView.text = self.cachedText;
            [self.textView resignFirstResponder];
            break;
        case LCCKFunctionViewShowKeyboard:
            self.textView.text = self.cachedText;
            break;
    }
    [self updateChatBarConstraintsIfNeeded];
    if (@available(iOS 11.0, *) && CYL_IS_iPHONEX) {
        [self safeAreaInsetsDidChange];
    }
}

- (void)buttonAction:(UIButton *)button {
    if (self.textView.text.length > 0) {
        [self sendTextMessage:self.textView.text];
    }
}

- (void)showFaceView:(BOOL)show {
    if (show) {
        self.faceView.hidden = NO;
        [UIView animateWithDuration:LCCKAnimateDuration animations:^{
            [self.faceView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.superview.mas_bottom).offset(-kFunctionViewHeight);
            }];
            [self.faceView layoutIfNeeded];
        } completion:nil];
        
        [self.faceView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.inputBarBackgroundView.mas_bottom);
        }];
    } else if (self.faceView.superview) {
        self.faceView.hidden = YES;
        [self.faceView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.and.left.mas_equalTo(self);
            make.height.mas_equalTo(kFunctionViewHeight);
            make.top.mas_equalTo(self.mas_bottom);
        }];
        [self.faceView layoutIfNeeded];
    }
}

- (void)destroyAVAudioPlayer {
    [[LCCKAVAudioPlayer sharePlayer] stopAudioPlayer];
    [LCCKAVAudioPlayer sharePlayer].identifier = nil;
    [LCCKAVAudioPlayer sharePlayer].URLString = nil;
}

/**
 *  显示moreView
 *  @param show 要显示的moreView
 */
- (void)showMoreView:(BOOL)show {
    if (show) {
        self.moreView.hidden = NO;
        // Related report about the image-selection panel's constraints: https://github.com/leancloud/ChatKit-OC/issues/327
        [UIView animateWithDuration:LCCKAnimateDuration animations:^{
            [self.moreView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.superview.mas_bottom).offset(-kFunctionViewHeight);
            }];
            [self.moreView layoutIfNeeded];
        } completion:nil];
        
        [self.moreView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.inputBarBackgroundView.mas_bottom);
        }];
    } else if (self.moreView.superview) {
        self.moreView.hidden = YES;
        [self.moreView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.and.left.mas_equalTo(self);
            make.height.mas_equalTo(kFunctionViewHeight);
            make.top.mas_equalTo(self.mas_bottom);
        }];
        [self.moreView layoutIfNeeded];
    }
}

- (void)showVoiceView:(BOOL)show {
    //    self.voiceButton.selected = show;
    //    self.voiceRecordButton.selected = !show;
    //    self.voiceRecordButton.hidden = !show;
    //    self.textView.hidden = !self.voiceRecordButton.hidden;
}

/**
 *  发送普通的文本信息,通知代理
 *
 *  @param text 发送的文本信息
 */
- (void)sendTextMessage:(NSString *)text{
    if (!text || text.length == 0 || [text lcck_isSpace]) {
        return;
    }
    
    if (text.length > LCCKNotificationTextLengthOutLength) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LCCKNotificationTextLengthOut object:nil];
        return;
    }
    NSArray<NSString *> *mentionList = self.mentionSet.allObjects;
    [self.mentionSet removeAllObjects];
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:sendMessage:mentionList:)]) {
        [self.delegate chatBar:self sendMessage:text mentionList:mentionList];
    }
    self.textView.text = @"";
    self.cachedText = @"";
    self.showType = LCCKFunctionViewShowKeyboard;
//    [self.moreButton LCCK_setHighlighted:NO];
}

- (void)sendVoiceMessage:(NSString *)voiceFileName seconds:(NSTimeInterval)seconds {
    //    if ((seconds > 0) && self.delegate && [self.delegate respondsToSelector:@selector(chatBar:sendVoice:seconds:)]) {
    //        [self.delegate chatBar:self sendVoice:voiceFileName seconds:seconds];
    //    }
}

/**
 *  通知代理发送图片信息
 *
 *  @param image 发送的图片
 */
- (void)sendImageMessage:(UIImage *)image {
    //    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:sendPictures:)]) {
    //        [self.delegate chatBar:self sendPictures:@[image]];
    //    }
}

- (void)chatBarFrameDidChangeShouldScrollToBottom:(BOOL)shouldScrollToBottom {
    NSString *reason = [NSString stringWithFormat:@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"Should update on main thread"];
    NSAssert([NSThread mainThread], reason);
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarFrameDidChange:shouldScrollToBottom:)]) {
        [self.delegate chatBarFrameDidChange:self shouldScrollToBottom:shouldScrollToBottom];
    }
}

- (UIImage *)imageInBundlePathForImageName:(NSString *)imageName {
    UIImage *image = [UIImage lcck_imageNamed:imageName bundleName:@"ChatKeyboard" bundleForClass:[self class]];
    return image;
}

#pragma mark - Getters

- (LCCKChatFaceView *)faceView {
    if (!_faceView) {
        LCCKChatFaceView *faceView = [[LCCKChatFaceView alloc] init];
        faceView.delegate = self;
        faceView.hidden = YES;
        faceView.backgroundColor = self.backgroundColor;
        [self addSubview:(_faceView = faceView)];
    }
    return _faceView;
}

- (LCCKChatMoreView *)moreView {
    if (!_moreView) {
        LCCKChatMoreView *moreView = [[LCCKChatMoreView alloc] init];
        moreView.inputViewRef = self;
        moreView.hidden = YES;
        [self addSubview:(_moreView = moreView)];
    }
    return _moreView;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:16.0f];
        _textView.delegate = self;
        //        _textView.placehodler;
        _textView.layer.cornerRadius = 4.0f;
        _textView.textColor = self.messageInputViewTextFieldTextColor;
        _textView.backgroundColor = self.messageInputViewTextFieldBackgroundColor;
        _textView.layer.borderColor = [UIColor colorWithRed:204.0/255.0f green:204.0/255.0f blue:204.0/255.0f alpha:1.0f].CGColor;
        //        _textView.returnKeyType = UIReturnKeyDefault;
        _textView.layer.borderWidth = .5f;
        _textView.layer.masksToBounds = YES;
        _textView.scrollsToTop = NO;
    }
    return _textView;
}

- (UIButton *)voiceButton {
    if (!_voiceButton) {
        _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceButton.tag = LCCKFunctionViewShowVoice;
        [_voiceButton setTitleColor:self.messageInputViewRecordTextColor forState:UIControlStateNormal];
        [_voiceButton setTitleColor:self.messageInputViewRecordTextColor forState:UIControlStateHighlighted];
        [_voiceButton setBackgroundImage:[self imageInBundlePathForImageName:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        [_voiceButton setBackgroundImage:[self imageInBundlePathForImageName:@"ToolViewKeyboard"] forState:UIControlStateSelected];
        [_voiceButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        _voiceButton.hidden = YES;
        [_voiceButton sizeToFit];
    }
    return _voiceButton;
}

- (UIButton *)voiceRecordButton {
    if (!_voiceRecordButton) {
        _voiceRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceRecordButton.hidden = YES;
        _voiceRecordButton.frame = self.textView.bounds;
        _voiceRecordButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_voiceRecordButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(9, 9, 9, 9);
        UIImage *voiceRecordButtonNormalBackgroundImage = [[self imageInBundlePathForImageName:@"VoiceBtn_Black"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
        UIImage *voiceRecordButtonHighlightedBackgroundImage = [[self imageInBundlePathForImageName:@"VoiceBtn_BlackHL"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
        [_voiceRecordButton setBackgroundImage:voiceRecordButtonNormalBackgroundImage forState:UIControlStateNormal];
        [_voiceRecordButton setBackgroundImage:voiceRecordButtonHighlightedBackgroundImage forState:UIControlStateSelected];
        _voiceRecordButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_voiceRecordButton setTitle:@"按住 说话" forState:UIControlStateNormal];
        [_voiceRecordButton setTitle:@"松开 结束" forState:UIControlStateSelected];
        [_voiceRecordButton setTitle:@"松开 结束" forState:UIControlStateHighlighted];
        
        // Cancel recordings when control tracking is interrupted or microphone authorization is requested.
        // https://github.com/ChenYilong/CYLChatKit/issues/3
        // https://github.com/leancloud/ChatKit-OC/issues/269
        [_voiceRecordButton addTarget:self action:@selector(startRecordVoice) forControlEvents:UIControlEventTouchDown];
        [_voiceRecordButton addTarget:self action:@selector(cancelRecordVoice) forControlEvents:UIControlEventTouchUpOutside];
        [_voiceRecordButton addTarget:self action:@selector(cancelRecordVoice) forControlEvents:UIControlEventTouchCancel];
        [_voiceRecordButton addTarget:self action:@selector(confirmRecordVoice) forControlEvents:UIControlEventTouchUpInside];
        [_voiceRecordButton addTarget:self action:@selector(updateCancelRecordVoice) forControlEvents:UIControlEventTouchDragExit];
        [_voiceRecordButton addTarget:self action:@selector(updateContinueRecordVoice) forControlEvents:UIControlEventTouchDragEnter];
    }
    return _voiceRecordButton;
}

- (UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreButton.frame = CGRectZero;
        _moreButton.layer.cornerRadius = 5;
        _moreButton.layer.masksToBounds = YES;
        _moreButton.tag = LCCKFunctionViewShowMore;
//        [_moreButton hdl_setBackgroundColor:[UIColor fd_c1] forState:UIControlStateHighlighted];
//        [_moreButton hdl_setBackgroundColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_moreButton setTitle:@"发送" forState:UIControlStateNormal];
        [_moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_moreButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
//        [_moreButton cyl_setHighlighted:NO];
        [_moreButton sizeToFit];
    }
    return _moreButton;
}

- (UIButton *)faceButton {
    if (!_faceButton) {
        _faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _faceButton.tag = LCCKFunctionViewShowFace;
        [_faceButton setBackgroundImage:[self imageInBundlePathForImageName:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [_faceButton setBackgroundImage:[self imageInBundlePathForImageName:@"ToolViewKeyboard"] forState:UIControlStateSelected];
        [_faceButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_faceButton sizeToFit];
        _faceButton.hidden = YES;
    }
    return _faceButton;
}

- (CGFloat)bottomHeight {
    if (self.faceView.superview || self.moreView.superview) {
        return MAX(self.keyboardSize.height, MAX(self.faceView.frame.size.height, self.moreView.frame.size.height));
    } else {
        return MAX(self.keyboardSize.height, CGFLOAT_MIN);
    }
}

- (UIViewController *)rootViewController {
    return [[UIApplication sharedApplication] keyWindow].rootViewController;
}

#pragma mark -
#pragma mark - MessageInputView Customize UI Method

- (UIColor *)messageInputViewBackgroundColor {
    if (_messageInputViewBackgroundColor) {
        return _messageInputViewBackgroundColor;
    }
    _messageInputViewBackgroundColor = [[LCCKSettingService sharedInstance] defaultThemeColorForKey:@"MessageInputView-BackgroundColor"];
    return _messageInputViewBackgroundColor;
}

- (UIColor *)messageInputViewTextFieldTextColor {
    if (_messageInputViewTextFieldTextColor) {
        return _messageInputViewTextFieldTextColor;
    }
    _messageInputViewTextFieldTextColor = [[LCCKSettingService sharedInstance] defaultThemeColorForKey:@"MessageInputView-TextField-TextColor"];
    return _messageInputViewTextFieldTextColor;
}

- (UIColor *)messageInputViewTextFieldBackgroundColor {
    if (_messageInputViewTextFieldBackgroundColor) {
        return _messageInputViewTextFieldBackgroundColor;
    }
    _messageInputViewTextFieldBackgroundColor = [[LCCKSettingService sharedInstance] defaultThemeColorForKey:@"MessageInputView-TextField-BackgroundColor"];
    return _messageInputViewTextFieldBackgroundColor;
}

- (UIColor *)messageInputViewRecordTextColor {
    if (_messageInputViewRecordTextColor) {
        return _messageInputViewRecordTextColor;
    }
    _messageInputViewRecordTextColor = [[LCCKSettingService sharedInstance] defaultThemeColorForKey:@"MessageInputView-Record-TextColor"];
    return _messageInputViewRecordTextColor;
}

/**
 *  进入后台 取消当前的录音
 */
- (void)appBecomeBackgroundCancelRecordVoice {
    [self cancelRecordVoice];
}

- (UIColor *)randomColor {
    return [UIColor colorWithRed:drand48()
                           green:drand48()
                            blue:drand48()
                           alpha:drand48()];
}

- (UIImage *)randomImage {
    CGSize size = CGSizeMake(30, 10);
    UIGraphicsBeginImageContextWithOptions(size , NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *fillColor = [self randomColor];
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextFillRect(context, rect);
    
    fillColor = [self randomColor];
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    CGFloat xxx = 3;
    rect = CGRectMake(xxx, xxx, size.width - 2 * xxx, size.height - 2 * xxx);
    CGContextFillRect(context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)safeAreaInsetsDidChange {
    CGFloat safeAreaOffset = 0;
    if ((_showType != LCCKFunctionViewShowFace) &&  (_showType != LCCKFunctionViewShowMore)) {
        safeAreaOffset = -self.safeAreaInsets.bottom;
    }
    [self.voiceButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.inputBarBackgroundView.mas_bottom).with.offset(-LCCKChatBarBottomOffset+safeAreaOffset);
    }];
    [self.moreButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.inputBarBackgroundView.mas_bottom).with.offset(-LCCKChatBarBottomOffset+safeAreaOffset);
    }];
    [self.faceButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.inputBarBackgroundView.mas_bottom).with.offset(-LCCKChatBarBottomOffset+safeAreaOffset);
    }];
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.inputBarBackgroundView.mas_bottom).with.offset(-LCCKChatBarBottomOffset+safeAreaOffset);
    }];
}

@end
