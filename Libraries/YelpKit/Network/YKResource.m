//
//  YKResource.m
//  YelpKit
//
//  Created by Gabriel Handford on 8/19/09.
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

#import "YKResource.h"
#import "YKDefines.h"
#import <GHKitIOS/GHNSFileManager+Utils.h>
#import <GHKitIOS/GHNSError+Utils.h>

@implementation YKResource

+ (NSString *)documentsDirectory {  
  static NSString *DocumentsDirectory = NULL;
  @synchronized([YKResource class]) {
    if (DocumentsDirectory == NULL) {
      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
      DocumentsDirectory = [[paths objectAtIndex:0] copy];
    }   
  }
  return DocumentsDirectory;
}

+ (NSString *)cacheDirectory {  
  static NSString *CacheDirectory = NULL;
  @synchronized([YKResource class]) {
    if (CacheDirectory == NULL) {
      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
      CacheDirectory = [[paths objectAtIndex:0] copy];
    }   
  }
  return CacheDirectory;
}

+ (NSString *)pathInDocuments:(NSString *)path {
  return [[self documentsDirectory] stringByAppendingPathComponent:path];
}

+ (NSString *)pathInDocumentsWithComponents:(NSArray *)components {
  NSString *path = [self documentsDirectory];
  for (NSString *component in components) {
    path = [path stringByAppendingPathComponent:component];
  }
  return path;
}

+ (NSString *)pathToResource:(NSString *)path {
  if (!path) return nil;
  return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
}

+ (NSString *)bundleURLStringForResourceIfExists:(NSString *)path {
  NSString *resourcePath = [self pathToResource:path];
  if (resourcePath && [NSFileManager gh_exist:resourcePath]) return [NSString stringWithFormat:@"bundle://%@", path];
  return nil;  
}

+ (NSString *)pathToCache:(NSString *)path {
  return [[self cacheDirectory] stringByAppendingPathComponent:path];
}

+ (NSString *)pathToResourceCopiedInDocuments:(NSString *)fileName {
  return [self pathToResourceCopiedInDocumentsFrom:fileName to:fileName overwrite:NO];
}

+ (NSString *)pathToResourceCopiedInDocumentsFrom:(NSString *)source to:(NSString *)dest overwrite:(BOOL)overwrite {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *fullDocsPath = [self pathInDocuments:dest];
  if (![fileManager fileExistsAtPath:fullDocsPath] || overwrite) {
    YKDebug(@"File does not exist at: %@", fullDocsPath);
    NSString *resourcePath = [self pathToResource:source];
    NSError *error = nil;
    BOOL success;
    NSString *directory = [fullDocsPath stringByDeletingLastPathComponent];
    if (![fileManager fileExistsAtPath:directory]) {
      success = [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
      if (!success) {
        YKErr(@"Failed to create intermediate directories: %@ (%@)", fullDocsPath, error);
        return nil;
      }   
    }
    success = [fileManager copyItemAtPath:resourcePath toPath:fullDocsPath error:&error];
    if (!success) {
      YKErr(@"Failed to copy the file: %@ to %@ (%@)", resourcePath, fullDocsPath, error);
      return nil;
    } else {
      YKDebug(@"Copied file %@ to %@", resourcePath, fullDocsPath);
    }
  }
  return fullDocsPath;
}

+ (id)loadObjectFromPath:(NSString *)path defaultValue:(id)defaultValue error:(NSError **)error {
  if ([NSFileManager gh_exist:path]) {
    @try {
      id obj = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
      if (!obj || [obj isEqual:[NSNull null]]) return defaultValue;
      return obj;
    } @catch(NSException *e) {
      YKException(e);
      if (error) *error = [NSError gh_errorFromException:e];
    }
  }
  return defaultValue;
}

+ (BOOL)saveObject:(id)obj toPath:(NSString *)path error:(NSError **)error {
  @try {
    [NSKeyedArchiver archiveRootObject:obj toFile:path];
    return YES;
  } @catch(NSException *e) {
    YKException(e);
    if (error) *error = [NSError gh_errorFromException:e];
    return NO;
  }
}

+ (NSString *)resolvedPathForURL:(NSURL *)URL {  
  URL = [self resolvedURLForURL:URL];
  if ([URL isFileURL]) return [URL path];
  return [URL absoluteString];
}

+ (NSString *)pathForBundleURL:(NSURL *)URL {
  if ([[URL scheme] isEqualToString:@"bundle"]) {
    NSString *path = [URL host];
    if (!path) path = [URL path];
    return path;
  }
  return nil;
}

+ (NSURL *)resolvedURLForURL:(NSURL *)URL {
  NSString *pathInBundle = [self pathForBundleURL:URL];
  if (pathInBundle) return [NSURL fileURLWithPath:pathInBundle];
  return URL;
}

+ (BOOL)URLExists:(NSURL *)URL {
  return [NSFileManager gh_exist:[self resolvedPathForURL:URL]];
}  

@end
