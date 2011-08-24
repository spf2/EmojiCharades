//
//  YKImageLoader.h
//  YelpIPhone
//
//  Created by Gabriel Handford on 4/14/09.
//  Copyright 2009 Yelp. All rights reserved.
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

#import "YKURLRequest.h"
#import "YKError.h"

@class YKImageLoader;
@class YKImageLoaderQueue;

typedef enum {
  YKImageLoaderStatusNone,
  YKImageLoaderStatusLoading,
  YKImageLoaderStatusLoaded,
  YKImageLoaderStatusErrored,
} YKImageLoaderStatus;

@protocol YKImageLoaderDelegate <NSObject>
- (void)imageLoader:(YKImageLoader *)imageLoader didUpdateStatus:(YKImageLoaderStatus)status image:(UIImage *)image;
@optional
- (void)imageLoaderDidStart:(YKImageLoader *)imageLoader;
- (void)imageLoader:(YKImageLoader *)imageLoader didError:(YKError *)error;
- (void)imageLoaderDidCancel:(YKImageLoader *)imageLoader;
@end

/*!
 Image loader.
 
 To disable the cache, set NSUserDefaults#boolForKey:@"YKImageLoaderCacheDisabled".
 */
@interface YKImageLoader : NSObject {  
  
  YKURLRequest *_request; 
  
  YKURL *_URL;
  UIImage *_image;
  UIImage *_defaultImage;
  UIImage *_loadingImage;
  id<YKImageLoaderDelegate> _delegate; // weak
  
  YKImageLoaderQueue *_queue; // weak
}

@property (readonly, retain, nonatomic) YKURL *URL;
@property (readonly, nonatomic) UIImage *image;
@property (retain, nonatomic) UIImage *defaultImage;
@property (readonly, retain, nonatomic) UIImage *loadingImage;
@property (assign, nonatomic) id<YKImageLoaderDelegate> delegate;
@property (assign, nonatomic) YKImageLoaderQueue *queue;

- (id)initWithLoadingImage:(UIImage *)loadingImage defaultImage:(UIImage *)defaultImage delegate:(id<YKImageLoaderDelegate>)delegate;

+ (YKImageLoader *)imageLoaderWithURLString:(NSString *)URLString loadingImage:(UIImage *)loadingImage defaultImage:(UIImage *)defaultImage delegate:(id<YKImageLoaderDelegate>)delegate;

/*!
 Load URL.
 By default this will use a loader queue; To override loadURLString:queue: with nil queue.
 @param URL
 */
- (void)setURL:(YKURL *)URL;

- (void)setURL:(YKURL *)URL queue:(YKImageLoaderQueue *)queue;

- (void)load;

- (void)cancel;

@end

@interface YKImageLoaderQueue : NSObject {
  NSMutableArray *_waitingQueue;
  NSMutableArray *_loadingQueue;
  
  NSInteger _maxLoadingCount;
}

+ (YKImageLoaderQueue *)sharedQueue;

- (void)enqueue:(YKImageLoader *)imageLoader;
- (void)dequeue:(YKImageLoader *)imageLoader;

- (void)check;

- (void)imageLoaderDidEnd:(YKImageLoader *)imageLoader;

@end
