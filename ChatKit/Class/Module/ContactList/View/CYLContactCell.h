//
//  CYLContactCell.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/9.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYLContactListViewController.h"

@interface CYLContactCell : UITableViewCell

- (void)configureWithAvatarURL:(NSURL *)avatarURL title:(NSString *)title subtitle:(NSString *)subtitle model:(CYLContactListMode)model;

@property (nonatomic, assign, getter=isChecked) BOOL checked;

@property (nonatomic, copy) NSString *identifier;

@end
