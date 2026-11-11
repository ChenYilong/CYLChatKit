//
//  CYLChatKit.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/22.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//  Core class of LeanCloudChatKit


#import "CYLDemoUserGroupCell.h"
#import "CYLDemoUserGroupItemCell.h"
#import "CYLDemoUser.h"
#if __has_include(<ChatKit/CYLChatKit.h>)
#import <ChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif

#define     USER_CELL_WIDTH         57
#define     USER_CELL_HEIGHT        75
#define     USER_CELL_ROWSPACE     15
#define     USER_CELL_COLSPACE      (([UIScreen mainScreen].bounds.size.width - USER_CELL_WIDTH * 4) / 5)

@interface CYLDemoUserGroupCell () <UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation CYLDemoUserGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.contentView addSubview:self.collectionView];
        [self.collectionView registerClass:[CYLDemoUserGroupItemCell class] forCellWithReuseIdentifier:NSStringFromClass([CYLDemoUserGroupItemCell class])];
        [self p_addMasonry];
    }
    return self;
}

#pragma mark - Delegate -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self cyl_isCreatorForCurrentGroupConversaton]) {
        return self.users.count + 2;
    }
    return self.users.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CYLDemoUserGroupItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CYLDemoUserGroupItemCell class]) forIndexPath:indexPath];
    CYLDemoConversationOperationType operationType;
    CYLDemoUser *user;
    if (indexPath.row < self.users.count) {
        user = self.users[indexPath.row];
        operationType = CYLDemoConversationOperationTypeNone;
    } else if (indexPath.row == self.users.count) {
        operationType = CYLDemoConversationOperationTypeAdd;
        user = nil;
    } else {
        operationType = CYLDemoConversationOperationTypeRemove;
        user = nil;
    }
    [cell setUser:user operationType:operationType];
    [cell setClickBlock:^(CYLDemoUser *user) {
        if (user && _delegate && [_delegate respondsToSelector:@selector(userGroupCellDidSelectUser:)]) {
            [_delegate userGroupCellDidSelectUser:user];
        } else {
            [_delegate userGroupCellAddUserButtonDownWithOperationType:operationType];
        }
    }];
    return cell;
}

#pragma mark - Private Methods -

- (void)p_addMasonry {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
}

#pragma mark - Getter -

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setItemSize:CGSizeMake(USER_CELL_WIDTH, USER_CELL_HEIGHT)];
        [layout setMinimumInteritemSpacing:USER_CELL_COLSPACE];
        [layout setSectionInset:UIEdgeInsetsMake(USER_CELL_ROWSPACE, USER_CELL_COLSPACE * 0.9, USER_CELL_ROWSPACE, USER_CELL_ROWSPACE * 0.9)];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        [_collectionView setScrollEnabled:NO];
        [_collectionView setPagingEnabled:YES];
        [_collectionView setDataSource:self];
        [_collectionView setDelegate:self];
        [_collectionView setShowsHorizontalScrollIndicator:NO];
        [_collectionView setShowsHorizontalScrollIndicator:NO];
        [_collectionView setScrollsToTop:NO];
    }
    return _collectionView;
}

@end
