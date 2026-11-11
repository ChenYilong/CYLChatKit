//
//  CYLConversationNavigationTitleView.h
//  Pods
//
//  v2.1.1 Created by ElonChan on 16/7/19.
//
//

#import <UIKit/UIKit.h>

#import "CYLConversationProtocol.h"

@interface CYLConversationNavigationTitleView : UIView

- (instancetype)initWithConversation:(id<CYLConversationProtocol>)conversation navigationController:(UINavigationController *)navigationController;

@end
