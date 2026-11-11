// Credit: adapted from AGEmojiKeyBoardView (third-party source). Renamed CYLEmojiKeyboardView with its file, following the CYL naming rule
// (AGENTS.md, docs/naming.md).
//
//  CYLEmojiKeyboardView.h
//  CYLEmojiKeyboard
//
//  Created by Ayush on 09/05/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//
// Set as inputView to textfields, this view class gives an
// interface to the user to enter emoji characters.

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CYLEmojiKeyboardViewCategoryImage) {
  CYLEmojiKeyboardViewCategoryImageRecent,
  CYLEmojiKeyboardViewCategoryImageFace,
  CYLEmojiKeyboardViewCategoryImageBell,
  CYLEmojiKeyboardViewCategoryImageFlower,
  CYLEmojiKeyboardViewCategoryImageCar,
  CYLEmojiKeyboardViewCategoryImageCharacters
};

@protocol CYLEmojiKeyboardViewDelegate;
@protocol CYLEmojiKeyboardViewDataSource;

/**
 Keyboard class to present as an alternate.
 This keyboard presents the emojis supported by iOS.

 @note To modify appearance, use @p segmentsBar @p pageControl
 @p emojiPagesScrollView properties.
 */
@interface CYLEmojiKeyboardView : UIView

/**
 Segment control displays the categories.
 */
@property (nonatomic, readonly) UISegmentedControl *segmentsBar;

/**
 Pagecontrol displays the current page and number of pages on an emoji page.
 */
@property (nonatomic, readonly) UIPageControl *pageControl;

/**
 Scroll view displays all the emoji pages.
 */
@property (nonatomic, readonly) UIScrollView *emojiPagesScrollView;

@property (nonatomic, weak) id<CYLEmojiKeyboardViewDelegate> delegate;
@property (nonatomic, weak) id<CYLEmojiKeyboardViewDataSource> dataSource;

/**
 @param frame Frame of the view to be initialised with.

 @param dataSource dataSource is required during the initialization to
 get all the relevent images to present in the view.
 */
- (instancetype)initWithFrame:(CGRect)frame
                   dataSource:(id<CYLEmojiKeyboardViewDataSource>)dataSource;

@end


/**
 Protocol to be followed by the dataSource of `CYLEmojiKeyboardView`.
 */
@protocol CYLEmojiKeyboardViewDataSource <NSObject>

/**
 Method called on dataSource to get the category image when selected.

 @param emojiKeyboardView EmojiKeyBoardView object on which user has tapped.

 @param category category to get the image for. @see CYLEmojiKeyboardViewCategoryImage
 */
- (UIImage *)emojiKeyboardView:(CYLEmojiKeyboardView *)emojiKeyboardView
      imageForSelectedCategory:(CYLEmojiKeyboardViewCategoryImage)category;

/**
 Method called on dataSource to get the category image when not-selected.

 @param emojiKeyboardView EmojiKeyBoardView object on which user has tapped.

 @param category category to get the image for. @see CYLEmojiKeyboardViewCategoryImage
 */
- (UIImage *)emojiKeyboardView:(CYLEmojiKeyboardView *)emojiKeyboardView
   imageForNonSelectedCategory:(CYLEmojiKeyboardViewCategoryImage)category;

/**
 Method called on dataSource to get the back button image to be shown in the view.

 @param emojiKeyboardView EmojiKeyBoardView object on which user has tapped.
 */
- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(CYLEmojiKeyboardView *)emojiKeyboardView;

@optional

/**
 Method called on dataSource to get category that should be shown by
 default i.e. when the keyboard is just presented.

 @note By default `CYLEmojiKeyboardViewCategoryImageRecent` is shown.

 @param emojiKeyboardView EmojiKeyBoardView object shown.
 */
- (CYLEmojiKeyboardViewCategoryImage)defaultCategoryForEmojiKeyboardView:(CYLEmojiKeyboardView *)emojiKeyboardView;

/**
 Method called on dataSource to get number of emojis to be maintained in
 recent category.

 @note By default `50` is used.

 @param emojiKeyboardView EmojiKeyBoardView object shown.
 */
- (NSUInteger)recentEmojisMaintainedCountForEmojiKeyboardView:(CYLEmojiKeyboardView *)emojiKeyboardView;

@end


/**
 Protocol to be followed by the delegate of `CYLEmojiKeyboardView`.
 */
@protocol CYLEmojiKeyboardViewDelegate <NSObject>

/**
 Delegate method called when user taps an emoji button

 @param emojiKeyBoardView EmojiKeyBoardView object on which user has tapped.

 @param emoji Emoji used by user
 */
- (void)emojiKeyBoardView:(CYLEmojiKeyboardView *)emojiKeyBoardView
              didUseEmoji:(NSString *)emoji;

/**
 Delegate method called when user taps on the backspace button

 @param emojiKeyBoardView EmojiKeyBoardView object on which user has tapped.
 */
- (void)emojiKeyBoardViewDidPressBackSpace:(CYLEmojiKeyboardView *)emojiKeyBoardView;

@end
