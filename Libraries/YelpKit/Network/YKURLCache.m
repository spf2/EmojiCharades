//
//  YKURLCache.m
//  YelpIPhone
//
//  Created by Gabriel Handford on 6/24/10.
//  Copyright 2010 Yelp. All rights reserved.
//

//
// Based on TTURLCache:
//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//


#import "YKURLCache.h"
#import <GHKitIOS/GHNSFileManager+Utils.h>
#import <GHKitIOS/GHNSString+Utils.h>
#import "YKResource.h"
#import "YKDefines.h"

//#include <sys/utsname.h>
#include <sys/sysctl.h>


static NSString *kEtagCacheDirectoryName = @"ETag";

static NSMutableDictionary *gNamedCaches = NULL;

@interface YKURLCache()
+ (NSString *)_cachePathWithName:(NSString *)name;
@end


@implementation YKURLCache

@synthesize disableDiskCache=_disableDiskCache, cachePath=_cachePath, invalidationAge=_invalidationAge, maxPixelCount=_maxPixelCount;

- (id)initWithName:(NSString *)name {
  if ((self = [super init])) {
    _name = [name copy];
    _cachePath = [[YKURLCache _cachePathWithName:name] retain];
    _invalidationAge = YKTimeIntervalDay;
    _maxPixelCount = 262144; // ~1 MB
    
    if ([YKURLCache totalMemory] > (220 * 1000 * 1000)) { // 256 MB iPhone/iPad
      _maxPixelCount *= 4; // ~4 MB
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
  }
  return self;
}

- (id)init {
  [NSException raise:NSInvalidArgumentException format:@"Must use initWithName:"];
  return nil;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_name release];
  [_cachePath release];
  [super dealloc];
}

#pragma mark sysctl

+ (NSUInteger)getSysInfo:(uint)typeSpecifier {
	size_t size = sizeof(int);
	int results;
	int mib[2] = {CTL_HW, typeSpecifier};
	sysctl(mib, 2, &results, &size, NULL, 0);
	return (NSUInteger) results;
}

+ (NSUInteger)totalMemory {
	return [self getSysInfo:HW_PHYSMEM];
}

+ (YKURLCache *)sharedCache {
  return [self cacheWithName:@"YKURLCache"];
}

+ (YKURLCache *)cacheWithName:(NSString *)name {
  YKURLCache *cache = nil;
  @synchronized([YKURLCache class]) {
    if (gNamedCaches == NULL)
      gNamedCaches = [[NSMutableDictionary alloc] init];
    
    cache = [gNamedCaches objectForKey:name];  
    if (!cache) {
      cache = [[[YKURLCache alloc] initWithName:name] autorelease];
      [gNamedCaches setObject:cache forKey:name];
    }
  }
  return cache;
}

+ (NSString*)_cachePathWithName:(NSString*)name {
  NSString *cachesPath = [YKResource cacheDirectory];
  NSString *cachePath = [cachesPath stringByAppendingPathComponent:name];
  NSString *ETagCachePath = [cachePath stringByAppendingPathComponent:kEtagCacheDirectoryName];
  
  [NSFileManager gh_ensureDirectoryExists:cachesPath created:nil error:nil];
  [NSFileManager gh_ensureDirectoryExists:cachePath created:nil error:nil];
  [NSFileManager gh_ensureDirectoryExists:ETagCachePath created:nil error:nil];
  
  return cachePath;
}

- (NSString *)ETagFromCacheWithKey:(NSString *)key {
  NSString *path = [self ETagCachePathForKey:key];
  NSData *data = [NSData dataWithContentsOfFile:path];
  return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

- (void)didReceiveMemoryWarning:(void *)object {
  // Empty the memory cache when memory is low
  [self removeAll:NO];
}

- (NSString *)ETagCachePath {
  return [self.cachePath stringByAppendingPathComponent:kEtagCacheDirectoryName];
}

- (NSString *)keyForURLString:(NSString *)URLString {
  return [URLString gh_MD5];
}

- (NSString *)cachePathForURLString:(NSString *)URLString {
  NSString *key = [self keyForURLString:URLString];
  return [self cachePathForKey:key];
}

- (NSString *)cachePathForKey:(NSString *)key {
  return [_cachePath stringByAppendingPathComponent:key];
}

- (NSString *)ETagCachePathForKey:(NSString *)key {
  return [self.ETagCachePath stringByAppendingPathComponent:key];
}

- (BOOL)hasDataForURLString:(NSString *)URLString {
  NSString *filePath = [self cachePathForURLString:URLString];
  NSFileManager *fm = [NSFileManager defaultManager];
  return [fm fileExistsAtPath:filePath];
}

- (NSData *)dataForURLString:(NSString *)URLString {
  return [self dataForURLString:URLString expires:YKTimeIntervalMax timestamp:nil];
}

- (NSData *)dataForURLString:(NSString *)URLString expires:(NSTimeInterval)expirationAge timestamp:(NSDate**)timestamp {
  if (!URLString) return nil;
  NSString *key = [self keyForURLString:URLString];
  return [self dataForKey:key expires:expirationAge timestamp:timestamp];
}

- (BOOL)hasDataForKey:(NSString *)key expires:(NSTimeInterval)expirationAge {
  NSString *filePath = [self cachePathForKey:key];
  NSFileManager *fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:filePath]) {
    NSDictionary *attrs = [fm attributesOfItemAtPath:filePath error:nil];
    NSDate *modified = [attrs objectForKey:NSFileModificationDate];
    if ([modified timeIntervalSinceNow] < -expirationAge) {
      return NO;
    }    
    return YES;
  }  
  return NO;
}

- (NSData *)dataForKey:(NSString*)key expires:(NSTimeInterval)expirationAge timestamp:(NSDate**)timestamp {
  NSString *filePath = [self cachePathForKey:key];
  NSFileManager *fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:filePath]) {
    NSDictionary *attrs = [fm attributesOfItemAtPath:filePath error:nil];
    NSDate *modified = [attrs objectForKey:NSFileModificationDate];
    if ([modified timeIntervalSinceNow] < -expirationAge) {
      return nil;
    }
    if (timestamp) {
      *timestamp = modified;
    }    
    return [NSData dataWithContentsOfFile:filePath];
  }  
  return nil;
}

- (NSString *)ETagForKey:(NSString*)key {
  return [self ETagFromCacheWithKey:key];
}

- (void)storeData:(NSData *)data forURLString:(NSString *)URLString {
  NSParameterAssert(URLString);
  NSString *key = [self keyForURLString:URLString];
  [self storeData:data forKey:key];
}

- (void)storeData:(NSData *)data forKey:(NSString *)key {
  NSParameterAssert(key);
  if (!_disableDiskCache) {
    NSString *filePath = [self cachePathForKey:key];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createFileAtPath:filePath contents:data attributes:nil];
  }
}

- (void)storeETag:(NSString *)ETag forKey:(NSString*)key {
  NSString *filePath = [self ETagCachePathForKey:key];
  NSFileManager *fm = [NSFileManager defaultManager];
  [fm createFileAtPath:filePath contents:[ETag dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

- (void)moveDataForURLString:(NSString *)oldURLString toURLString:(NSString *)newURLString {
  NSParameterAssert(oldURLString);
  NSParameterAssert(newURLString);
  NSString *oldKey = [self keyForURLString:oldURLString];
  NSString *oldPath = [self cachePathForKey:oldKey];
  NSFileManager *fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:oldPath]) {
    NSString *newKey = [self keyForURLString:newURLString];
    NSString *newPath = [self cachePathForKey:newKey];
    [fm moveItemAtPath:oldPath toPath:newPath error:nil];
  }
}

- (void)moveDataFromPath:(NSString *)path toURLString:(NSString *)newURLString {
  NSParameterAssert(path);
  NSParameterAssert(newURLString);
  NSString *newKey = [self keyForURLString:newURLString];
  NSFileManager *fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:path]) {
    NSString *newPath = [self cachePathForKey:newKey];
    [fm moveItemAtPath:path toPath:newPath error:nil];
  }
}

- (void)removeURLString:(NSString *)URLString fromDisk:(BOOL)fromDisk {
  if (fromDisk) {
    NSString *key = [self keyForURLString:URLString];
    NSString *filePath = [self cachePathForKey:key];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (filePath && [fm fileExistsAtPath:filePath]) {
      [fm removeItemAtPath:filePath error:nil];
    }
  }
}

- (void)removeKey:(NSString *)key {
  NSString *filePath = [self cachePathForKey:key];
  NSFileManager *fm = [NSFileManager defaultManager];
  if (filePath && [fm fileExistsAtPath:filePath]) {
    [fm removeItemAtPath:filePath error:nil];
  }
}

- (void)removeAll:(BOOL)fromDisk {
  if (fromDisk) {
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:_cachePath error:nil];
    [NSFileManager gh_ensureDirectoryExists:_cachePath created:nil error:nil];
  }
  _totalPixelCount = 0;
  [_imageCache release];
  _imageCache = nil;
  [_imageSortedList release];
  _imageSortedList = nil;
}

- (void)invalidateURLString:(NSString *)URLString {
  NSString *key = [self keyForURLString:URLString];
  return [self invalidateKey:key];
}

- (void)invalidateKey:(NSString *)key {
  NSString *filePath = [self cachePathForKey:key];
  NSFileManager *fm = [NSFileManager defaultManager];
  if (filePath && [fm fileExistsAtPath:filePath]) {
    NSDate *invalidDate = [NSDate dateWithTimeIntervalSinceNow:-_invalidationAge];
    NSDictionary *attrs = [NSDictionary dictionaryWithObject:invalidDate forKey:NSFileModificationDate];
    
#if __IPHONE_4_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    [fm setAttributes:attrs ofItemAtPath:filePath error:nil];
#else
    [fm changeFileAttributes:attrs atPath:filePath];
#endif
  }
}

- (void)invalidateAll {
  NSDate *invalidDate = [NSDate dateWithTimeIntervalSinceNow:-_invalidationAge];
  NSDictionary *attrs = [NSDictionary dictionaryWithObject:invalidDate forKey:NSFileModificationDate];
  
  NSFileManager *fm = [NSFileManager defaultManager];
  NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:_cachePath];
  for (NSString *fileName in enumerator) {
    NSString* filePath = [_cachePath stringByAppendingPathComponent:fileName];
#if __IPHONE_4_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    [fm setAttributes:attrs ofItemAtPath:filePath error:nil];
#else
    [fm changeFileAttributes:attrs atPath:filePath];
#endif
  }
}

#pragma mark Image Cache

- (void)_expireImagesFromMemory {
  while (_imageSortedList.count) {
    NSString *key = [_imageSortedList objectAtIndex:0];
    UIImage *image = [_imageCache objectForKey:key];
    
    YKDebug(@"Expiring image, key=%@, pixels=%.0f", key, (image.size.width * image.size.height));
    _totalPixelCount -= image.size.width * image.size.height;
    [_imageCache removeObjectForKey:key];
    [_imageSortedList removeObjectAtIndex:0];
    
    if (_totalPixelCount <= _maxPixelCount) {
      break;
    }
  }
  if (_totalPixelCount < 0) _totalPixelCount = 0;
}

- (BOOL)cacheImage:(UIImage *)image forURLString:(NSString *)URLString {
  YKParameterAssert(image);
  YKParameterAssert(URLString);
  if (!image || !URLString) return NO;
  
  // Already in cache (We don't bump it forward)
  if ([_imageCache objectForKey:URLString]) return NO;
  
  int pixelCount = image.size.width * image.size.height;
  
  static const CGFloat kLargeImageSize = 600 * 400;
  
  // Cache is full
  if (pixelCount >= kLargeImageSize) {
    YKDebug(@"NOT caching image in in memory (too large, pixelCount=%d > %d)", pixelCount, kLargeImageSize);
    return NO;
  }
  
  _totalPixelCount += pixelCount;
  
  if (_totalPixelCount > _maxPixelCount && _maxPixelCount) {
    [self _expireImagesFromMemory];
  }
  
  if (!_imageCache) {
    _imageCache = [[NSMutableDictionary alloc] init];
  }
  
  if (!_imageSortedList) {
    _imageSortedList = [[NSMutableArray alloc] init];
  }
  
  [_imageSortedList addObject:URLString];
  [_imageCache setObject:image forKey:URLString];
  return YES;
}

- (UIImage *)cachedImageForURLString:(NSString *)URLString expires:(NSTimeInterval)expires {
  if (!URLString) return nil;
  UIImage *image = [_imageCache objectForKey:URLString];
  if (!image) {
    //NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    NSData *cachedData = [self dataForURLString:URLString expires:expires timestamp:nil];
    if (cachedData) {      
      image = [UIImage imageWithData:cachedData];
      // If the image was invalid, remove it from the cache
      if (image) {
        [self cacheImage:image forURLString:URLString];
      } else {
        [self removeURLString:URLString fromDisk:YES];
      }
    }
    //YKDebug(@"Image memory cache MISS: %@ (length=%d), Loading image took: %0.3f", URLString, [cachedData length], ([NSDate timeIntervalSinceReferenceDate] - start));
  } else {
    //YKDebug(@"Image memory cache HIT: %@", URLString);
  }
  return image;
}

@end
