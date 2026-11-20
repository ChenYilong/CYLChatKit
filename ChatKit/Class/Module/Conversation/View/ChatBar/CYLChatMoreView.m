//
//  CYLChatMoreView.m
//  CYLChatBarExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/8/18.
//  Copyright (c) 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//

#import "CYLChatMoreView.h"
#import "CYLChatConstants.h"
#import "CYLInputViewPlugin.h"
#import "CYLSettingService.h"
#import "NSString+CYLExtension.h"

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

#define kCYLTopLineBackgroundColor [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f]

@interface CYLChatMoreView ()<UIScrollViewDelegate>

@property (copy, nonatomic) NSArray *titles;
@property (copy, nonatomic) NSArray *images;

@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSMutableArray<CYLInputViewPlugin *> *itemViews;

@property (assign, nonatomic) CGSize itemSize;
@property (nonatomic, copy) NSArray<Class> *sortedInputViewPluginArray;
@property (nonatomic, strong) UIColor *messageInputViewMorePanelBackgroundColor;

@end

@implementation CYLChatMoreView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.pageControl setCurrentPage:scrollView.contentOffset.x / scrollView.frame.size.width];
}

#pragma mark - Public Methods

- (void)reloadData {
    CGFloat width = [UIApplication sharedApplication].keyWindow.frame.size.width;
    CGFloat height = [UIApplication sharedApplication].keyWindow.frame.size.height;
    CGFloat widthLimit = MIN(width, height);
    CGFloat itemWidth = (widthLimit - self.edgeInsets.left - self.edgeInsets.right) / self.numberPerLine;
    CGFloat itemHeight = kFunctionViewHeight / 2;
    self.itemSize = CGSizeMake(itemWidth, itemHeight);
    if (self && [self respondsToSelector:@selector(titlesOfMoreView:)]&&[self respondsToSelector:@selector(imagesOfMoreView:)]) {
        self.titles = [self titlesOfMoreView:self];
        self.images = [self imagesOfMoreView:self];
        [self setupItems];
    }
}

#pragma mark - Private Methods
#pragma mark - CYLChatMoreViewDelegate & CYLChatMoreViewDataSource
- (NSArray<Class> *)sortedInputViewPluginArray {
    if (_sortedInputViewPluginArray) {
        return _sortedInputViewPluginArray;
    }
    NSArray *inputViewPluginDictArray = [CYLInputViewPluginArray copy];
    
    NSArray<NSDictionary *> *notSortedDefaultInputViewPlugin = [inputViewPluginDictArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(CYLInputViewPluginTypeKey < 0)"]];
    NSArray<NSDictionary *> *notSortedCustomInputViewPlugin = [inputViewPluginDictArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(CYLInputViewPluginTypeKey > 0)"]];
    
    NSMutableArray<NSNumber *> *notSortedDefaultInputViewPluginMutableTypes = [NSMutableArray arrayWithCapacity:notSortedDefaultInputViewPlugin.count];
    NSMutableArray<NSNumber *> *notSortedCustomInputViewPluginMutableTypes = [NSMutableArray arrayWithCapacity:notSortedCustomInputViewPlugin.count];
    
    [notSortedDefaultInputViewPlugin enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull inputViewPluginDict, NSUInteger idx, BOOL * _Nonnull stop) {
        [notSortedDefaultInputViewPluginMutableTypes addObject:inputViewPluginDict[CYLInputViewPluginTypeKey]];
    }];
    [notSortedCustomInputViewPlugin enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull inputViewPluginDict, NSUInteger idx, BOOL * _Nonnull stop) {
        [notSortedCustomInputViewPluginMutableTypes addObject:inputViewPluginDict[CYLInputViewPluginTypeKey]];
    }];
    
    NSArray<NSNumber *> *notSortedDefaultInputViewPluginTypes = [notSortedDefaultInputViewPluginMutableTypes copy];
    NSArray<NSNumber *> *notSortedCustomInputViewPluginTypes = [notSortedCustomInputViewPluginMutableTypes copy];
    
    //排序
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    NSSortDescriptor *LowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    NSArray<NSNumber *> *sortedDefaultInputViewPluginTypes = [notSortedDefaultInputViewPluginTypes sortedArrayUsingDescriptors:@[highestToLowest]];
    NSArray<NSNumber *> *sortedCustomInputViewPluginTypes = [notSortedCustomInputViewPluginTypes sortedArrayUsingDescriptors:@[LowestToHighest]];
    
    NSMutableArray *sortedInputViewPluginArray = [NSMutableArray arrayWithCapacity:[[CYLInputViewPluginDict allKeys] count]];
    [sortedDefaultInputViewPluginTypes enumerateObjectsUsingBlock:^(NSNumber * _Nonnull typeKey, NSUInteger idx, BOOL * _Nonnull stop) {
        [sortedInputViewPluginArray addObject:[CYLInputViewPluginDict objectForKey:typeKey]];
    }];
    
    [sortedCustomInputViewPluginTypes enumerateObjectsUsingBlock:^(NSNumber * _Nonnull typeKey, NSUInteger idx, BOOL * _Nonnull stop) {
        [sortedInputViewPluginArray addObject:[CYLInputViewPluginDict objectForKey:typeKey]];
    }];
    _sortedInputViewPluginArray = [sortedInputViewPluginArray copy];
    return _sortedInputViewPluginArray;
}

- (void)moreView:(CYLChatMoreView *)moreView selectIndex:(NSInteger)itemType {
    NSNumber *typeKey = @(itemType);
    id<CYLInputViewPluginDelegate> inputViewPlugin = [[CYLInputViewPluginDict objectForKey:typeKey] new];
    inputViewPlugin.inputViewRef = self.inputViewRef;
    [inputViewPlugin pluginDidClicked];
}

- (NSArray *)titlesOfMoreView:(CYLChatMoreView *)moreView {
    NSMutableArray *titles = [NSMutableArray arrayWithCapacity:[[CYLInputViewPluginDict allKeys] count]];
    [self.sortedInputViewPluginArray enumerateObjectsUsingBlock:^(Class _Nonnull aClass, NSUInteger idx, BOOL * _Nonnull stop) {
        id<CYLInputViewPluginDelegate> inputViewPlugin = [aClass new];
        NSString *title = [inputViewPlugin pluginTitle];
        [titles addObject:title];
    }];
    return [titles copy];
}

- (NSArray<UIImage *> *)imagesOfMoreView:(CYLChatMoreView *)moreView {
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[[CYLInputViewPluginDict allKeys] count]];
    [self.sortedInputViewPluginArray enumerateObjectsUsingBlock:^(Class _Nonnull aClass, NSUInteger idx, BOOL * _Nonnull stop) {
        id<CYLInputViewPluginDelegate> inputViewPlugin = [aClass new];
        UIImage *image = [inputViewPlugin pluginIconImage];
        [images addObject:image];
    }];
    return [images copy];
}

- (NSInteger)inputViewPluginTypeForItemTag:(NSInteger)tag {
    NSArray<NSNumber *> *allPlugins = [CYLInputViewPluginDict allKeys];
    NSArray *allDefalutPlugins = [allPlugins filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF < 0"]];
    NSInteger allDefalutPluginsCount = [allDefalutPlugins count];
    if (tag >= allDefalutPluginsCount) {
        return (tag - allDefalutPluginsCount)+1;
    } else {
        return -tag-1;
    }
}

- (void)itemClickAction:(CYLInputViewPlugin *)item {
    [self moreView:self selectIndex:[self inputViewPluginTypeForItemTag:item.tag]];
}

- (void)setup {
    UIImageView *topLine = [[UIImageView alloc] init];
    topLine.backgroundColor = kCYLTopLineBackgroundColor;
    [self addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.equalTo(self);
        make.height.mas_equalTo(.5f);
    }];
    
    self.edgeInsets = UIEdgeInsetsMake(10, 10, 5, 10);
    self.itemViews = [NSMutableArray array];
    self.numberPerLine = 4;
    
    [self scrollView];
    [self pageControl];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(_edgeInsets);
    }];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(-10);
    }];
    self.backgroundColor = self.messageInputViewMorePanelBackgroundColor;
    [self reloadData];
}

- (void)setupItems {
    __block NSUInteger line = 0;   //行数
    __block NSUInteger column = 0; //列数
    __block NSUInteger page = 0;
    [self.titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (column > 3) {
            line ++ ;
            column = 0;
        }
        if (line > 1) {
            line = 0;
            column = 0;
            page ++ ;
        }
        CGFloat width = [UIApplication sharedApplication].keyWindow.frame.size.width;
        CGFloat scrollViewWidth = width - self.edgeInsets.left - self.edgeInsets.right;
        CGFloat scrollViewHeight = kFunctionViewHeight - self.edgeInsets.top - self.edgeInsets.bottom;
        CGFloat startX = column * self.itemSize.width + page * scrollViewWidth;
        CGFloat startY = line * self.itemSize.height;
        NSInteger type = [self inputViewPluginTypeForItemTag:idx];
        NSNumber *typeKey = @(type);
        CYLInputViewPlugin *item = [[[CYLInputViewPluginDict objectForKey:typeKey] alloc] initWithFrame:CGRectMake(startX, startY, self.itemSize.width, self.itemSize.height)];
        [item fillWithPluginTitle:obj pluginIconImage:self.images[idx]];
        item.tag = idx;
        [item addTarget:self action:@selector(itemClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:item];
        if (!item) {
            NSString *formatString = @"\n\n\
            ------ BEGIN NSException Log ---------------\n \
            class name: %@                              \n \
            ------line: %@                              \n \
            ----reason: %@                              \n \
            ------ END -------------------------------- \n\n";
            NSString *reason = [NSString stringWithFormat:formatString,
                                @(__PRETTY_FUNCTION__),
                                @(__LINE__),
                                @"Please make sure the custom InputViewPlugin type increase from 1 consecutively.[Chinese:]请确保自定义插件的 type 值从1开始连续递增，详情请查看文档：https://github.com/ChenYilong/CYLChatKit/blob/master/ChatKit%20%E8%87%AA%E5%AE%9A%E4%B9%89%E4%B8%9A%E5%8A%A1.md#%E8%87%AA%E5%AE%9A%E4%B9%89%E8%BE%93%E5%85%A5%E6%A1%86%E6%8F%92%E4%BB%B6"];
            //TODO: add debug model
            NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), reason);
            return;
        }
        [self.itemViews addObject:item];
        column ++;
        if (idx == self.titles.count - 1) {
            [self.scrollView setContentSize:CGSizeMake(width * (page + 1), scrollViewHeight)];
            self.pageControl.numberOfPages = page + 1;
            *stop = YES;
        }
    }];
}

#pragma mark - Getters

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        [self addSubview:(_scrollView = scrollView)];
    }
    return _scrollView;
}

- (UIPageControl *)pageControl{
    if (!_pageControl) {
        UIPageControl *pageControl = [[UIPageControl alloc] init];//WithFrame:CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 20)];
        pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        pageControl.hidesForSinglePage = YES;
        [self addSubview:(_pageControl = pageControl)];
    }
    return _pageControl;
}

- (UIColor *)messageInputViewMorePanelBackgroundColor {
    if (_messageInputViewMorePanelBackgroundColor) {
        return _messageInputViewMorePanelBackgroundColor;
    }
    _messageInputViewMorePanelBackgroundColor = [[CYLSettingService sharedInstance] defaultThemeColorForKey:@"MessageInputView-MorePanel-BackgroundColor"];
    return _messageInputViewMorePanelBackgroundColor;
}

@end

