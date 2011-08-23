//
//  YKUIView.m
//  YelpKit
//
//  Created by Gabriel Handford on 6/19/09.
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

#import "YKUIView.h"
#import "YKCGUtils.h"


@implementation YKUIView

@synthesize layout=_layout;

- (void)dealloc {
  [_layout clear];
  [_layout release];
  [super dealloc];
}

- (void)setFrame:(CGRect)frame {
  if (_layout && !YKCGRectIsEqual(self.frame, frame)) [_layout setNeedsLayout];
  [super setFrame:frame];
}

#pragma mark Layout

- (void)layoutSubviews {
  [super layoutSubviews];
  YKLayoutAssert(self, _layout);
  if (_layout) {
    [_layout layoutSubviews:self.frame.size];
  }
}

- (CGSize)sizeThatFits:(CGSize)size {
  YKLayoutAssert(self, _layout);  
  if (_layout) {
    return [_layout sizeThatFits:size];
  }
  return [super sizeThatFits:size];
}

- (void)setNeedsLayout {
  [super setNeedsLayout];
  [_layout setNeedsLayout];
}

#pragma mark Drawing/Layout

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  [_layout drawSubviewsInRect:self.bounds];
}

- (void)drawInRect:(CGRect)rect {
  [_layout drawSubviewsInRect:rect];
}

@end
