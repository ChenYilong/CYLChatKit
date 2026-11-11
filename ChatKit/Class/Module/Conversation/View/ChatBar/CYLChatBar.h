//
//  CYLChatBar.h
//  CYLChatBarExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/8/17.
//  Copyright (c) 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

static CGFloat const CYLChatBarBottomOffset = 8.f;
static CGFloat const CYLChatBarTextViewBottomOffset = 6 * 2;
/*!
 * The minimum height of the text view: `kCYLChatBarMinHeight - 2 * CYLChatBarTextViewBottomOffset`.
 */
static CGFloat const kCYLChatBarTextViewFrameMinHeight = 37.f;
/*!
 * The maximum height of the text view: `kCYLChatBarMaxHeight - 2 * CYLChatBarTextViewBottomOffset`.
 */
static CGFloat const kCYLChatBarTextViewFrameMaxHeight = 102.f;
/*!
 * The maximum height of the chat bar (114 pt).
 */
static CGFloat const kCYLChatBarMaxHeight = kCYLChatBarTextViewFrameMaxHeight + 2*CYLChatBarTextViewBottomOffset;
/*!
 * The minimum height of the chat bar (49 pt).
 */
static CGFloat const kCYLChatBarMinHeight = kCYLChatBarTextViewFrameMinHeight + 2*CYLChatBarTextViewBottomOffset;

FOUNDATION_EXTERN NSString *const kCYLBatchDeleteTextPrefix;
FOUNDATION_EXTERN NSString *const kCYLBatchDeleteTextSuffix;

/*!
 *  functionView 类型
 */
typedef NS_ENUM(NSUInteger, CYLFunctionViewShowType){
    /*!
     * 不显示functionView
     */
    CYLFunctionViewShowNothing,
    /*!
     * 显示表情View
     */
    CYLFunctionViewShowFace,
    /*!
     * 显示录音view
     */
    CYLFunctionViewShowVoice,
    /*!
     * 显示更多view
     */
    CYLFunctionViewShowMore,
    /*!
     * 显示键盘
     */
    CYLFunctionViewShowKeyboard,
};

@protocol CYLChatBarDelegate;

/*!
 *  信息输入框,支持语音,文字,表情,选择照片,拍照
 */
@interface CYLChatBar : UIView

@property (weak, nonatomic) id<CYLChatBarDelegate> delegate;
@property (nonatomic, readonly) UIViewController *controllerRef;

/*!
 *
 * 缓存输入框文字，兼具内存缓存和本地数据库缓存的作用。同时也负责着输入框内容被清空时的监听，收缩键盘。内部重写了setter方法，self.cachedText 就相当于self.textView.text，使用最重要的场景：为了显示voiceButton，self.textView.text = nil;
 */
@property (copy, nonatomic) NSString *cachedText;
@property (nonatomic, assign) CYLFunctionViewShowType showType;
@property (strong, nonatomic) UITextView *textView;

/*!
 * 在 `-presentViewController:animated:completion:` 的 completion 回调中调用该方法，屏蔽来自其它 ViewController 的键盘通知事件。
 */
- (void)close;

/*!
 * 对应于 `-close` 方法。
 */
- (void)open;

/*!
 * 追加后，输入框默认开启编辑模式
 */
- (void)appendString:(NSString *)string;
- (void)appendString:(NSString *)string beginInputing:(BOOL)beginInputing;
- (void)appendString:(NSString *)string mentionList:(NSArray<NSString *> *)mentionList;

/*!
 *  结束输入状态
 */
- (void)endInputing;

/*!
 *  进入输入状态
 */
- (void)beginInputing;

@end

/*!
 *  CYLChatBar代理事件,发送图片,地理位置,文字,语音信息等
 */
@protocol CYLChatBarDelegate <NSObject>

@optional

/*!
 *  chatBarFrame改变回调
 *
 *
 */
- (void)chatBarFrameDidChange:(CYLChatBar *)chatBar shouldScrollToBottom:(BOOL)shouldScrollToBottom;

/*!
 *  发送图片信息,支持多张图片
 *
 *
 *  @param pictures 需要发送的图片信息
 */
- (void)chatBar:(CYLChatBar *)chatBar sendPictures:(NSArray *)pictures;

/*!
 *  发送地理位置信息
 *
 *
 *  @param locationCoordinate 需要发送的地址位置经纬度
 *  @param locationText       需要发送的地址位置对应信息
 */
- (void)chatBar:(CYLChatBar *)chatBar sendLocation:(CLLocationCoordinate2D)locationCoordinate locationText:(NSString *)locationText;

/*!
 *  发送普通的文字信息,可能带有表情
 *
 *
 *  @param message 需要发送的文字信息
 */
- (void)chatBar:(CYLChatBar *)chatBar sendMessage:(NSString *)message mentionList:(NSArray<NSString *> *)mentionList;

/*!
 *  发送语音信息
 *  @param seconds   语音时长
 */
- (void)chatBar:(CYLChatBar *)chatBar sendVoice:(NSString *)voiceFileName seconds:(NSTimeInterval)seconds;

/*!
 *  输入了 @ 的时候
 */
- (void)didInputAtSign:(CYLChatBar *)chatBar;

- (NSArray *)regulationForBatchDeleteText;

@end

