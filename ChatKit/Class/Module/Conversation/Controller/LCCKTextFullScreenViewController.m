//
//  LCCKTextFullScreenViewController.m
//  LeanCloudIMKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/23.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "LCCKTextFullScreenViewController.h"

#if __has_include(<CYLDeallocBlockExecutor/CYLDeallocBlockExecutor.h>)
#import <CYLDeallocBlockExecutor/CYLDeallocBlockExecutor.h>
#else
#import "CYLDeallocBlockExecutor.h"
#endif

#import "LCCKFaceManager.h"
#define kLCCKTextFont [UIFont systemFontOfSize:30.0f]
static void * const LCCKTextFullScreenViewContentSizeContext = (void*)&LCCKTextFullScreenViewContentSizeContext;

@interface LCCKTextFullScreenViewController()

@property (nonatomic, weak) UIView *backgroundView;
@property (nonatomic, weak) UITextView *displayTextView;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy, readonly) NSDictionary *textStyle;
@property (nonatomic, copy) LCCKRemoveFromWindowHandler removeFromWindowHandler;
@end
@interface LCCKTextFullScreenViewController()<UITextViewDelegate>
@end
@implementation LCCKTextFullScreenViewController
@synthesize textStyle = _textStyle;

- (UITextView *)displayTextView {
    if (!_displayTextView) {
        UITextView *displayTextView = [[UITextView alloc] initWithFrame:self.view.frame];
        [displayTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:LCCKTextFullScreenViewContentSizeContext];
        [self cyl_willDeallocWithSelfCallback:^(__unsafe_unretained id owner, NSUInteger identifier) {
            [displayTextView removeObserver:owner forKeyPath:@"contentSize"];
        }];
        displayTextView.contentSize = self.view.bounds.size;
        displayTextView.textColor = [UIColor blackColor];
        displayTextView.editable = NO;
        displayTextView.backgroundColor = [UIColor whiteColor];
        displayTextView.dataDetectorTypes = UIDataDetectorTypeAll;
        displayTextView.textContainerInset = UIEdgeInsetsMake(0,20,0,20);
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFromWindow:)];
        recognizer.delegate = self;
        recognizer.numberOfTapsRequired = 1;
        [self.view addSubview:(_displayTextView = displayTextView)];
        [_displayTextView addGestureRecognizer:recognizer];
        [self.view bringSubviewToFront:_displayTextView];
    }
    return _displayTextView;
}

- (NSDictionary *)textStyle {
    if (!_textStyle) {
        UIFont *font = kLCCKTextFont;
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        style.alignment = NSTextAlignmentCenter;
        style.paragraphSpacing = 0.25 * font.lineHeight;
        style.hyphenationFactor = 1.0;
        _textStyle = @{NSFontAttributeName: font,
                       NSParagraphStyleAttributeName: style};
    }
    return _textStyle;
}

- (void)setRemoveFromWindowHandler:(LCCKRemoveFromWindowHandler)removeFromWindowHandler {
    _removeFromWindowHandler = removeFromWindowHandler;
}

- (void)removeFromWindow:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self.navigationController popViewControllerAnimated:NO];
    !_removeFromWindowHandler ?: _removeFromWindowHandler();
}

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (!self) {
        return nil;
    }
    _text = text;
    NSMutableAttributedString *attrS = [LCCKFaceManager emotionStrWithString:text];
    [attrS addAttributes:self.textStyle range:NSMakeRange(0, attrS.length)];
    self.displayTextView.attributedText = attrS;
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Life cycle

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(context != LCCKTextFullScreenViewContentSizeContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    if(context == LCCKTextFullScreenViewContentSizeContext) {
        UITextView *textView = object;
        CGFloat topCorrect = ([textView bounds].size.height - [textView contentSize].height * [textView zoomScale])/2.0;
        topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
        [textView setContentInset:UIEdgeInsetsMake(topCorrect,0,0,0)];
    }
}

@end
