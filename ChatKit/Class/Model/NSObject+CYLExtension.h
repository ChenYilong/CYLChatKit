//
//  NSObject+CYLExtension.h
//  Pods
//
//  v2.1.1 Created by ElonChan on 18/6/10.
//
//

#import <Foundation/Foundation.h>

typedef void (^CYLShouldDisplayTimestampCallBack)(BOOL shouldDisplayTimestamp, NSTimeInterval messageTimestamp);

@interface NSObject (CYLExtension)

/*!
 * 判断是否为自定义消息
 */
- (BOOL)cyl_isCustomMessage;
- (BOOL)cyl_isCustomCYLMessage;

/*!
 * 当前消息的时间戳，以sendTime为准，可以区分自定义消息，和默认消息类型。
 */
- (NSTimeInterval)cyl_messageTimestamp;

/*!
 * 是否显示时间轴Label
 */
- (void)cyl_shouldDisplayTimestampForMessages:(NSArray *)messages callback:(CYLShouldDisplayTimestampCallBack)callback;

- (NSDictionary *)cyl_JSONValue;

- (BOOL)cyl_isCreatorForCurrentGroupConversaton;

@end
