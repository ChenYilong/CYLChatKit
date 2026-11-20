//
//  UIself+CYLCellRegister.m
//  CYLChatBarExample
//
//  v2.1.1 Created by ElonChan  ( https://github.com/ChenYilong/CYLChatKit ) on 15/11/23.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//

#import "CYLCellRegisterController.h"
#import "CYLChatSystemMessageCell.h"
#import "CYLChatConstants.h"

@implementation CYLCellRegisterController
//
+ (void)registerChatMessageCellClassForTableView:(UITableView *)tableView {
    [CYLChatMessageCellMediaTypeDict enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull mediaType, Class _Nonnull aClass, BOOL * _Nonnull stop) {
        if (mediaType.intValue != -7) {
            [self registerMessageCellClass:aClass ForTableView:tableView];
        }
    }];
    [self registerSystemMessageCellClassForTableView:tableView];
}

+ (void)registerMessageCellClass:(Class)messageCellClass ForTableView:(UITableView *)tableView  {
    NSString *messageCellClassString = NSStringFromClass(messageCellClass);
    UINib *nib = [UINib nibWithNibName:messageCellClassString bundle:nil];
    if([[NSBundle mainBundle] pathForResource:messageCellClassString ofType:@"nib"] != nil) {
    [tableView registerNib:nib forCellReuseIdentifier:[NSString stringWithFormat:@"%@_%@_%@", messageCellClassString, CYLCellIdentifierOwnerSelf, CYLCellIdentifierGroup]];
    [tableView registerNib:nib forCellReuseIdentifier:[NSString stringWithFormat:@"%@_%@_%@", messageCellClassString, CYLCellIdentifierOwnerSelf, CYLCellIdentifierSingle]];
    [tableView registerNib:nib forCellReuseIdentifier:[NSString stringWithFormat:@"%@_%@_%@", messageCellClassString, CYLCellIdentifierOwnerOther, CYLCellIdentifierGroup]];
    [tableView registerNib:nib forCellReuseIdentifier:[NSString stringWithFormat:@"%@_%@_%@", messageCellClassString, CYLCellIdentifierOwnerOther , CYLCellIdentifierSingle]];
    } else {
        [tableView registerClass:messageCellClass forCellReuseIdentifier:[NSString stringWithFormat:@"%@_%@_%@", messageCellClassString, CYLCellIdentifierOwnerSelf, CYLCellIdentifierGroup]];
        [tableView registerClass:messageCellClass forCellReuseIdentifier:[NSString stringWithFormat:@"%@_%@_%@", messageCellClassString, CYLCellIdentifierOwnerSelf, CYLCellIdentifierSingle]];
        [tableView registerClass:messageCellClass forCellReuseIdentifier:[NSString stringWithFormat:@"%@_%@_%@", messageCellClassString, CYLCellIdentifierOwnerOther, CYLCellIdentifierGroup]];
        [tableView registerClass:messageCellClass forCellReuseIdentifier:[NSString stringWithFormat:@"%@_%@_%@", messageCellClassString, CYLCellIdentifierOwnerOther , CYLCellIdentifierSingle]];
    }
}

+ (void)registerSystemMessageCellClassForTableView:(UITableView *)tableView {
    [tableView registerClass:[CYLChatSystemMessageCell class] forCellReuseIdentifier:@"CYLChatSystemMessageCell_CYLCellIdentifierOwnerSystem_CYLCellIdentifierSingle"];
    [tableView registerClass:[CYLChatSystemMessageCell class] forCellReuseIdentifier:@"CYLChatSystemMessageCell_CYLCellIdentifierOwnerSystem_CYLCellIdentifierGroup"];
}

@end
