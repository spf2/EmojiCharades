//
//  YKUIImageView.m
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

#import "YKUIImageView.h"
#import "YKCGUtils.h"
#import "YKLocalized.h"


@implementation YKUIImageBaseView

@synthesize image=_image, status=_status, delegate=_delegate, imageLoader=_imageLoader;

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.opaque = NO;
    self.backgroundColor = [UIColor whiteColor];
    self.contentMode = UIViewContentModeScaleAspectFit;

    [self setIsAccessibilityElement:YES];
    [self setAccessibilityTraits:UIAccessibilityTraitImage];
  }
  return self;
}

- (id)initWithImage:(UIImage *)image {
  if ((self = [self initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)])) {
    self.image = image;
  }
  return self;
}

- (id)initWithURLString:(NSString *)URLString loadingImage:(UIImage *)loadingImage defaultImage:(UIImage *)defaultImage {
  if ((self = [self initWithFrame:CGRectZero])) {
    [self setURLString:URLString loadingImage:loadingImage defaultImage:defaultImage];
  }
  return self;
}

- (void)dealloc {
  _imageLoader.delegate = nil;
  [_imageLoader release];
  [_image release];
  [super dealloc];
}

- (void)cancel {
  [_imageLoader cancel];
}

- (void)reset {
  [_image release];
  _image = nil;
  _status = YKUIImageViewStatusNone;
  _imageLoader.delegate = nil;
  [_imageLoader release];
  _imageLoader = nil;
  [self setNeedsDisplay];
  [self setNeedsLayout];
}

- (void)setURLString:(NSString *)URLString loadingImage:(UIImage *)loadingImage defaultImage:(UIImage *)defaultImage {
  if ([URLString isEqual:[NSNull null]]) URLString = nil;
  
  [self reset];
  if (URLString) {
    _imageLoader = [[YKImageLoader alloc] initWithLoadingImage:loadingImage defaultImage:defaultImage delegate:self];
    [_imageLoader setURL:[YKURL URLString:URLString]];
  }
}

- (void)setURLString:(NSString *)URLString defaultImage:(UIImage *)defaultImage {
  [self setURLString:URLString loadingImage:nil defaultImage:defaultImage];
}

- (void)setURLString:(NSString *)URLString {
  [self setURLString:URLString defaultImage:nil];
}

- (NSString *)URLString {
  return _imageLoader.URL.URLString;
}

- (void)setImage:(UIImage *)image {
  [self reset];
  [image retain];
  [_image release];
  _image = image;  
  [self setNeedsDisplay];
  [self setNeedsLayout];
}

- (void)_setImage:(UIImage *)image {
  [image retain];
  [_image release];
  _image = image;
  [self setNeedsDisplay];
  [self setNeedsLayout];
}

- (CGSize)size {
  if (!_image) return CGSizeZero;
  return _image.size;
}

- (CGSize)sizeThatFits:(CGSize)size {  
  CGSize sizeThatFits = [self size];
  if (sizeThatFits.width > size.width || sizeThatFits.height > size.height) {    
    CGRect scale = YKCGRectScaleAspectAndCenter(sizeThatFits, size, YES);    
    sizeThatFits.width = scale.size.width;
    sizeThatFits.height = scale.size.height;
  }  
  return sizeThatFits;
}

- (void)reload {
  [self setURLString:_imageLoader.URL.URLString loadingImage:_imageLoader.loadingImage defaultImage:_imageLoader.defaultImage];
}

- (void)didLoadImage:(UIImage *)image { }

#pragma mark Delegates (YKImageLoader)

- (void)imageLoaderDidStart:(YKImageLoader *)imageLoader { 
  if ([self.delegate respondsToSelector:@selector(imageViewDidStart:)])
    [self.delegate imageViewDidStart:self];
}

- (void)imageLoader:(YKImageLoader *)imageLoader didUpdateStatus:(YKImageLoaderStatus)status image:(UIImage *)image { 
  switch (status) {
    case YKImageLoaderStatusNone: _status = YKUIImageViewStatusNone; break;
    case YKImageLoaderStatusLoading: _status = YKUIImageViewStatusLoading; break;
    case YKImageLoaderStatusLoaded: _status = YKUIImageViewStatusLoaded; break;
    default:
      break;
  }
  
  [self _setImage:image];
  if (image) {
    [self didLoadImage:image];
    if ([self.delegate respondsToSelector:@selector(imageView:didLoadImage:)])
      [self.delegate imageView:self didLoadImage:self.image];
  }
}

- (void)imageLoader:(YKImageLoader *)imageLoader didError:(YKError *)error {
  _status = YKUIImageViewStatusErrored;
  [self setNeedsDisplay];
  
  if ([self.delegate respondsToSelector:@selector(imageView:didError:)])
    [self.delegate imageView:self didError:error];
}

- (void)imageLoaderDidCancel:(YKImageLoader *)imageLoader { 
  _status = YKUIImageViewStatusNone;
  if ([self.delegate respondsToSelector:@selector(imageViewDidCancel:)])
    [self.delegate imageViewDidCancel:self];
}

@end



@implementation YKUIImageView

@synthesize strokeColor=_strokeColor, strokeWidth=_strokeWidth, cornerRadius=_cornerRadius;

- (void)dealloc {
  [_strokeColor release];
  [super dealloc];
}

#pragma mark Drawing

// From Three20: UIImageAdditions
+ (void)drawImage:(UIImage *)image inRect:(CGRect)rect contentMode:(UIViewContentMode)contentMode {
  if (!image) return;
  
  BOOL clip = NO;
  CGRect originalRect = rect;
  if (image.size.width != rect.size.width || image.size.height != rect.size.height) {
    clip = contentMode != UIViewContentModeScaleAspectFill && contentMode != UIViewContentModeScaleAspectFit;
    rect = YKCGRectConvert(rect, image.size, contentMode);
  }
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  if (clip) {
    CGContextSaveGState(context);
    CGContextAddRect(context, originalRect);
    CGContextClip(context);
  }
  
  //YKDebug(@"Drawing image with size: %@ in %@ (%@)", NSStringFromCGSize(image.size), NSStringFromCGRect(rect), YKNSStringFromUIViewContentMode(contentMode));
  [image drawInRect:rect];
  
  if (clip) {
    CGContextRestoreGState(context);
  }
}


- (void)drawInRect:(CGRect)rect contentMode:(UIViewContentMode)contentMode {
  [YKUIImageView drawImage:_image inRect:rect contentMode:contentMode];
}

- (void)drawInRect:(CGRect)rect {
  CGRect bounds = rect;
  
  CGContextRef context = UIGraphicsGetCurrentContext();

  if (_cornerRadius > 0) {
    YKCGContextDrawRoundedRectImage(context, self.image.CGImage, rect, _strokeColor.CGColor, _strokeWidth, _cornerRadius, YES, YES, self.backgroundColor.CGColor);
  } else {  
    if (self.backgroundColor) {
      YKCGContextDrawRect(context, bounds, self.backgroundColor.CGColor, NULL, 0);
    }
    [self drawInRect:bounds contentMode:self.contentMode];  
  }
}

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  [self drawInRect:self.bounds];
}

@end
