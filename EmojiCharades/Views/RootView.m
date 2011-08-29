//
//  RootView.m
//  EmojiCharades
//
//  Created by Steve Farrell on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootView.h"

@implementation RootView

@synthesize facebookButton = _facebookButton;
@synthesize playButtonItem = _playButtonItem;
@synthesize activityView = _activityView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [_playButtonItem release];
    [_facebookButton release];
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
