//
//  YKLocalized.m
//  YelpIPhone
//
//  Created by Gabriel Handford on 11/18/08.
//  Copyright 2008 Yelp. All rights reserved.
//

#import "YKLocalized.h"
#import "YKDefines.h"


#include <math.h>

#define kDefaultTableName @"Localizable"
static NSString *gDefaultTableName = kDefaultTableName;

@implementation NSBundle (YKLocalized)

static NSMutableDictionary *gLocalizationResourceCache = nil;

// Get resource cache
+ (NSMutableDictionary *)yelp_localizationResourceCache {
  @synchronized([YKLocalized class]) {
    if (!gLocalizationResourceCache) gLocalizationResourceCache = [[NSMutableDictionary alloc] init];
  }
  return gLocalizationResourceCache;
}

// Clear resource cache
+ (void)yelp_clearCache {
  [[self yelp_localizationResourceCache] removeAllObjects];
}

- (NSDictionary *)yelp_loadResourceForTableName:(NSString *)tableName localization:(NSString *)localization {
  if ([localization isEqual:@"en_US"]) localization = @"en";
  NSString *resource = [self pathForResource:tableName ofType:@"strings" inDirectory:nil forLocalization:localization];
  if (!resource) return nil;
  
  NSDictionary *dict = nil;
  
  @synchronized([YKLocalized class]) {
    dict = [[NSBundle yelp_localizationResourceCache] objectForKey:resource];   
    if (!dict) {
      NSDictionary *newDict = [[NSDictionary alloc] initWithContentsOfFile:resource];
      [[NSBundle yelp_localizationResourceCache] setObject:newDict forKey:resource];
      dict = newDict;
      [newDict autorelease]; // Retained by yelp_localizationResourceCache
    }
  }
  return dict;
}

// Look for string with localization string
- (NSString *)yelp_stringForKey:(NSString *)key tableName:(NSString *)tableName localization:(NSString *)localization {
  if (!localization) localization = [YKLocalized languageCode];

  NSString *value = [[YKLocalized localizationCache] objectForKey:key];
  if (value) return value;

  NSDictionary *dict = [self yelp_loadResourceForTableName:tableName localization:localization];
  value = [dict objectForKey:key];
  if (value) {
    [[YKLocalized localizationCache] setObject:value forKey:key];
  }
  return value;
}

- (NSString *)yelp_preferredLanguageForTableName:(NSString *)tableName {
  static NSString *LanguageCode = nil;
  if (LanguageCode) return LanguageCode;
  
  for (NSString *languageCode in [NSLocale preferredLanguages]) {
    // Check if we have a bundle with this preferred language code
    if (!![self yelp_loadResourceForTableName:tableName localization:languageCode]) {
      LanguageCode = [languageCode copy];
      break;
    }
  }
  if (!LanguageCode) LanguageCode = @"en";
  return LanguageCode;
}

// Patched localized string.
- (NSString *)yelp_localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)table {
  if (!key) {
    YKInfo(@"Trying to localize nil key, (with value=%@, tableName=%@)", value, table);
    return nil;
  }
  if (!table) table = gDefaultTableName; // Default file is Localizable.strings

  NSString *localizedString = [self yelp_localizedStringForKey:key table:table];
  
  if (!localizedString) {
    YKWarn(@"\n\n\nNo localized string for key: %@, using default: %@\n\n", key, value);
    localizedString = value;
  }
  if (!localizedString) {
    YKWarn(@"\n\n\nNo localized string for key: %@\n\n", key);
    localizedString = key;
  }
  return localizedString;
}

- (NSString *)yelp_localizedStringForKey:(NSString *)key table:(NSString *)table {
  NSString *localizedString = [self yelp_stringForKey:key tableName:table localization:[YKLocalized localeIdentifier]];
  
  // If not found, check preferredLanguages
  if (!localizedString)
    localizedString = [self yelp_stringForKey:key tableName:table localization:[self yelp_preferredLanguageForTableName:table]];
  
  return localizedString;
}

@end

@implementation YKLocalized

static NSMutableDictionary *gLocalizationCache = nil;
static NSString *gLocaleIdentifier = nil;
static NSSet *gSupportedLanguages = nil;
static NSString *gLanguageCode = nil;

+ (NSMutableDictionary *)localizationCache {
  @synchronized([YKLocalized class]) {
    if (!gLocalizationCache) gLocalizationCache = [[NSMutableDictionary alloc] init];
  }
  return gLocalizationCache;
}

+ (void)clearCache {
  [[self localizationCache] removeAllObjects];
  [NSBundle yelp_clearCache];
  [gLocaleIdentifier release];
  gLocaleIdentifier = nil;
  [gLanguageCode release];
  gLanguageCode = nil;
}

+ (NSString *)localize:(NSString *)key table:(NSString *)table value:(NSString *)value {
  return NSLocalizedStringWithDefaultValue(key, table, [NSBundle bundleForClass:[self class]], value, @"");
}

+ (void)setDefaultTableName:(NSString *)defaultTableName {
  [gDefaultTableName release];
  gDefaultTableName = (defaultTableName ? [defaultTableName copy] : kDefaultTableName);
}

+ (BOOL)isMetric {
  return [self isMetric:[NSLocale currentLocale]];
}

+ (BOOL)isMetric:(id)locale {
  // Override metric for GB (use miles)
  if ([[self countryCode] isEqualToString:@"GB"]) return NO;
  
  return [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];
}

+ (NSString *)currencySymbol {
  return [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
}

+ (NSString *)localeIdentifier {
  if (!gLocaleIdentifier) {
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    if (countryCode) gLocaleIdentifier = [[NSString stringWithFormat:@"%@_%@", [YKLocalized languageCode], countryCode] retain];
    else gLocaleIdentifier = [[YKLocalized languageCode] retain];
    YKDebug(@"gLocaleIdentifier: %@", gLocaleIdentifier);
  }
  return gLocaleIdentifier;
}

// TODO(johnb): This doesn't make sense in YelpKit. Move it to YPLocalized
+ (NSSet *)supportedLanguages {
  if (!gSupportedLanguages) {
    gSupportedLanguages = [[NSSet setWithObjects:@"en", @"es", @"fr", @"it", @"de", @"nl", nil] retain];
  }
  return gSupportedLanguages;
}

+ (NSString *)countryCode {
  return [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleCountryCode];
}

+ (NSString *)languageCode {
  if (!gLanguageCode) {
    NSArray *preferredLanguages = [NSLocale preferredLanguages];
    for (NSString *language in preferredLanguages) {
      if ([[YKLocalized supportedLanguages] containsObject:language]) {
        gLanguageCode = [language retain];
        return gLanguageCode;
      }
    }
    gLanguageCode = [@"en" retain];
  }
  return gLanguageCode;
}

+ (BOOL)isCountryCode:(NSString *)code {
  NSString *countryCode = [self countryCode];
  return ([countryCode compare:code options:NSCaseInsensitiveSearch] == NSOrderedSame);
}

+ (NSString *)localizedPath:(NSString *)name ofType:(NSString *)type {
  NSString *localeIdentifier = [YKLocalized localeIdentifier];
  
  NSString *resourcePath = [[NSBundle mainBundle] pathForResource:name ofType:type inDirectory:nil forLocalization:localeIdentifier];
  // Try a localization for the language code
  if (!resourcePath) resourcePath = [[NSBundle mainBundle] pathForResource:name ofType:type inDirectory:nil forLocalization:[YKLocalized languageCode]];
  // Try localizing based on 'en'
  if (!resourcePath) resourcePath = [[NSBundle mainBundle] pathForResource:name ofType:type inDirectory:nil forLocalization:@"en"];
  // If a localized version was found, remove the base resource path
  if (resourcePath) {
    NSString *baseResourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath substringFromIndex:[baseResourcePath length] + 1];
  // Otherwise just return the filename
  } else {
    resourcePath = [NSString stringWithFormat:@"%@.%@", name, type];
  }
  return resourcePath;
}

+ (NSString *)localizedListFromStrings:(NSArray */*of NSString*/)strings {
  if (!strings || ([strings count] <= 0)) return nil;
  if ([strings count] == 1) return [strings objectAtIndex:0];
  if ([strings count] == 2) {
    return [NSString stringWithFormat:@"%@ %@ %@", [strings objectAtIndex:0], YKLocalizedString(@"and"), [strings objectAtIndex:1], nil];
  }
  NSMutableString *localizedList = [[[NSMutableString alloc] initWithString:[strings objectAtIndex:0]] autorelease];
  for (NSInteger i = 1; i < [strings count]; i++) {
    if (i == ([strings count] - 1)) [localizedList appendFormat:@" %@ ", YKLocalizedString(@"and"), nil];
    else [localizedList appendString:@", "];
    [localizedList appendString:[strings objectAtIndex:i]];
  }
  return localizedList;
}

+ (NSDateFormatter *)dateFormatter {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setLocale:[YKLocalized currentLocale]];
  return [formatter autorelease];
}

+ (NSLocale *)currentLocale {
  NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:[YKLocalized localeIdentifier]];
  return [locale autorelease];
}

@end

