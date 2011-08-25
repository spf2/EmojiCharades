//
//  YKUIImageView.h
//  YelpKit
//
//  Created by Gabriel Handford on 12/30/08.
//  Copyright 2008 Yelp. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "YKUIView.h"
#import "YKImageLoader.h"


@protocol YKUIImageView <NSObject>
@property (retain, nonatomic) UIImage *image;
@property (retain, nonatomic) NSString *URLString;
@end


typedef enum {
  YKUIImageViewStatusNone,
  YKUIImageViewStatusLoading,
  YKUIImageViewStatusLoaded,
  YKUIImageViewStatusErrored
} YKUIImageViewStatus;

@class YKUIImageView;

@protocol YKUIImageViewDelegate <NSObject>
@optional
- (void)imageView:(id<YKUIImageView>)imageView didLoadImage:(UIImage *)image;
- (void)imageViewDidStart:(id<YKUIImageView>)imageView;
- (void)imageView:(id<YKUIImageView>)imageView didError:(YKError *)error;
- (void)imageViewDidCancel:(id<YKUIImageView>)imageView;
@end


/*!
 Image base view. Doesn't draw contents. See YKUIImageView.
 */
@interface YKUIImageBaseView : YKUIView <YKUIImageView, YKImageLoaderDelegate> {
  YKImageLoader *_imageLoader;
  YKUIImageViewStatus _status;
  UIImage *_image;  
  id<YKUIImageViewDelegate> _delegate;
}

@property (readonly, nonatomic) YKUIImageViewStatus status;
@property (assign, nonatomic) id<YKUIImageViewDelegate> delegate;
@property (readonly, nonatomic) YKImageLoader *imageLoader;


/*!
 Image size.
 @result Image size or CGSizeZero if no image set
 */
@property (readonly, nonatomic) CGSize size;


- (id)initWithImage:(UIImage *)image;

- (id)initWithURLString:(NSString *)URLString loadingImage:(UIImage *)loadingImage defaultImage:(UIImage *)defaultImage;


// For subclasses to notify when image was loaded asynchronously
- (void)didLoadImage:(UIImage *)image;

/*!
 Cancel any image loading.
 */
- (void)cancel;

- (void)reload;

/*!
 Set URLString to load with loading image and default image (if loading fails).
 @param URLString
 @param loadingImage
 @param defaultImage
 */
- (void)setURLString:(NSString *)URLString loadingImage:(UIImage *)loadingImage defaultImage:(UIImage *)defaultImage;
- (void)setURLString:(NSString *)URLString defaultImage:(UIImage *)defaultImage;


@end


/*!
 Image view.

 Defaults to non-opaque with white background and fill aspect fit content mode.
 */
@interface YKUIImageView : YKUIImageBaseView { 

  // For manual rounded border style (non CALayer)
  UIColor *_strokeColor;
  CGFloat _strokeWidth;
  CGFloat _cornerRadius;
  
}

@property (retain, nonatomic) UIColor *strokeColor;
@property (assign, nonatomic) CGFloat strokeWidth;
@property (assign, nonatomic) CGFloat cornerRadius;

/*!
 Draw image in rect for current graphics context.
 @param rect
 @param contentMode
 */
- (void)drawInRect:(CGRect)rect contentMode:(UIViewContentMode)contentMode;

@end








