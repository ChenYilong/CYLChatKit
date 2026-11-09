//
//  CYLChatVoiceMessageCell.m
//  CYLChatExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/11/16.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//

#import "CYLChatVoiceMessageCell.h"
#import "CYLMessageVoiceFactory.h"
#import "CYLAVAudioPlayer.h"

#if __has_include(<CYLDeallocBlockExecutor/CYLDeallocBlockExecutor.h>)
#import <CYLDeallocBlockExecutor/CYLDeallocBlockExecutor.h>
#else
#import "CYLDeallocBlockExecutor.h"
#endif

static void * const CYLChatVoiceMessageCellVoiceMessageStateContext = (void*)&CYLChatVoiceMessageCellVoiceMessageStateContext;

@interface CYLChatVoiceMessageCell ()

@property (nonatomic, strong) UIImageView *messageVoiceStatusImageView;
@property (nonatomic, strong) UILabel *messageVoiceSecondsLabel;
@property (nonatomic, strong) UIActivityIndicatorView *messageIndicatorView;

@end

@implementation CYLChatVoiceMessageCell

#pragma mark - Override Methods

- (void)prepareForReuse {
    [super prepareForReuse];
    [self setVoiceMessageState:CYLVoiceMessageStateNormal];
}

- (void)updateConstraints {
    [super updateConstraints];
    if (self.messageOwner == CYLMessageOwnerTypeSelf) {
        [self.messageVoiceStatusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.messageContentView.mas_right).with.offset(-12);
            make.centerY.equalTo(self.messageContentView.mas_centerY);
        }];
        [self.messageVoiceSecondsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.messageContentView.mas_left).with.offset(-10);
            make.bottom.equalTo(self.messageContentView.mas_bottom);
        }];
        self.messageVoiceSecondsLabel.textColor = [UIColor lightGrayColor];
        [self.messageIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.messageContentView);
            make.width.equalTo(@10);
            make.height.equalTo(@10);
        }];
    } else if (self.messageOwner == CYLMessageOwnerTypeOther) {
        self.messageVoiceSecondsLabel.textColor = [UIColor lightGrayColor];
        [self.messageVoiceStatusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.messageContentView.mas_left).with.offset(12);
            make.centerY.equalTo(self.messageContentView.mas_centerY);
        }];
        
        [self.messageVoiceSecondsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.messageContentView.mas_right).with.offset(10);
                make.bottom.equalTo(self.messageContentView.mas_bottom);
        }];
        [self.messageIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.messageContentView);
            make.width.equalTo(@10);
            make.height.equalTo(@10);
        }];
    }
    
    [self.messageContentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_greaterThanOrEqualTo(@(80)).priorityHigh();
    }];

}

#pragma mark - Public Methods

- (void)setup {
    [self addSubview:self.messageVoiceSecondsLabel];
    [self.messageContentView addSubview:self.messageVoiceStatusImageView];
    [self.messageContentView addSubview:self.messageIndicatorView];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapMessageImageViewGestureRecognizerHandler:)];
    [self.messageContentView addGestureRecognizer:recognizer];
    [super setup];
    [self addGeneralView];
    self.voiceMessageState = CYLVoiceMessageStateNormal;
    [[CYLAVAudioPlayer sharePlayer]  addObserver:self forKeyPath:@"audioPlayerState" options:NSKeyValueObservingOptionNew context:CYLChatVoiceMessageCellVoiceMessageStateContext];
    [self cyl_willDeallocWithSelfCallback:^(__unsafe_unretained id owner, NSUInteger identifier) {
        [[CYLAVAudioPlayer sharePlayer] removeObserver:owner forKeyPath:@"audioPlayerState"];
    }];
}

// KVO监听执行
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(context != CYLChatVoiceMessageCellVoiceMessageStateContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    if(context == CYLChatVoiceMessageCellVoiceMessageStateContext) {
        //if ([keyPath isEqualToString:@"audioPlayerState"]) {
        NSNumber *audioPlayerStateNumber = change[NSKeyValueChangeNewKey];
        CYLVoiceMessageState audioPlayerState = [audioPlayerStateNumber intValue];
        switch (audioPlayerState) {
            case CYLVoiceMessageStateCancel:
            case CYLVoiceMessageStateNormal:
                self.voiceMessageState = CYLVoiceMessageStateCancel;
                break;

            default: {
                NSString *playerIdentifier = [[CYLAVAudioPlayer sharePlayer] identifier];
                if (playerIdentifier) {
                    NSString *messageId = self.message.messageId;
                    if (playerIdentifier && [messageId isEqualToString:playerIdentifier]) {
                        self.voiceMessageState = audioPlayerState;
                    }
                }
            }
                break;
        }
    }
}

- (void)singleTapMessageImageViewGestureRecognizerHandler:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(messageCellTappedMessage:)]) {
            [self.delegate messageCellTappedMessage:self];
        }
    }
}

- (void)configureCellWithData:(CYLMessage *)message {
    [super configureCellWithData:message];
    NSUInteger voiceDuration = [message.voiceDuration integerValue];
    NSString *voiceDurationString = [NSString stringWithFormat:@"%@", @(voiceDuration)];
    self.messageVoiceSecondsLabel.text = [NSString stringWithFormat:@"%@''", voiceDurationString];
        //设置正确的voiceMessageCell播放状态
        NSString *identifier = [[CYLAVAudioPlayer sharePlayer] identifier];
        if (identifier) {
            NSString *messageId = message.messageId;
            if (messageId == identifier) {
                if (message.mediaType == CYLMessageMediaTypeAudio) {
                    [self setVoiceMessageState:[[CYLAVAudioPlayer sharePlayer] audioPlayerState]];
                }
            }
        }

    if (voiceDuration > 2) {
        __block CGFloat length;
        CGFloat lengthUnit = 10.f;
        // 1-2 长度固定, 2-10s每秒增加一个单位, 10-60s每10s增加一个单位
        do {
            if (voiceDuration <= 10) {
                length = lengthUnit*(voiceDuration-2);
                break;
            }
            if (voiceDuration > 10) {
                length = lengthUnit*(10-2) + lengthUnit*((voiceDuration-2)/10);
                break;
            }
        } while (NO);
        [self.messageContentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(80+length));
        }];
    } else {
        [self.messageContentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(80));
        }];
    }
}

- (void)setMessageSendState:(CYLMessageSendState)messageSendState {
    [super setMessageSendState:messageSendState];
    switch (self.messageSendState) {
        case CYLMessageSendStateSending:
            self.messageVoiceSecondsLabel.hidden = YES;
            break;
            
        case CYLMessageSendStateFailed:
            self.messageVoiceSecondsLabel.hidden = YES;
            break;
        default:
            self.messageVoiceSecondsLabel.hidden = NO;
            break;
    }
}

#pragma mark - Getters

- (UIImageView *)messageVoiceStatusImageView {
    if (!_messageVoiceStatusImageView) {
       _messageVoiceStatusImageView = [CYLMessageVoiceFactory messageVoiceAnimationImageViewWithBubbleMessageType:self.messageOwner];
    }
    return _messageVoiceStatusImageView;
}

- (UILabel *)messageVoiceSecondsLabel {
    if (!_messageVoiceSecondsLabel) {
        _messageVoiceSecondsLabel = [[UILabel alloc] init];
        _messageVoiceSecondsLabel.font = [CYLSettingService sharedInstance].defaultThemeTextMessageFont;
        _messageVoiceSecondsLabel.text = @"0''";
    }
    return _messageVoiceSecondsLabel;
}

- (UIActivityIndicatorView *)messageIndicatorView {
    if (!_messageIndicatorView) {
        _messageIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _messageIndicatorView;
}

#pragma mark - Setters

- (void)setVoiceMessageState:(CYLVoiceMessageState)voiceMessageState {
    if (_voiceMessageState != voiceMessageState) {
        _voiceMessageState = voiceMessageState;
    }
    self.messageVoiceSecondsLabel.hidden = NO;
    self.messageVoiceStatusImageView.hidden = NO;
    self.messageIndicatorView.hidden = YES;
    dispatch_async(dispatch_get_main_queue(),^{
        [self.messageIndicatorView stopAnimating];
    });
    if (_voiceMessageState == CYLVoiceMessageStatePlaying) {
        self.messageVoiceStatusImageView.highlighted = YES;
        [self.messageVoiceStatusImageView startAnimating];
    } else if (_voiceMessageState == CYLVoiceMessageStateDownloading) {
        self.messageVoiceSecondsLabel.hidden = YES;
        self.messageVoiceStatusImageView.hidden = YES;
        self.messageIndicatorView.hidden = NO;
        dispatch_async(dispatch_get_main_queue(),^{
            [self.messageIndicatorView startAnimating];
        });
    } else {
        self.messageVoiceStatusImageView.highlighted = NO;
        dispatch_async(dispatch_get_main_queue(),^{
            [self.messageVoiceStatusImageView stopAnimating];
        });
    }
}

#pragma mark -
#pragma mark - CYLChatMessageCellSubclassing Method

+ (void)load {
    [self registerSubclass];
}

+ (CYLMessageMediaType)classMediaType {
    return CYLMessageMediaTypeAudio;
}

@end
