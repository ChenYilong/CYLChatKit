//
//  CYLChatKit.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/22.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//  Core class of LeanCloudChatKit


#import "CYLDemoSettingSwitchCell.h"
//#import <Masonry/Masonry.h>
#if __has_include(<ChatKit/CYLChatKit.h>)
#import <ChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif
@interface CYLDemoSettingSwitchCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UISwitch *cellSwitch;

@end

@implementation CYLDemoSettingSwitchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setAccessoryView:self.cellSwitch];
        [self.contentView addSubview:self.titleLabel];
        [self p_addMasonry];
    }
    return self;
}

- (void)setItem:(CYLDemoSettingItem *)item {
    _item = item;
    [self.titleLabel setText:item.title];
    self.cellSwitch.on = item.isSwithOn;
}

#pragma mark - Event Response -
- (void)switchChangeStatus:(UISwitch *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(settingSwitchCellForItem:didChangeStatus:completionHandler:)]) {
        CYLDemoSettingSwitchCellCompletionhandler completionHandler = ^void (BOOL succeeded, NSError *error) {
            if (error) {
                sender.on = !sender.on;
            }
        };
        [_delegate settingSwitchCellForItem:self.item didChangeStatus:sender.on completionHandler:completionHandler];
    }
}

#pragma mark - Private Methods -
- (void)p_addMasonry {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).mas_offset(15);
        make.right.mas_lessThanOrEqualTo(self.contentView).mas_offset(-15);
    }];
}

#pragma mark - Getter -
- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
    }
    return _titleLabel;
}

- (UISwitch *)cellSwitch
{
    if (_cellSwitch == nil) {
        _cellSwitch = [[UISwitch alloc] init];
        [_cellSwitch addTarget:self action:@selector(switchChangeStatus:) forControlEvents:UIControlEventValueChanged];
    }
    return _cellSwitch;
}

@end
