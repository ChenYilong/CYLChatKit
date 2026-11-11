//
//  CYLStatusView.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/11.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CYLStatusViewDelegate <NSObject>

@optional
- (void)statusViewClicked:(id)sender;
@end

static CGFloat CYLStatusViewHight = 44;

@interface CYLStatusView : UIView

@property (nonatomic, weak) id<CYLStatusViewDelegate> delegate;

@end
