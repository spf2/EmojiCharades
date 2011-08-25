//
//  YKError.m
//  YelpKit
//
//  Created by Gabriel Handford on 2/5/09.
//  Copyright 2009 Yelp. All rights reserved.
//

#import "YKError.h"
#import "YKDefines.h"
#import <GHKitIOS/GHNSError+Utils.h>
#import "YKLocalized.h"

NSString *const YKErrorDomain = @"YKErrorDomain";

NSString *const YKErrorUnknown = @"YKErrorUnknown"; // Unknown error

NSString *const YKErrorRequest = @"YKErrorRequest"; // General request error
NSString *const YKErrorAuthChallenge = @"YKErrorAuthChallenge";
NSString *const YKErrorServerResourceNotFound = @"YKErrorServerResourceNotFound"; // Server was reached but returned a 404 error
NSString *const YKErrorServerMaintenance = @"YKErrorServerMaintenance"; // Server was reached but returned a 503 error
NSString *const YKErrorServerResponse = @"YKErrorServerResponse"; // Reached server, but there was an error returned
NSString *const YKErrorCannotConnectToHost = @"YKErrorCannotConnectToHost"; // Server not reachable but internet active
NSString *const YKErrorNotConnectedToInternet = @"YKErrorNotConnectedToInternet";


@interface YKError ()
@property (retain, nonatomic) NSString *key;
@end

@implementation YKError

@synthesize key=_key, unknownDescription=_unknownDescription, description=_description;

- (id)initWithKey:(NSString *const)key {
  return [self initWithKey:key userInfo:nil];
}

- (id)initWithKey:(NSString *const)key userInfo:(NSDictionary *)userInfo {
  if ((self = [super initWithDomain:YKErrorDomain code:-1 userInfo:userInfo])) {  
    _key = [key copy];
  }
  return self;
  
}

- (id)initWithKey:(NSString *const)key error:(NSError *)error {
  NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:NSUnderlyingErrorKey];
  if ((self = [super initWithDomain:error.domain code:error.code userInfo:userInfo])) { 
    _key = [key copy];
  }
  return self;
}

- (void)dealloc {
  [_key release];
  [_description release];
  [_unknownDescription release];
  [super dealloc];
}

- (NSString *)description {
  return YKDescription(@"class", @"domain", @"key", @"userInfo");
}

- (NSString *)localizedDescriptionForKey {
  return YKLocalizedString(_key);
}

- (NSString *)localizedDescription {
  // Get description in the following order:
  //  * _description
  //  * Description in userInfo
  //  * Localized string using error key
  //  * _unknownDescription
  //  * Localized string for YKErrorUnknown
  if (_description) return _description;
  NSString *description = [self.userInfo objectForKey:NSLocalizedDescriptionKey];
  if (!description) {
    if (_key) description = [self localizedDescriptionForKey];
    YKDebug(@"Description for error key=%@: %@", _key, description);
    if (!description || [description isEqualToString:_key]) {
      if (_unknownDescription) return _unknownDescription;
      return YKLocalizedString(@"YKErrorUnknown");
    }
  }
  return description;
}

+ (id)errorWithKey:(NSString *const)key {
  return [self errorWithKey:key userInfo:nil];
}

+ (id)errorWithKey:(NSString *const)key userInfo:(NSDictionary *)userInfo {
  return [[[self alloc] initWithKey:key userInfo:userInfo] autorelease];
}

+ (id)errorWithKey:(NSString *const)key error:(NSError *)error {
  return [[[self alloc] initWithKey:key error:error] autorelease];
}

+ (id)errorWithDescription:(NSString *)description {
  return [self gh_errorWithDomain:YKErrorDomain code:-1 localizedDescription:description];
}

- (id)userInfoForKey:(NSString *const)key {
  return [self.userInfo objectForKey:key];
}

- (id)userInfoForKey:(NSString *const)key subKey:(NSString *)subKey {
  id dict = [self.userInfo objectForKey:key];
  if ([dict isKindOfClass:[NSDictionary class]]) {
    return [dict objectForKey:subKey];
  }
  return nil;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeObject:_key forKey:@"key"];
  [coder encodeObject:_description forKey:@"description"];
  [coder encodeObject:_unknownDescription forKey:@"unknownDescription"];
}

- (id)initWithCoder:(NSCoder *)coder {
  YKError *error = [super initWithCoder:coder];
  error.key = [coder decodeObjectForKey:@"key"];
  error.description = [coder decodeObjectForKey:@"description"];
  error.unknownDescription = [coder decodeObjectForKey:@"unknownDescription"];
  return error;
}

+ (YKError *)errorForError:(NSError *)error {
  if ([error isKindOfClass:[YKError class]]) return (YKError *)error;
  return [[[YKError alloc] initWithKey:YKErrorUnknown error:error] autorelease];
}

// Abstract
- (NSArray *)fields { return nil; }

@end


@interface YKHTTPError ()
@property (assign, nonatomic) NSInteger HTTPStatus;
@end

@implementation YKHTTPError

@synthesize HTTPStatus=_HTTPStatus;

+ (YKHTTPError *)errorWithHTTPStatus:(NSInteger)HTTPStatus {
  YKHTTPError *error = [super errorWithKey:[self keyForHTTPStatus:HTTPStatus] userInfo:nil];
  error->_HTTPStatus = HTTPStatus;
  return error; 
}

+ (NSString *const)keyForHTTPStatus:(NSInteger)HTTPStatus {
  switch(HTTPStatus) {
    case 503: return YKErrorServerMaintenance;
    case 404: return YKErrorServerResourceNotFound;
    default: return YKErrorServerResponse;
  }
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeInteger:_HTTPStatus forKey:@"HTTPStatus"];
}

- (id)initWithCoder:(NSCoder *)coder {
  YKHTTPError *error = [super initWithCoder:coder];
  error.HTTPStatus = [coder decodeIntegerForKey:@"HTTPStatus"];
  return error;
}

@end
