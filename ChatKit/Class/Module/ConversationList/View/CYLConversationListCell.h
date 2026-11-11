//
//  CYLConversationListCell.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/22.
//  Copyright © 2016年 ElonChan . All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CYLBadgeView.h"

@interface CYLConversationListCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *officialSignImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel  *messageTextLabel;
@property (nonatomic, strong) CYLBadgeView *badgeView;
@property (nonatomic, strong) UIView *litteBadgeView;
@property (nonatomic, strong) UILabel *timestampLabel;
@property (nonatomic, strong) UIButton *remindMuteImageView;
@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, copy) NSString *identifier;

+ (instancetype)dequeueOrCreateCellByTableView:(UITableView *)tableView;
+ (void)registerCellToTableView:(UITableView *)tableView;

@end
