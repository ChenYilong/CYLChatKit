//
//  LCCKConversationListService.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

//TODO:
///**
// *  在没有数据时显示该view，占据Controller的View整个页面
// */
//@property (nonatomic, strong) UIView *viewForNoData;
///**
// *  设置某个对话的最近消息内容后的回调
// *  @param conversation 需要设置最近消息内容的对话
// *  @return 无需自定义最近消息内容返回nil
// */
//typedef NSString *(^LCCKConversationsLatestMessageContent)(id<LCCKConversationProtocol> conversation);
//
///**
// *  设置某个对话的最近消息内容后的回调
// */
//@property (nonatomic, copy, readonly) LCCKConversationsLatestMessageContent latestMessageContentBlock;
//
///**
// *  设置某个对话的最近消息内容后的回调
// */
//- (void)setLatestMessageContentBlock:(LCCKConversationsLatestMessageContent)latestMessageContentBlock;


#import "LCCKConversationListService.h"
#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

@implementation LCCKConversationListService
@synthesize didSelectConversationsListCellBlock = _didSelectConversationsListCellBlock;
@synthesize didDeleteConversationsListCellBlock = _didDeleteConversationsListCellBlock;
@synthesize conversationEditActionBlock = _conversationEditActionBlock;
@synthesize markBadgeWithTotalUnreadCountBlock = _markBadgeWithTotalUnreadCountBlock;
@synthesize conversationListShowHookBlock = _conversationListShowHookBlock;

/*!
 * Loading recent conversations depends on the IM SDK, so it is implemented by `-[LCChatKit IMProvider]`.
 */
- (void)findRecentConversationsWithBlock:(LCCKRecentConversationsCallback)block {
    id<LCCKIMProvider> IMProvider = [LCChatKit sharedInstance].IMProvider;
    if (!IMProvider) {
        NSInteger code = 0;
        NSDictionary *errorInfo = @{
                                    @"code" : @(code),
                                    NSLocalizedDescriptionKey : @"IM provider not set. Set `-[LCChatKit setIMProvider:]` first.",
                                    };
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:code userInfo:errorInfo];
        dispatch_async(dispatch_get_main_queue(),^{
            !block ?: block(@[], 0, error);
        });
        return;
    }
    [IMProvider findRecentConversationsWithBlock:^(NSArray<id<LCCKConversationProtocol>> *conversations, NSInteger totalUnreadCount, NSError *error) {
        !block ?: block(conversations, totalUnreadCount, error);
    }];
}

- (void)fetchRelationConversationsFromServerCallback:(LCCKArrayResultBlock)block {
    [[LCChatKit sharedInstance].IMProvider fetchRelationConversationsFromServerCallback:block];
}

#pragma mark -
#pragma mark - Setter Method

- (void)setDidSelectConversationsListCellBlock:(LCCKDidSelectConversationsListCellBlock)didSelectConversationsListCellBlock {
    _didSelectConversationsListCellBlock = didSelectConversationsListCellBlock;
}

- (void)setMarkBadgeWithTotalUnreadCountBlock:(LCCKMarkBadgeWithTotalUnreadCountBlock)markBadgeWithTotalUnreadCountBlock {
    _markBadgeWithTotalUnreadCountBlock = markBadgeWithTotalUnreadCountBlock;
}

- (void)setPrepareConversationsWhenLoadBlock:(LCCKPrepareConversationsWhenLoadBlock)prepareConversationsWhenLoadBlock {
    _prepareConversationsWhenLoadBlock = prepareConversationsWhenLoadBlock;
}

- (void)setDidDeleteConversationsListCellBlock:(LCCKDidDeleteConversationsListCellBlock)didDeleteConversationsListCellBlock {
    _didDeleteConversationsListCellBlock = didDeleteConversationsListCellBlock;
}

- (void)setConversationEditActionBlock:(LCCKConversationEditActionsBlock)conversationEditActionBlock {
    _conversationEditActionBlock = conversationEditActionBlock;
}

- (void)setHeightForRowBlock:(LCCKHeightForRowBlock)heightForRowBlock {
    _heightForRowBlock = heightForRowBlock;
}

- (void)setCellForRowBlock:(LCCKCellForRowBlock)cellForRowBlock {
    _cellForRowBlock = cellForRowBlock;
}

- (void)setConfigureCellBlock:(LCCKConfigureCellBlock)configureCellBlock {
    _configureCellBlock = configureCellBlock;
}

- (void)setConversationListShowHookBlock:(LCCKConversationListShowHookBlock)conversationListShowHookBlock {
    _conversationListShowHookBlock = [conversationListShowHookBlock copy];
}

- (LCCKConversationListShowHookBlock)conversationListShowHookBlock {
    return _conversationListShowHookBlock;
}

@end
