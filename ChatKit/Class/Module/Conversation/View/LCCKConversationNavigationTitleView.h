//
//  LCCKConversationNavigationTitleView.h
//  Pods
//
//  v2.1.1 Created by ElonChan on 16/7/19.
//
//

#import <UIKit/UIKit.h>

@class AVIMConversation;

@interface LCCKConversationNavigationTitleView : UIView

- (instancetype)initWithConversation:(AVIMConversation *)conversation navigationController:(UINavigationController *)navigationController;

@end
