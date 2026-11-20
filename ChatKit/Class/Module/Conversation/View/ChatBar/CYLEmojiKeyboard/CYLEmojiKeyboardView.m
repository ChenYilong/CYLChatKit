// Credit: adapted from AGEmojiKeyBoardView (third-party source). Renamed CYLEmojiKeyboardView with its file, following the CYL naming rule
// (AGENTS.md, docs/naming.md).
//
//  CYLEmojiKeyboardView.m
//  CYLEmojiKeyboard
//
//  Created by Ayush on 09/05/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//

#import "CYLEmojiKeyboardView.h"
#import "CYLEmojiPageView.h"

#define SCREENWIDTH [[UIScreen mainScreen] bounds].size.width

#define kCYLTopLineBackgroundColor [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f]

static const CGFloat ButtonWidth = 45;
static const CGFloat ButtonHeight = 37;

static const NSUInteger DefaultRecentEmojisMaintainedCount = 50;

static NSString *const segmentRecentName = @"Recent";
NSString *const RecentUsedEmojiCharactersKey = @"RecentUsedEmojiCharactersKey";


@interface CYLEmojiKeyboardView () <UIScrollViewDelegate, CYLEmojiPageViewDelegate>

@property (nonatomic) UISegmentedControl *segmentsBar;
@property (nonatomic) UIPageControl *pageControl;
@property (nonatomic) UIScrollView *emojiPagesScrollView;
@property (nonatomic) UIView *bottomView;
@property (nonatomic) NSDictionary *emojis;
@property (nonatomic) NSMutableArray *pageViews;
@property (nonatomic) NSString *category;
@property (weak, nonatomic) UIButton *sendButton;

@end

@implementation CYLEmojiKeyboardView

- (NSDictionary *)emojis {
  if (!_emojis) {
    NSBundle *selfBundle = [NSBundle bundleForClass:[self class]];
    NSString *plistPath = [selfBundle pathForResource:@"EmojisList"
                                               ofType:@"plist"];
    _emojis = [[NSDictionary dictionaryWithContentsOfFile:plistPath] copy];
  }
  return _emojis;
}

- (NSString *)categoryNameAtIndex:(NSUInteger)index {
  NSArray *categoryList = @[segmentRecentName, @"People", @"Objects", @"Nature", @"Places", @"Symbols"];
  return categoryList[index];
}

- (CYLEmojiKeyboardViewCategoryImage)defaultSelectedCategory {
  if ([self.dataSource respondsToSelector:@selector(defaultCategoryForEmojiKeyboardView:)]) {
    return [self.dataSource defaultCategoryForEmojiKeyboardView:self];
  }
  return CYLEmojiKeyboardViewCategoryImageRecent;
}

- (NSUInteger)recentEmojisMaintainedCount {
  if ([self.dataSource respondsToSelector:@selector(recentEmojisMaintainedCountForEmojiKeyboardView:)]) {
    return [self.dataSource recentEmojisMaintainedCountForEmojiKeyboardView:self];
  }
  return DefaultRecentEmojisMaintainedCount;
}

- (NSArray *)imagesForSelectedSegments {
  static NSMutableArray *array;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    array = [NSMutableArray array];
    for (CYLEmojiKeyboardViewCategoryImage i = CYLEmojiKeyboardViewCategoryImageRecent;
         i <= CYLEmojiKeyboardViewCategoryImageCharacters;
         ++i) {
      [array addObject:[self.dataSource emojiKeyboardView:self imageForSelectedCategory:i]];
    }
  });
  return array;
}

- (NSArray *)imagesForNonSelectedSegments {
  static NSMutableArray *array;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    array = [NSMutableArray array];
    for (CYLEmojiKeyboardViewCategoryImage i = CYLEmojiKeyboardViewCategoryImageRecent;
         i <= CYLEmojiKeyboardViewCategoryImageCharacters;
         ++i) {
      [array addObject:[self.dataSource emojiKeyboardView:self imageForNonSelectedCategory:i]];
    }
  });
  return array;
}

// recent emojis are backed in NSUserDefaults to save them across app restarts.
- (NSMutableArray *)recentEmojis {
  NSArray *emojis = [[NSUserDefaults standardUserDefaults] arrayForKey:RecentUsedEmojiCharactersKey];
  NSMutableArray *recentEmojis = [emojis mutableCopy];
  if (recentEmojis == nil) {
    recentEmojis = [NSMutableArray array];
  }
  return recentEmojis;
}

- (void)setRecentEmojis:(NSMutableArray *)recentEmojis {
  // remove emojis if they cross the cache maintained limit
  if ([recentEmojis count] > self.recentEmojisMaintainedCount) {
    NSRange indexRange = NSMakeRange(self.recentEmojisMaintainedCount,
                                     [recentEmojis count] - self.recentEmojisMaintainedCount);
    NSIndexSet *indexesToBeRemoved = [NSIndexSet indexSetWithIndexesInRange:indexRange];
    [recentEmojis removeObjectsAtIndexes:indexesToBeRemoved];
  }
  [[NSUserDefaults standardUserDefaults] setObject:recentEmojis forKey:RecentUsedEmojiCharactersKey];
}

- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<CYLEmojiKeyboardViewDataSource>)dataSource {
  self = [super initWithFrame:frame];
  if (self) {
    // initialize category

    _dataSource = dataSource;

      self.category = [self categoryNameAtIndex:self.defaultSelectedCategory];

      CGRect scrollViewFrame = CGRectMake(0,0,
                                          CGRectGetWidth(self.bounds),
                                          CGRectGetHeight(self.bounds) - 40 - 35);
      self.emojiPagesScrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
      self.emojiPagesScrollView.pagingEnabled = YES;
      self.emojiPagesScrollView.showsHorizontalScrollIndicator = NO;
      self.emojiPagesScrollView.showsVerticalScrollIndicator = NO;
      self.emojiPagesScrollView.delegate = self;

      [self addSubview:self.emojiPagesScrollView];

      self.pageControl = [[UIPageControl alloc] init];
      self.pageControl.hidesForSinglePage = YES;
      self.pageControl.currentPage = 0;
      self.pageControl.backgroundColor = [UIColor clearColor];
      CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:3];
      CGSize frameSize = CGSizeMake(CGRectGetWidth(self.bounds),15);
      NSUInteger numberOfPages = [self numberOfPagesForCategory:self.category
                                                    inFrameSize:frameSize];
      self.pageControl.numberOfPages = numberOfPages;
      pageControlSize = [self.pageControl sizeForNumberOfPages:numberOfPages];
      CGRect pageControlFrame = CGRectMake((CGRectGetWidth(self.bounds) - pageControlSize.width) / 2,
                                           CGRectGetHeight(self.emojiPagesScrollView.bounds),
                                           pageControlSize.width,
                                           pageControlSize.height);
      self.pageControl.frame = CGRectIntegral(pageControlFrame);
      [self.pageControl addTarget:self
                           action:@selector(pageControlTouched:)
                 forControlEvents:UIControlEventValueChanged];
      [self addSubview:self.pageControl];

      self.segmentsBar = [[UISegmentedControl alloc] initWithItems:self.imagesForSelectedSegments];
      self.segmentsBar.frame = CGRectMake(0,
                                          CGRectGetHeight(self.bounds) - 50,
                                          CGRectGetWidth(self.bounds),
                                          45);
      self.segmentsBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
      [self.segmentsBar addTarget:self
                           action:@selector(categoryChangedViaSegmentsBar:)
                 forControlEvents:UIControlEventValueChanged];
      [self setSelectedCategoryImageInSegmentControl:self.segmentsBar
                                             atIndex:self.defaultSelectedCategory];
      self.segmentsBar.selectedSegmentIndex = self.defaultSelectedCategory;
      [self addSubview:self.segmentsBar];

      self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 40, SCREENWIDTH, 40)];
      self.bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
      UIImageView *topLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH - 70, 1.0f)];
      topLine.backgroundColor = kCYLTopLineBackgroundColor;
      [self.bottomView addSubview:topLine];
      UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 70, 0, 70, 40)];
      sendButton.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:70.0f/255.0f blue:1.0f alpha:1.0f];
      [sendButton setTitle:@"发送" forState:UIControlStateNormal];
      [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
      [sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
      [self.bottomView addSubview:self.sendButton = sendButton];
      [self addSubview:self.bottomView];

      self.segmentsBar.hidden = YES;
      self.category = [self categoryNameAtIndex:1];
      self.pageControl.currentPage = 0;
      [self setNeedsLayout];
  }
  return self;
}

- (void)layoutSubviews {
  CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:3];
  NSUInteger numberOfPages = [self numberOfPagesForCategory:self.category
                                                inFrameSize:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.segmentsBar.bounds) - pageControlSize.height)];

  NSInteger currentPage = (self.pageControl.currentPage > numberOfPages) ? numberOfPages : self.pageControl.currentPage;

  // if (currentPage > numberOfPages) it is set implicitly to max pageNumber available
  self.pageControl.numberOfPages = numberOfPages;
  pageControlSize = [self.pageControl sizeForNumberOfPages:numberOfPages];
  CGRect pageControlFrame = CGRectMake((CGRectGetWidth(self.bounds) - pageControlSize.width) / 2,
                                       CGRectGetHeight(self.emojiPagesScrollView.bounds),
                                       pageControlSize.width,
                                       pageControlSize.height);
  self.pageControl.frame = CGRectIntegral(pageControlFrame);

  self.emojiPagesScrollView.frame = CGRectMake(0,
                                               0,
                                               CGRectGetWidth(self.bounds),
                                               CGRectGetHeight(self.bounds) - 75);
  [self.emojiPagesScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  self.emojiPagesScrollView.contentOffset = CGPointMake(CGRectGetWidth(self.emojiPagesScrollView.bounds) * currentPage, 0);
  self.emojiPagesScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.emojiPagesScrollView.bounds) * numberOfPages,
                                                     CGRectGetHeight(self.emojiPagesScrollView.bounds));
  [self purgePageViews];
  self.pageViews = [NSMutableArray array];
  [self setPage:currentPage];
}

#pragma mark event handlers

- (void)setSelectedCategoryImageInSegmentControl:(UISegmentedControl *)segmentsBar
                                         atIndex:(NSInteger)index {
  for (int i=0; i < self.segmentsBar.numberOfSegments; ++i) {
    [segmentsBar setImage:self.imagesForNonSelectedSegments[i] forSegmentAtIndex:i];
  }
  [segmentsBar setImage:self.imagesForSelectedSegments[index] forSegmentAtIndex:index];
}

- (void)categoryChangedViaSegmentsBar:(UISegmentedControl *)sender {
  // recalculate number of pages for new category and recreate emoji pages
  self.category = [self categoryNameAtIndex:sender.selectedSegmentIndex];
  [self setSelectedCategoryImageInSegmentControl:sender
                                         atIndex:sender.selectedSegmentIndex];
  self.pageControl.currentPage = 0;
  [self setNeedsLayout];
}

- (void)pageControlTouched:(UIPageControl *)sender {
  CGRect bounds = self.emojiPagesScrollView.bounds;
  bounds.origin.x = CGRectGetWidth(bounds) * sender.currentPage;
  bounds.origin.y = 0;
  // scrollViewDidScroll is called here. Page set at that time.
  [self.emojiPagesScrollView scrollRectToVisible:bounds animated:YES];
}

// Track the contentOffset of the scroll view, and when it passes the mid
// point of the current view’s width, the views are reconfigured.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
  NSInteger newPageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
  if (self.pageControl.currentPage == newPageNumber) {
    return;
  }
  self.pageControl.currentPage = newPageNumber;
  [self setPage:self.pageControl.currentPage];
}

#pragma mark change a page on scrollView

// Check if setting pageView for an index is required
- (BOOL)requireToSetPageViewForIndex:(NSUInteger)index {
  if (index >= self.pageControl.numberOfPages) {
    return NO;
  }
  for (CYLEmojiPageView *page in self.pageViews) {
    if ((page.frame.origin.x / CGRectGetWidth(self.emojiPagesScrollView.bounds)) == index) {
      return NO;
    }
  }
  return YES;
}

// Create a pageView and add it to the scroll view.
- (CYLEmojiPageView *)synthesizeEmojiPageView {
  NSUInteger rows = [self numberOfRowsForFrameSize:self.emojiPagesScrollView.bounds.size];
  NSUInteger columns = [self numberOfColumnsForFrameSize:self.emojiPagesScrollView.bounds.size];
  CGRect pageViewFrame = CGRectMake(0,
                                    0,
                                    CGRectGetWidth(self.emojiPagesScrollView.bounds),
                                    CGRectGetHeight(self.emojiPagesScrollView.bounds));
  CYLEmojiPageView *pageView = [[CYLEmojiPageView alloc] initWithFrame: pageViewFrame
                                                backSpaceButtonImage:[self.dataSource backSpaceButtonImageForEmojiKeyboardView:self]
                                                          buttonSize:CGSizeMake(ButtonWidth, ButtonHeight)
                                                                rows:rows
                                                             columns:columns];
  pageView.delegate = self;
  [self.pageViews addObject:pageView];
  [self.emojiPagesScrollView addSubview:pageView];
  return pageView;
}

// return a pageView that can be used in the current scrollView.
// look for an available pageView in current pageView-s on scrollView.
// If all are in use i.e. are of current page or neighbours
// of current page, we create a new one

- (CYLEmojiPageView *)usableEmojiPageView {
  CYLEmojiPageView *pageView = nil;
  for (CYLEmojiPageView *page in self.pageViews) {
    NSUInteger pageNumber = page.frame.origin.x / CGRectGetWidth(self.emojiPagesScrollView.bounds);
    if (abs((int)(pageNumber - self.pageControl.currentPage)) > 1) {
      pageView = page;
      break;
    }
  }
  if (!pageView) {
    pageView = [self synthesizeEmojiPageView];
  }
  return pageView;
}

// Set emoji page view for given index.
- (void)setEmojiPageViewInScrollView:(UIScrollView *)scrollView atIndex:(NSUInteger)index {

  if (![self requireToSetPageViewForIndex:index]) {
    return;
  }

  CYLEmojiPageView *pageView = [self usableEmojiPageView];

  NSUInteger rows = [self numberOfRowsForFrameSize:scrollView.bounds.size];
  NSUInteger columns = [self numberOfColumnsForFrameSize:scrollView.bounds.size];
  NSUInteger startingIndex = index * (rows * columns - 1);
  NSUInteger endingIndex = (index + 1) * (rows * columns - 1);
  NSMutableArray *buttonTexts = [self emojiTextsForCategory:self.category
                                                  fromIndex:startingIndex
                                                    toIndex:endingIndex];
  [pageView setButtonTexts:buttonTexts];
  pageView.frame = CGRectMake(index * CGRectGetWidth(scrollView.bounds),
                              0,
                              CGRectGetWidth(scrollView.bounds),
                              CGRectGetHeight(scrollView.bounds));
}

// Set the current page.
// sets neightbouring pages too, as they are viewable by part scrolling.
- (void)setPage:(NSInteger)page {
  [self setEmojiPageViewInScrollView:self.emojiPagesScrollView atIndex:page - 1];
  [self setEmojiPageViewInScrollView:self.emojiPagesScrollView atIndex:page];
  [self setEmojiPageViewInScrollView:self.emojiPagesScrollView atIndex:page + 1];
}

- (void)purgePageViews {
  for (CYLEmojiPageView *page in self.pageViews) {
    page.delegate = nil;
  }
  self.pageViews = nil;
}

#pragma mark data methods

- (NSUInteger)numberOfColumnsForFrameSize:(CGSize)frameSize {
  return (NSUInteger)floor(frameSize.width / ButtonWidth);
}

- (NSUInteger)numberOfRowsForFrameSize:(CGSize)frameSize {
  return (NSUInteger)floor(frameSize.height / ButtonHeight);
}

- (NSArray *)emojiListForCategory:(NSString *)category {
  if ([category isEqualToString:segmentRecentName]) {
    return [self recentEmojis];
  }
  return [self.emojis objectForKey:category];
}

// for a given frame size of scroll view, return the number of pages
// required to show all the emojis for a category
- (NSUInteger)numberOfPagesForCategory:(NSString *)category inFrameSize:(CGSize)frameSize {

  if ([category isEqualToString:segmentRecentName]) {
    return 1;
  }

  NSUInteger emojiCount = [[self emojiListForCategory:category] count];
  NSUInteger numberOfRows = [self numberOfRowsForFrameSize:frameSize];
  NSUInteger numberOfColumns = [self numberOfColumnsForFrameSize:frameSize];
  NSUInteger numberOfEmojisOnAPage = (numberOfRows * numberOfColumns) - 1;

  NSUInteger numberOfPages = (NSUInteger)ceil((float)emojiCount / numberOfEmojisOnAPage);
  return numberOfPages;
}

// return the emojis for a category, given a staring and an ending index
- (NSMutableArray *)emojiTextsForCategory:(NSString *)category
                                fromIndex:(NSUInteger)start
                                  toIndex:(NSUInteger)end {
  NSArray *emojis = [self emojiListForCategory:category];
  end = ([emojis count] > end)? end : [emojis count];
  NSIndexSet *index = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(start, end-start)];
  return [[emojis objectsAtIndexes:index] mutableCopy];
}

#pragma mark EmojiPageViewDelegate

- (void)setInRecentsEmoji:(NSString *)emoji {
  NSAssert(emoji != nil, @"Emoji can't be nil");

  NSMutableArray *recentEmojis = [self recentEmojis];
  for (int i = 0; i < [recentEmojis count]; ++i) {
    if ([recentEmojis[i] isEqualToString:emoji]) {
      [recentEmojis removeObjectAtIndex:i];
    }
  }
  [recentEmojis insertObject:emoji atIndex:0];
  [self setRecentEmojis:recentEmojis];
}

// add the emoji to recents
- (void)emojiPageView:(CYLEmojiPageView *)emojiPageView didUseEmoji:(NSString *)emoji {
  [self setInRecentsEmoji:emoji];
  [self.delegate emojiKeyBoardView:self didUseEmoji:emoji];
}

- (void)emojiPageViewDidPressBackSpace:(CYLEmojiPageView *)emojiPageView {
  [self.delegate emojiKeyBoardViewDidPressBackSpace:self];
}

#pragma mark - buttonClick
- (void)sendAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiKeyBoardView:didUseEmoji:)]) {
        [self.delegate emojiKeyBoardView:self didUseEmoji:@"发送"];
    }
}

@end
