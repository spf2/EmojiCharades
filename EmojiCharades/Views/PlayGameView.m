//
//  PlayGameView.m
//  EmojiCharades
//
//  Created by Gabriel Handford on 8/15/11.
//  Copyright 2011. All rights reserved.
//

#import "PlayGameView.h"

@implementation PlayGameView

@synthesize hintLabel=_hintLabel, metadataLabel=_metadataLabel, turnTableScrollView=_turnTableScrollView, turnTableView = _turnTableView, guessTextField = _guessTextField,guessToolbar = _guessToolbar;

- (void)dealloc {
    [_hintLabel release];
    [_metadataLabel release];
    [_turnTableScrollView release];
    [_turnTableView release];
    [_guessTextField release];
    [_guessToolbar release];
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat y = 10;
    _hintLabel.frame = CGRectMake(10, y, 300, 38);
    [_hintLabel sizeToFit];
    y += _hintLabel.frame.size.height + 6;
    
    _metadataLabel.frame = CGRectMake(10, y, 300, 16);
    y += _metadataLabel.frame.size.height + 8;
    
    _turnTableScrollView.frame = CGRectMake(0, y, 320, self.frame.size.height - y);
}

@end
