//
//  YKURL.m
//  YelpKit
//
//  Created by Gabriel Handford on 11/4/09.
//  Copyright 2009 Yelp. All rights reserved.
//

#import "YKURL.h"

@implementation YKURL

@synthesize cacheDisabled=_cacheDisabled;

- (id)initWithURLString:(NSString *)URLString {
  if ((self = [self init])) {
    _URLString = [URLString retain];
  }
  return self;
}

- (void)dealloc {
  [_URLString release];
  [super dealloc];
}

+ (YKURL *)URLString:(NSString *)URLString {
  return [self URLString:URLString cacheEnabled:YES];
}

+ (YKURL *)URLString:(NSString *)URLString cacheEnabled:(BOOL)cacheEnabled {
  YKURL *URL = [[YKURL alloc] initWithURLString:URLString];
  URL.cacheDisabled = !cacheEnabled;
  return [URL autorelease];
}

- (NSString *)description {
  return _URLString;
}

- (NSString *)cacheableURLString {
  if (_cacheDisabled) return nil;
  return _URLString;
}

- (NSString *)URLString {
  return _URLString;
}

@end
