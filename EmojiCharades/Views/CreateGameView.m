//
//  CreateGameView.m
//  EmojiCharades
//
//  Created by Steve Farrell on 8/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CreateGameView.h"

@implementation CreateGameView

@synthesize hintTextView = _hintTextView;
@synthesize keyboardScrollView = _keyboardScrollView;

- (void)layoutSubviews
{
    _hintTextView.layer.cornerRadius = 5;
    _hintTextView.clipsToBounds = YES;    
}

- (void)dealloc
{
    [_hintTextView release];
    [_keyboardScrollView release];
    [super dealloc];
}

@end
