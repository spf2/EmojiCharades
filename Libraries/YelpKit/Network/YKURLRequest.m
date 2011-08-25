//
//  YKURLRequest.m
//  YelpKit
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

#import "YKURLCache.h"
#import "YKDefines.h"
#import <GHKitIOS/GHNSObject+Invocation.h>
#import <GHKitIOS/GHNSURL+Utils.h>
#import <GHKitIOS/GHNSDate+Parsing.h>

NSString *const kYKURLRequestDefaultMultipartBoundary = @"----------------314159265358979323846";
NSString *const kYKURLRequestDefaultContentType = @"application/octet-stream";

const double kYKURLRequestExpiresAgeMax = DBL_MAX;

static NSTimeInterval gYKURLRequestDefaultTimeout = 30.0;
static BOOL gYKURLRequestCacheEnabled = YES; // Defaults to ON


@interface YKURLRequest ()
@property (retain, nonatomic) NSData *responseData;
- (void)_start;
- (void)_stop;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
@end

@implementation YKURLRequest

@synthesize connection=_connection, timeout=_timeout, request=_request, response=_response, delegate=__delegate, 
finishSelector=_finishSelector, failSelector=_failSelector, cancelSelector=_cancelSelector,
expiresAge=_expiresAge, URL=_URL, cacheName=_cacheName,
cachePolicy=_cachePolicy, mockResponse=_mockResponse, mockResponseDelayInterval=_mockResponseDelayInterval, dataInterval=_dataInterval, 
totalInterval=_totalInterval, start=_start, downloadedData=_downloadedData, cacheHit=_cacheHit, inCache=_inCache,
stopped=_stopped, error=_error, detachOnThread=_detachOnThread, 
started=_started, responseInterval=_responseInterval, runLoop=_runLoop;
@synthesize responseData=_responseData; // Private properties


- (id)init {
  if ((self = [super init])) {
    _timeout = gYKURLRequestDefaultTimeout;
    _cachePolicy = YKURLRequestCachePolicyEnabled;
    _totalInterval = -1; 
    _dataInterval = -1;
    _responseInterval = -1;
  }
  return self;
}

- (void)dealloc {
  [self _stop];
  
  [__delegate release];
  __delegate = nil;
  [_URL release];

  [_request release];
  [_connection release];
  [_downloadedData release];
  [_response release];  
  [_mockResponse release];
  [_error release];
  [_responseData release];
  [super dealloc];
}

- (NSString *)description {
  NSInteger statusCode = 0;
  NSDictionary *headerFields = nil;
  if ([_response isKindOfClass:[NSHTTPURLResponse class]]) {
    statusCode = [(NSHTTPURLResponse *)_response statusCode];
    headerFields = [(NSHTTPURLResponse *)_response allHeaderFields];
  }
  
  return [NSString stringWithFormat:@"{\n\tURL = \"%@\";\n\tstatusCode: \"%d\";\n\theaderFields = \"%@\";\n}", _URL, statusCode, headerFields];
}

- (BOOL)shouldAttemptLoadFromCache {
  YKDebug(@"Cache status: gYKURLRequestCacheEnabled=%d, _cachePolicy=%d, _expiresAge=%0f, GET=%d, YKURLRequestCacheDisabled=%d", 
          gYKURLRequestCacheEnabled, _cachePolicy, _expiresAge, 
          (_method == YKHTTPMethodGet),
          [[NSUserDefaults standardUserDefaults] boolForKey:@"YKURLRequestCacheDisabled"]);
  
  return (gYKURLRequestCacheEnabled && 
          _cachePolicy == YKURLRequestCachePolicyEnabled && 
          _expiresAge > 0 && 
          _method == YKHTTPMethodGet &&
          ![[NSUserDefaults standardUserDefaults] boolForKey:@"YKURLRequestCacheDisabled"]);
}

- (BOOL)shouldStoreInCache {
  if (!_request || _method != YKHTTPMethodGet) return NO;
  return (gYKURLRequestCacheEnabled && 
          !_cacheHit &&
          (_cachePolicy == YKURLRequestCachePolicyEnabled || _cachePolicy == YKURLRequestCachePolicyIfModifiedSince) &&
          ![[NSUserDefaults standardUserDefaults] boolForKey:@"YKURLRequestCacheDisabled"]);
}

- (BOOL)requestWithURL:(YKURL *)URL headers:(NSDictionary *)headers delegate:(id)delegate finishSelector:(SEL)finishSelector failSelector:(SEL)failSelector cancelSelector:(SEL)cancelSelector {
  return [self requestWithURL:URL method:YKHTTPMethodGet headers:headers postParams:nil keyEnumerator:nil 
                     delegate:delegate finishSelector:finishSelector failSelector:failSelector cancelSelector:cancelSelector secure:NO];
}

- (BOOL)requestWithURL:(YKURL *)URL method:(YPHTTPMethod)method headers:(NSDictionary *)headers postParams:(NSDictionary *)postParams keyEnumerator:(NSEnumerator *)keyEnumerator 
               delegate:(id)delegate finishSelector:(SEL)finishSelector failSelector:(SEL)failSelector cancelSelector:(SEL)cancelSelector secure:(BOOL)secure {
  
  YKAssertSelectorNilOrImplementedWithArguments(delegate, finishSelector, @encode(YKURLRequest *), 0);
  YKAssertSelectorNilOrImplementedWithArguments(delegate, failSelector, @encode(YKURLRequest *), @encode(YKError *), 0);
  YKAssertSelectorNilOrImplementedWithArguments(delegate, cancelSelector, @encode(YKURLRequest *), 0);
  
  if (_started) [NSException raise:NSInternalInconsistencyException format:@"Re-using a request more than once is not supported."];
  _started = YES;
  
  self.delegate = delegate; // Retained only for life of connection
  _finishSelector = finishSelector;
  _failSelector = failSelector;
  _cancelSelector = cancelSelector;
  
  _URL = [URL retain];
  _method = method;
  NSAssert(_method != YKHTTPMethodNone, @"Invalid method");
  
#if YP_DEBUG
  // Check mock
  if (_mockResponse) {
    YKDebug(@"Mock response for: %@", _URL);
    if (_mockResponseDelayInterval > 0) {
      [[self gh_proxyAfterDelay:_mockResponseDelayInterval] didLoadData:_mockResponse withResponse:nil cacheKey:nil];    
    } else {
      [self didLoadData:_mockResponse withResponse:nil cacheKey:nil];    
    }
    return YES;
  }
#endif
  
  // Check cache
  if ([self shouldAttemptLoadFromCache] && _URL.cacheableURLString) {
    NSData *cachedData = [[self cache] dataForURLString:_URL.cacheableURLString expires:_expiresAge timestamp:nil];
    if (cachedData) {
      YKDebug(@"\n\nCache hit: %@\n\n", _URL.cacheableURLString);
      _cacheHit = YES;
      [[self gh_proxyAfterDelay:0] didLoadData:cachedData withResponse:nil cacheKey:nil];
      return YES;
    } else {
      YKDebug(@"Cache miss: %@, expiresAge=%.0f", _URL.cacheableURLString, _expiresAge);
    }
  } else {
    YKDebug(@"Cache load not attempted");
  }
  
  // Notify that we will request
  [self willRequestURL:_URL];
  
  YKDebug(@"Using timeout: %0.3f", _timeout);
  [_request release];
  _request = [[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[_URL URLString]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:_timeout] retain];
  _request.HTTPShouldHandleCookies = YES;
  
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"YKURLRequestCookiesDisabled"]) _request.HTTPShouldHandleCookies = NO;

  // TODO(gabe): Investigate If-Modified-Since header
//  NSDate *lastModifiedDate = [[self cache] lastModifiedDateForURLString:_URL.cacheableURLString];
//  if (lastModifiedDate) {
//    YKDebug(@"If modified since: %@", [lastModifiedDate gh_formatHTTP]);
//    [_request setValue:[lastModifiedDate gh_formatHTTP] forHTTPHeaderField:@"If-Modified-Since"];
//  }
  
  if (headers) {
    for(NSString *key in headers) {      
      [_request setValue:[headers objectForKey:key] forHTTPHeaderField:key];
    }
  }
  
  [_downloadedData release];
  _downloadedData = nil;
  _downloadedData = [[NSMutableData alloc] init];
  
  Class connectionClass = [[self class] connectionClass];
  YKDebug(@"\n\nConnecting to: %@ <%@>\n", URL, NSStringFromClass(connectionClass));
  
  if (method == YPHTTPMethodPostMultipart) {
    [_request setHTTPMethod:@"POST"]; 
    [self setHTTPBodyMultipart:postParams keyEnumerator:keyEnumerator compress:NO];
  } else if (method == YPHTTPMethodPostMultipartCompressed) {
    [_request setHTTPMethod:@"POST"]; 
    [self setHTTPBodyMultipart:postParams keyEnumerator:keyEnumerator compress:YES];
  } else if (method == YPHTTPMethodPostForm) {
    [_request setHTTPMethod:@"POST"]; 
    [self setHTTPBodyFormData:postParams];
  } 
  _start = [NSDate timeIntervalSinceReferenceDate];
  _connection = [[connectionClass alloc] initWithRequest:_request delegate:self startImmediately:NO];   
  if (_detachOnThread) {
    YKDebug(@"Request will detach on thread");
    [[self gh_proxyDetachThreadWithCallback:nil action:NULL context:nil] _start];
  } else {
    [self _start];
  }
  return YES;
}

- (YKURLCache *)cache {
  if (_cacheName) return [YKURLCache cacheWithName:_cacheName];
  return [YKURLCache sharedCache];
}

- (void)_start {
  YKDebug(@"Starting...");
  [_connection scheduleInRunLoop:(self.runLoop ? self.runLoop : [NSRunLoop mainRunLoop]) forMode:NSDefaultRunLoopMode];
  [_connection start];
}

- (void)cancel {
  YKDebug(@"Cancel");
  _cancelled = YES;
  if (_stopped) {
    YKDebug(@"Ignoring cancel; Request stopped");
    return;
  } 
  [self didCancel]; 
  [self _stop];
}

- (void)close {
  [self _stop];
}

- (void)_stop {
  if (!_stopped) YKDebug(@"Stopping");
  _stopped = YES;
  if (_connection) {
    // In case cancelling the connection calls this recursively (from dealloc), 
    // nil connection before releasing
    NSURLConnection *oldConnection = _connection;
    _connection = nil;
    
    // This may be called in a callback from the connection, so use autorelease
    [oldConnection cancel];
    [oldConnection unscheduleFromRunLoop:(self.runLoop ? self.runLoop : [NSRunLoop mainRunLoop]) forMode:NSDefaultRunLoopMode];
    [oldConnection autorelease];     
    
    // Delegates are retained only for the life of the connection
    [__delegate release];
    __delegate = nil;   
  }   
}

- (void)setHTTPBodyFormData:(NSDictionary *)params {
  [_request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
  NSData *data = [[NSURL gh_dictionaryToQueryString:params] dataUsingEncoding:NSUTF8StringEncoding];
  YKDebug(@"Form data: %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
  [_request setHTTPBody:data];
}

- (void)setHTTPBody:(NSData *)data compress:(BOOL)compress {
  if (compress) {
    id<YKCompressor> compressor = [[self class] compressor];
    if (!compressor) [NSException raise:NSDestinationInvalidException format:@"No compressor available. Set compressor at setCompressor:"];
    [_request setValue:[compressor contentEncoding] forHTTPHeaderField:@"Content-Encoding"];
    NSData *compressedData = [compressor compressData:data];
    [_request setHTTPBody:compressedData];
  } else {
    [_request setHTTPBody:data];
  }
}

- (void)cacheDataIfEnabled:(NSData *)data cacheKey:(NSString *)cacheKey {
  if (cacheKey && [self shouldStoreInCache] && [self shouldCacheData:data forKey:cacheKey]) {
    YKDebug(@"Storing in cache with key: %@", cacheKey);
    [[self cache] storeData:data forURLString:cacheKey];
    _inCache = YES;
  } else {
    YKDebug(@"Response was not cached");
  }
} 

- (NSDictionary *)responseHeaderFields {
  if ([_response isKindOfClass:[NSHTTPURLResponse class]])
    return [(NSHTTPURLResponse *)_response allHeaderFields];
  return nil;
}

- (NSDate *)responseDate {
  NSString *dateString = [[self responseHeaderFields] objectForKey:@"Date"];
  return [NSDate gh_parseHTTP:dateString];
}

#pragma mark -

- (void)willRequestURL:(YKURL *)URL { }

- (void)didLoadData:(NSData *)data withResponse:(NSURLResponse *)response cacheKey:(NSString *)cacheKey {   
  YKDebug(@"Did load data: %d", [data length]);
  // Subclasses may do processing here
  [self didFinishWithData:data cacheKey:cacheKey];
}

- (BOOL)shouldCacheData:(NSData *)data forKey:(id)key { return YES; }

- (void)didError:(YKError *)error { 
  YKErr(@"Error in response: %@", error);
  [error retain];
  [_error release];
  _error = error;
  if (_failSelector != NULL) [[__delegate gh_proxyOnMainThread:YES] performSelector:_failSelector withObject:self withObject:error];
  [[self gh_proxyOnMainThread:YES] _stop];
}

- (void)didFinishWithData:(NSData *)data cacheKey:(NSString *)cacheKey {   
  self.responseData = data;
  // TODO(gabe): In experimental threaded request, caching isn't thread safe (so this call isn't completely safe)
  [self cacheDataIfEnabled:data cacheKey:cacheKey];
  
  if (_stopped) return;
  
  if (_finishSelector != NULL) [[__delegate gh_proxyOnMainThread:YES] performSelector:_finishSelector withObject:self];
  [[self gh_proxyOnMainThread:YES] _stop];
}

- (void)didCancel {
  YKDebug(@"Cancel (%@/%@)", self.delegate, NSStringFromSelector(_cancelSelector));
  if (_cancelSelector != NULL) [[__delegate gh_proxyOnMainThread:YES] performSelector:_cancelSelector withObject:self];
  [[self gh_proxyOnMainThread:YES] _stop];
}

#pragma mark Debug

- (NSString *)metricsDescription {
  return [NSString stringWithFormat:@"Latency: %0.4fs\nData: %0.4fs\nTotal: %0.4fs\n", 
          _responseInterval, _dataInterval, _totalInterval];
}  

#pragma mark Multipart POST

- (void)setHTTPBodyMultipart:(NSDictionary *)multipart keyEnumerator:(NSEnumerator *)keyEnumerator compress:(BOOL)compress {
  [_request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", kYKURLRequestDefaultMultipartBoundary] forHTTPHeaderField:@"Content-Type"];
  [self setHTTPBody:[[self class] HTTPBodyForMultipart:multipart keyEnumerator:keyEnumerator] compress:compress];
}

+ (NSData *)HTTPBodyForMultipart:(NSDictionary *)multipart {
  return [self HTTPBodyForMultipart:multipart keyEnumerator:nil];
}

+ (NSData *)HTTPBodyForMultipart:(NSDictionary *)multipart keyEnumerator:(NSEnumerator *)keyEnumerator {
  NSMutableData *postBody = [NSMutableData data];
  NSData *newLineData = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
  if (!keyEnumerator) keyEnumerator = [multipart keyEnumerator];
  for (NSString *key in keyEnumerator) {
    id value = [multipart objectForKey:key];
    if (!value || value == [NSNull null]) continue;
    if ([value isKindOfClass:[NSNumber class]])
      value = [(NSNumber *)value stringValue];
    if ([value isKindOfClass:[NSString class]]) {
      [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", kYKURLRequestDefaultMultipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
      [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
      [postBody appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
      [postBody appendData:newLineData];
    } else {      
      if ([value isKindOfClass:[NSData class]]) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", kYKURLRequestDefaultMultipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, key] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", kYKURLRequestDefaultContentType] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:value];
      } else if ([value isKindOfClass:[YKURLRequestDataPart class]]) {
        YKURLRequestDataPart *part = (YKURLRequestDataPart *)value;
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", kYKURLRequestDefaultMultipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, key] dataUsingEncoding:NSUTF8StringEncoding]];       
        [postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", part.contentType] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:part.data];
      } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Only supports NSString, NSNumber, and NSData but was %@", [value class]] userInfo:nil];
      }
      [postBody appendData:newLineData];
    }
  }
  [postBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", kYKURLRequestDefaultMultipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
  return postBody;
}

#pragma mark Connection Globals

static Class gYKURLRequestConnectionClass = NULL;

+ (Class)connectionClass {
  if (gYKURLRequestConnectionClass == NULL) {
    gYKURLRequestConnectionClass = [NSURLConnection class]; 
  }
  return gYKURLRequestConnectionClass; 
}

+ (void)setConnectionClass:(Class)theClass {
  gYKURLRequestConnectionClass = theClass;
}

#pragma mark Compressor

static id<YKCompressor> gCompressor = NULL;

+ (id<YKCompressor>)compressor {
  return gCompressor;
}

+ (void)setCompressor:(id<YKCompressor>)compressor {
  gCompressor = [compressor retain];
}

#pragma mark -

+ (void)setCacheEnabled:(BOOL)cacheEnabled {
  gYKURLRequestCacheEnabled = cacheEnabled;
}

- (NSInteger)responseStatusCode {
  NSInteger status = -1;
  if ([_response respondsToSelector:@selector(statusCode)])
    status = [(NSHTTPURLResponse *)_response statusCode];

  return status;
}

#pragma mark Delegates (NSURLConnection)

// This method can be called multiple times (in case of redirect)
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  if (_stopped) return;
  [_downloadedData setLength:0];
  
  _responseInterval = [NSDate timeIntervalSinceReferenceDate] - _start;
  
  // In <= 3.1.1 this was set in connection:didReceiveData: so interval_data may be inaccurate
  if (_startData == 0)
    _startData = [NSDate timeIntervalSinceReferenceDate];
  
  YKDebug(@"Got response: %@", response);
  [response retain];
  [_response release];
  _response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  if (_stopped) return;
  [_downloadedData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
  return nil;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
  if (_authProtectionDisabled) {
    // Accept all secure connections in debug mode
    return YES;
  }
  return NO; // The default
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  if (_stopped) return;

  if (_authProtectionDisabled) {
    // Accept all secure connections in debug mode
    YKDebug(@"Connecting to SSL host: %@", challenge.protectionSpace.host);
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
  } else {
    [self connection:connection didFailWithError:[YKError errorWithKey:YKErrorAuthChallenge]];
  }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  if (_stopped) {
    YKDebug(@"Ignoring connectionDidFinishLoading:, stopped");
    return;
  }
  
  _dataInterval = [NSDate timeIntervalSinceReferenceDate] - _startData;
  _totalInterval = [NSDate timeIntervalSinceReferenceDate] - _start;

  NSInteger status = [self responseStatusCode];
  YKDebug(@"Did finish loading; status=%d", status);
  if (status >= 300) {
    [self didError:[YKHTTPError errorWithHTTPStatus:status]];
  } else {
    [self didLoadData:_downloadedData withResponse:_response cacheKey:_URL.cacheableURLString];
  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  if (_stopped) return;
  if ([error isKindOfClass:[YKError class]]) {
    [self didError:(YKError *)error];
    return;
  } else if ([error domain] == NSURLErrorDomain && [error code] == NSURLErrorNotConnectedToInternet) {
    [self didError:[YKError errorWithKey:YKErrorNotConnectedToInternet error:error]];
  } else if ([error domain] == NSURLErrorDomain && [error code] == NSURLErrorCannotConnectToHost) {
     [self didError:[YKError errorWithKey:YKErrorCannotConnectToHost error:error]];
  } else {    
    [self didError:[YKError errorWithKey:YKErrorRequest error:error]];
  }
}

@end


@implementation YKURLRequestDataPart

@synthesize data=_data, contentType=_contentType;

- (id)init {
  if ((self = [super init])) {
    _contentType = [kYKURLRequestDefaultContentType copy];
  }
  return self;
}

- (void)dealloc {
  [_data release];
  [_contentType release];
  [super dealloc];
}

+ (YKURLRequestDataPart *)text:(NSString *)text {
  YKURLRequestDataPart *part = [[YKURLRequestDataPart alloc] init];
  part.contentType = @"text/plain";
  part.data = [text dataUsingEncoding:NSUTF8StringEncoding];
  return [part autorelease];
}

@end
