//
//  LCCKConversationNavigationTitleView.h
//  Pods
//
//  v2.1.1 Created by ElonChan on 16/7/19.
//
//

#import <UIKit/UIKit.h>

#import "LCCKConversationDelegate.h"

@interface LCCKConversationNavigationTitleView : UIView

- (instancetype)initWithConversation:(id<LCCKConversationDelegate>)conversation navigationController:(UINavigationController *)navigationController;

@end
