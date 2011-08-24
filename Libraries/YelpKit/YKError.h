//
//  YKError.h
//  YelpKit
//
//  Created by Gabriel Handford on 2/5/09.
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

// Error domains
extern NSString *const YKErrorDomain;

extern NSString *const YKErrorUnknown;

extern NSString *const YKErrorRequest; // A generic error
extern NSString *const YKErrorAuthChallenge; // We received an unexpected auth challenge
extern NSString *const YKErrorServerResourceNotFound; // Server was reached but returned a 404 error
extern NSString *const YKErrorServerMaintenance; // Server was reached but returned a 503 error
extern NSString *const YKErrorServerResponse; // Server was reached but returned some other error
extern NSString *const YKErrorCannotConnectToHost; // Server not reachable but internet active
extern NSString *const YKErrorNotConnectedToInternet;


/*!
 Generic error class, which stores error code as a unique string (key).
 
 The localized description can be set using the same string key.
 
 An example usage might look like:
 
 @code
 // In YKError.h
 extern NSString *const YKErrorBadFoo;
 
 // In YKError.m
 NSString *const YKErrorBadFoo = @"YKErrorBadFoo";
 
 // Creating "bad foo" error
 YKError *error = [YKError errorWithKey:YKErrorBadFoo];
 
 // Somewhere else checking if error is for "bad foo"
 if (error.key == YKErrorBadFoo) { ... } 
 
 // In strings file:
 YKErrorBadFoo = "There was some bad foo";
 @endcode
 */
@interface YKError : NSError {

  NSString *_key;
  
  // To override description in userInfo
  NSString *_description;
  
  // Allows us to override default description if localized message not available; 
  // For example, if there was an error in talk we might set this to: 
  //  "We had trouble getting to Talk.\nPlease try again in a bit."
  NSString *_unknownDescription; 
  
}

@property (readonly, retain, nonatomic) NSString *key;
@property (retain, nonatomic) NSString *description;
@property (retain, nonatomic) NSString *unknownDescription;

/*!
 Create error with key.
 The key is also used to look up the localized description.
 The NSError code defaults to -1; and is not mean to be used.
 The domain is set to YKErrorDomain.
 
 @param key Key should be a unique string and include domain + error.
 @result Error with key
 */
- (id)initWithKey:(NSString *const)key userInfo:(NSDictionary *)userInfo;
- (id)initWithKey:(NSString *const)key;

- (id)initWithKey:(NSString *const)key error:(NSError *)error;

/*!
 Create error with key.
 The localized description is set via NSLocalizedString(key).
 See initWithKey:userInfo: method.
 @param key
 @param userInfo
 */
+ (id)errorWithKey:(NSString *const)key userInfo:(NSDictionary *)userInfo;

+ (id)errorWithKey:(NSString *const)key;

+ (id)errorWithKey:(NSString *const)key error:(NSError *)error;

+ (id)errorWithDescription:(NSString *)description;;

- (id)userInfoForKey:(NSString *)key;
- (id)userInfoForKey:(NSString *)key subKey:(NSString *)subKey;

/*!
 Set (override) description.
 @param description
 */
- (void)setDescription:(NSString *)description;

// For subclasses to customize localized description from key
- (NSString *)localizedDescriptionForKey;

/*!
 Build YKError from NSError.
 Returns error if error is already a YKError instance.
 */
+ (YKError *)errorForError:(NSError *)error;

/*!
 Fields that caused the error.
 @result Array of dictionary with name, localized_description keys, or nil
 */
- (NSArray */*of NSDictionary*/)fields;

- (NSArray *)fields;

@end


@interface YKHTTPError : YKError {
  NSInteger _HTTPStatus;
}

@property (readonly, assign, nonatomic) NSInteger HTTPStatus;

+ (YKHTTPError *)errorWithHTTPStatus:(NSInteger)HTTPStatus;
+ (NSString *const)keyForHTTPStatus:(NSInteger)HTTPStatus;

@end
