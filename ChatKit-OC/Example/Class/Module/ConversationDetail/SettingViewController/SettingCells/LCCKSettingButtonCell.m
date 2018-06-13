//
//  LCChatKit.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 18/6/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//  Core class of LeanCloudChatKit


#import "LCCKSettingButtonCell.h"

@implementation LCCKSettingButtonCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.textLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return self;
}

- (void) setItem:(LCCKSettingItem *)item {
    _item = item;
    [self.textLabel setText:item.title];
}

@end
