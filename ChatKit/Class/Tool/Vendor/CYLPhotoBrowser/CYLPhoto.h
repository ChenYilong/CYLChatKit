//
//  CYLPhoto.h
//  CYLPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYLPhotoProtocol.h"
#if __has_include(<SDWebImage/SDWebImageManager.h>)
#import <SDWebImage/SDWebImageManager.h>
#else
#import "SDWebImageManager.h"
#endif

// This class models a photo/image and it's caption
// If you want to handle photos, caching, decompression
// yourself then you can simply ensure your custom data model
// conforms to CYLPhotoProtocol
@interface CYLPhoto : NSObject <CYLPhoto>

// Progress download block, used to update the circularView
typedef void (^CYLProgressUpdateBlock)(CGFloat progress);

// Properties
@property (nonatomic, strong) CYLProgressUpdateBlock progressUpdateBlock;

@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) UIImage *underlyingImage;
@property (nonatomic, strong) UIImageView *placeholderImageView;
@property (nonatomic, assign, readonly) CGRect placeholderFrame;
@property (nonatomic, assign, readonly) BOOL loadingInProgress;

// Class
+ (CYLPhoto *)photoWithImage:(UIImage *)image;
+ (CYLPhoto *)photoWithFilePath:(NSString *)path;
+ (CYLPhoto *)photoWithURL:(NSURL *)url;

+ (NSArray *)photosWithImages:(NSArray *)imagesArray;
+ (NSArray *)photosWithFilePaths:(NSArray *)pathsArray;
+ (NSArray *)photosWithURLs:(NSArray *)urlsArray;

//+ (NSArray *)photosWithImages:(NSArray *)imagesArray placeholderImageViews:(NSArray *)placeholderImageViews;
//+ (NSArray *)photosWithFilePaths:(NSArray *)pathsArray placeholderImageViews:(NSArray *)placeholderImageViews;
//+ (NSArray *)photosWithURLs:(NSArray *)urlsArray placeholderImageViews:(NSArray *)placeholderImageViews;

// Init
- (id)initWithImage:(UIImage *)image;
- (id)initWithFilePath:(NSString *)path;
- (id)initWithURL:(NSURL *)url;

@end

