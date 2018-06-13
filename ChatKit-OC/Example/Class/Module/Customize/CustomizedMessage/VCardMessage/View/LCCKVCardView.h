//
//  LCCKVCardView.h
//  ChatKit-OC
//
//  v0.8.5 Created by ElonChan on 16/8/15.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^LCCKVCardDidClickedHandler)(NSString *clientId);
@interface LCCKVCardView : UIView

+ (id)vCardView;
- (void)configureWithAvatarURL:(NSURL *)avatarURL title:(NSString *)title clientId:(NSString *)clientId;
@property (nonatomic, copy) LCCKVCardDidClickedHandler vCardDidClickedHandler;
- (void)setVCardDidClickedHandler:(LCCKVCardDidClickedHandler)vCardDidClickedHandler;

@end
