//
//  NSString+timeAgo.m
//  EmojiCharades
//
//  Created by Steve Farrell on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDate+timeAgo.h"

@implementation NSDate (Extensions)

// Based on http://forrst.com/posts/Time_passed_NSDate_category_for_activity_feed-tmj
-(NSString *)timeAgo {
    NSDate *now = [NSDate date];
    double deltaMinutes = fabs([self timeIntervalSinceDate:now]) / 60.0f;
    if (deltaMinutes < 1) {
        return @"just now";
    } else if (deltaMinutes < 2) {
        return @"a minute ago";
    } else if (deltaMinutes < 60){
        return [NSString stringWithFormat:@"%d minutes ago", (int)floor(deltaMinutes)];
    } else if (deltaMinutes < 120) {
        return @"an hour ago";
    } else if (deltaMinutes < (24 * 60)) {
        return [NSString stringWithFormat:@"%d hours ago", (int)floor(deltaMinutes/60)];
    } else if (deltaMinutes < (24 * 60 * 2)) {
        return @"yesterday";
    } else if (deltaMinutes < (24 * 60 * 7)) {
        return [NSString stringWithFormat:@"%d days ago", (int)floor(deltaMinutes/(60 * 24))];
    } else if (deltaMinutes < (24 * 60 * 14)) {
        return @"last week";
    } else if (deltaMinutes < (24 * 60 * 31)) {
        return [NSString stringWithFormat:@"%d weeks ago", (int)floor(deltaMinutes/(60 * 24 * 7))];
    } else if (deltaMinutes < (24 * 60 * 61)) {
        return @"last month";
    } else if (deltaMinutes < (24 * 60 * 365)) {
        return [NSString stringWithFormat:@"%d months ago", (int)floor(deltaMinutes/(60 * 24 * 31))];
    } else if (deltaMinutes < (24 * 60 * 730)) {
        return @"last year";
    }
    return [NSString stringWithFormat:@"%d years ago", (int)floor(deltaMinutes/(60 * 24 * 365))];
}

@end
