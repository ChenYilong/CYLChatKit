//
//  CYLZoomingScrollView.h
//  CYLPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYLPhotoProtocol.h"
#import "CYLTapDetectingImageView.h"
#import "CYLTapDetectingView.h"
#if __has_include(<DACircularProgress/DACircularProgressView.h>)
#import <DACircularProgress/DACircularProgressView.h>
#else
#import "DACircularProgressView.h"
#endif

@class CYLPhoto, CYLCaptionView;

@protocol CYLZoomingScrollViewDelegate;

@interface CYLZoomingScrollView : UIScrollView <UIScrollViewDelegate, CYLTapDetectingImageViewDelegate, CYLTapDetectingViewDelegate> {
	
//	CYLPhotoBrowser *__weak _photoBrowser;
    id<CYLPhoto> _photo;
	
    // This view references the related caption view for simplified handling in photo browser
    CYLCaptionView *_captionView;
    
	CYLTapDetectingView *_tapView; // for background taps
    
    DACircularProgressView *_progressView;
    
    UIImageView *_loadingError;
}

@property (nonatomic, strong) CYLTapDetectingImageView *photoImageView;
@property (nonatomic, strong) CYLCaptionView *captionView;
@property (nonatomic, strong) id<CYLPhoto> photo;

//- (id)initWithPhotoBrowser:(CYLPhotoBrowser *)browser;
- (id)initWithPhotoDelegate:(id<CYLZoomingScrollViewDelegate>)photoDelegate;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setProgress:(CGFloat)progress forPhoto:(CYLPhoto*)photo;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;

- (void)animateImage;

@end

@protocol CYLZoomingScrollViewDelegate <NSObject>

@required
- (UIImage *)imageForPhoto:(id<CYLPhoto>)photo zoomingScrollView:(CYLZoomingScrollView *)zoomingScrollView;

@optional
- (UIColor *)trackTintColorForZoomingScrollView:(CYLZoomingScrollView *)zoomingScrollView;
- (UIColor *)progressTintColorForZoomingScrollView:(CYLZoomingScrollView *)zoomingScrollView;
- (CGFloat)animationDurationForZoomingScrollView:(CYLZoomingScrollView *)zoomingScrollView;

- (void)singleTapInZoomingScrollView:(CYLZoomingScrollView *)zoomingScrollView;
- (void)doubleTapInZoomingScrollView:(CYLZoomingScrollView *)zoomingScrollView;
- (void)longTapInZoomingScrollView:(CYLZoomingScrollView *)zoomingScrollView;

@end
