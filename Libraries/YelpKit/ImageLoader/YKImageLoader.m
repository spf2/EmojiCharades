//
//  YKImageLoader.m
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

#import "YKImageLoader.h"

#import "YKURLCache.h"
#import <GHKitIOS/GHNSObject+Invocation.h>
#import "YKResource.h"
#import "YKDefines.h"

@interface YKImageLoader ()
@property (retain, nonatomic) YKURL *URL;
@property (retain, nonatomic) UIImage *loadingImage;
- (UIImage *)_cachedImage:(YKURL *)URL;
- (void)setImage:(UIImage *)image status:(YKImageLoaderStatus)status;
@end

#define kExpiresAge YKTimeIntervalWeek

@implementation YKImageLoader

@synthesize URL=_URL, image=_image, loadingImage=_loadingImage, defaultImage=_defaultImage, delegate=_delegate, queue=_queue;

- (id)initWithLoadingImage:(UIImage *)loadingImage defaultImage:(UIImage *)defaultImage delegate:(id<YKImageLoaderDelegate>)delegate {
  if ((self = [self init])) {
    self.loadingImage = loadingImage;
    self.defaultImage = defaultImage;
    self.delegate = delegate;
  }
  return self;
}

+ (YKImageLoader *)imageLoaderWithURLString:(NSString *)URLString loadingImage:(UIImage *)loadingImage defaultImage:(UIImage *)defaultImage delegate:(id<YKImageLoaderDelegate>)delegate {
  YKImageLoader *imageLoader = [[YKImageLoader alloc] initWithLoadingImage:loadingImage defaultImage:defaultImage delegate:delegate];
  [imageLoader setURL:[YKURL URLString:URLString]];
  return [imageLoader autorelease]; 
}

- (void)dealloc {
  YKURLRequestRelease(_request);
  [_URL release];
  [_image release];
  [_defaultImage release];
  [_loadingImage release];
  [super dealloc];
}

- (void)setURL:(YKURL *)URL {
  // Use queue by default
  [self setURL:URL queue:[YKImageLoaderQueue sharedQueue]];
}

- (void)setURL:(YKURL *)URL queue:(YKImageLoaderQueue *)queue {  
  [self cancel];
  [URL retain];
  [_URL release];
  _URL = URL;  
  [_image release];
  _image = nil;
  _queue = queue;
   
#if YP_DEBUG
  self.URL.cacheDisabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"YKImageLoaderCacheDisabled"];
#endif
  
  if (!URL) {
    [self setImage:_defaultImage status:YKImageLoaderStatusNone];    
    return;
  }
  
  // Check for cached image, and set immediately if available
  UIImage *cachedImage = [self _cachedImage:self.URL];  
  if (cachedImage) {
    [self setImage:cachedImage status:YKImageLoaderStatusLoaded];
    return;
  }    
  
  // Check resource URL
  NSString *resourceName = [YKResource pathForBundleURL:[NSURL URLWithString:URL.URLString]];
  if (resourceName) {
    [self setImage:[UIImage imageNamed:resourceName] status:YKImageLoaderStatusLoaded];
    return;
  }
  
  // Put the loading image in place while waiting for the request to load
  [self setImage:_loadingImage status:YKImageLoaderStatusLoading];
  
  if (_queue) {
    [_queue enqueue:self];
  } else {
    [self load];
  }
}

- (UIImage *)_cachedImage:(YKURL *)URL {
  UIImage *image = [[YKURLCache sharedCache] cachedImageForURLString:_URL.cacheableURLString expires:kExpiresAge];
  //if (image) YKDebug(@"Cache hit for: %@", _URL);
  return image;
}

- (void)load {  
  YKURLRequestRelease(_request);
  
  _request = [[YKURLRequest alloc] init];
  _request.expiresAge = kExpiresAge;
    
  [_request requestWithURL:_URL headers:nil delegate:self 
            finishSelector:@selector(requestDidFinish:)
              failSelector:@selector(request:failedWithError:)
            cancelSelector:@selector(requestDidCancel:)];  
  
  if ([_delegate respondsToSelector:@selector(imageLoaderDidStart:)])
    [_delegate imageLoaderDidStart:self];
}

- (void)setImage:(UIImage *)image status:(YKImageLoaderStatus)status {
  //if (image == _image) return;
  [image retain];
  [_image release];
  _image = image;  
  //YKDebug(@"Update image for %@", _URL);
  [_delegate imageLoader:self didUpdateStatus:status image:image];
}

- (void)cancel {
  [_queue dequeue:self];
  [_request cancel];
}

- (void)setError:(YKError *)error {
  [self setImage:_defaultImage status:YKImageLoaderStatusErrored];
  if ([_delegate respondsToSelector:@selector(imageLoader:didError:)])
    [_delegate imageLoader:self didError:error];  
}

#pragma mark Delegates (YKURLRequest)

- (void)requestDidFinish:(YKURLRequest *)request {
  UIImage *image = [UIImage imageWithData:request.responseData];
  
  if (!image) {
    // Image data was not recognized or was invalid, we'll error
    [self setError:[YKError errorWithKey:YKErrorRequest]];
  } else {
    if (image && request.URL.cacheableURLString) {
      [[YKURLCache sharedCache] cacheImage:image forURLString:request.URL.cacheableURLString];
    }
    [self setImage:image status:YKImageLoaderStatusLoaded];
  }
  [_queue imageLoaderDidEnd:self];
}

- (void)request:(YKURLRequest *)request failedWithError:(NSError *)error {
  [self setImage:_defaultImage status:YKImageLoaderStatusErrored];
  if ([_delegate respondsToSelector:@selector(imageLoader:didError:)])
    [_delegate imageLoader:self didError:[YKError errorWithKey:YKErrorRequest error:error]];
  [_queue imageLoaderDidEnd:self];
}

- (void)requestDidCancel:(YKURLRequest *)request {
  if ([_delegate respondsToSelector:@selector(imageLoaderDidCancel:)])
    [_delegate imageLoaderDidCancel:self];
  [_queue imageLoaderDidEnd:self];
}

@end

@implementation YKImageLoaderQueue

- (id)init {
  if ((self = [super init])) {
    _waitingQueue = [[NSMutableArray alloc] initWithCapacity:40];
    _loadingQueue = [[NSMutableArray alloc] initWithCapacity:40];
    _maxLoadingCount = 2;
  }
  return self;
}

- (void)dealloc {  
  for (YKImageLoader *imageLoader in _waitingQueue)
    imageLoader.queue = nil;

  for (YKImageLoader *imageLoader in _loadingQueue)
    imageLoader.queue = nil;

  [_waitingQueue release];
  [_loadingQueue release];  
  [super dealloc];
}

+ (YKImageLoaderQueue *)sharedQueue {
  static YKImageLoaderQueue *gSharedQueue = NULL;
  @synchronized([YKImageLoaderQueue class]) {
    if (gSharedQueue == NULL) gSharedQueue = [[YKImageLoaderQueue alloc] init];
  }
  return gSharedQueue;
}

- (void)_updateIndicator {
  if ([_waitingQueue count] == 0 && [_loadingQueue count] == 0) [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  else [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)enqueue:(YKImageLoader *)imageLoader {
  YKAssertMainThread();
  if (![_waitingQueue containsObject:imageLoader]) {
    [_waitingQueue addObject:imageLoader];
    [self check];
    [self _updateIndicator];
  }
}

- (void)dequeue:(YKImageLoader *)imageLoader {
  YKAssertMainThread();  
  imageLoader.queue = nil;
  [_waitingQueue removeObject:imageLoader];
  [_loadingQueue removeObject:imageLoader];
  [self _updateIndicator];
}

- (void)check {
  if ([_loadingQueue count] < _maxLoadingCount && [_waitingQueue count] > 0) {    
    YKImageLoader *imageLoader = [_waitingQueue objectAtIndex:0];
    [_loadingQueue addObject:imageLoader];
    [_waitingQueue removeObjectAtIndex:0];
    imageLoader.queue = self;
    [imageLoader load];
    [self _updateIndicator];
  }
}

- (void)imageLoaderDidEnd:(YKImageLoader *)imageLoader {
  imageLoader.queue = nil;
  [_loadingQueue removeObject:imageLoader];
  [self _updateIndicator];
  [[self gh_proxyAfterDelay:0] check];
}

@end
