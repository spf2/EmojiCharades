//
//  YKUIRefreshTableHeaderView.m
//  Original name: EGORefreshTableHeaderView.m
//  Heavily modified
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


#import "YKUIRefreshTableHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "YKCGUtils.h"
#import "YKLocalized.h"

@implementation YKUIRefreshTableHeaderView

@synthesize state=_state, pullHeight=_pullHeight, pullAmount=_pullAmount, momentary=_momentary, pullIconDisabled=_pullIconDisabled;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.clipsToBounds = YES;
    _pullHeight = 48;
        
    _activityLabel = [[YKUIActivityLabel alloc] initWithFrame:CGRectZero];
    _activityLabel.backgroundColor = [UIColor clearColor];
    _activityLabel.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
    _activityLabel.textLabel.textColor = [UIColor grayColor];
    _activityLabel.textLabel.shadowColor = [UIColor whiteColor];
    _activityLabel.textLabel.shadowOffset = CGSizeMake(0, 1);    
    [self addSubview:_activityLabel];
    [_activityLabel release];

    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pull_to_refresh_icon.png"]];    
    _imageView.contentMode = UIViewContentModeCenter;
    [self addSubview:_imageView];
    [_imageView release];
    
    _icon = [[UIImage imageNamed:@"pull_to_refresh_icon.png"] retain];
    _iconLayer = [[CALayer alloc] init];
    _iconLayer.contentsGravity = kCAGravityResizeAspect;
    _iconLayer.contents = (id)_icon.CGImage;
    [[self layer] addSublayer:_iconLayer];
    [_iconLayer release];
    
    [self setState:YKUIPullRefreshNormal];
    [self setPullIconDisabled:YES];
    [self setNeedsLayout];
  }
  return self;
}

- (void)dealloc {
  _iconLayer.contents = NULL;
  [_icon release];
  [super dealloc];
}

- (void)setPullAmount:(CGFloat)pullAmount {
  _pullAmount = pullAmount;
  if (_state == YKUIPullRefreshLoading) return;
  CGFloat pad = 8;
  CGFloat y = _pullAmount - (_pullHeight - _icon.size.height) + pad;  
  if (y > _icon.size.height + pad) y = _icon.size.height + pad;
  _iconLayer.frame = YKCGRectSetY(_iconLayer.frame, self.frame.size.height - y);
}

- (void)setPullIconDisabled:(BOOL)pullIconDisabled {
  _pullIconDisabled = pullIconDisabled;
  _iconLayer.hidden = pullIconDisabled;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  // Note: View frame height will be large so we can continue our background color;
  CGFloat height = _pullHeight;
  CGFloat y = self.frame.size.height - _pullHeight;
  
  CGFloat activityLabelWidth = MAX([YKLocalizedString(@"Release to refresh...") sizeWithFont:_activityLabel.textLabel.font].width,
                                   [YKLocalizedString(@"Pull down to refresh...") sizeWithFont:_activityLabel.textLabel.font].width);

  _activityLabel.frame = CGRectMake(roundf((self.frame.size.width - activityLabelWidth) / 2.0), y, roundf(activityLabelWidth), height);
  
  _imageView.frame = CGRectMake(_imageView.frame.size.width - _activityLabel.frame.origin.x - 10, y, _imageView.frame.size.width, height);

  _iconLayer.frame = CGRectMake(50, self.frame.size.height, _icon.size.width, _icon.size.height);
}

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  UIColor *backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
  UIColor *shadowColor = [UIColor colorWithWhite:0.8 alpha:1.0];
  YKCGContextDrawRect(context, self.bounds, backgroundColor.CGColor, NULL, 0);
  YKCGContextDrawShading(context, 
                         backgroundColor.CGColor, 
                         shadowColor.CGColor,
                         NULL, 
                         NULL,
                         CGPointMake(0, self.frame.size.height - 20), 
                         CGPointMake(0, self.frame.size.height), 
                         YKUIShadingTypeExponential,
                         NO, YES);
}

- (void)setState:(YKUIPullRefreshState)state {
  
  switch (state) {
    case YKUIPullRefreshPulling:
      _imageView.hidden = NO;
      [_activityLabel setText:YKLocalizedString(@"Release to refresh...")];
      [_activityLabel setNeedsLayout];
      break;
      
    case YKUIPullRefreshNormal:
      _imageView.hidden = NO;
      [self setPullAmount:0];      
      [_activityLabel setText:YKLocalizedString(@"Pull down to refresh...")];
      [_activityLabel stopAnimating];
      break;
      
    case YKUIPullRefreshLoading:     
      _imageView.hidden = YES;
      [_activityLabel setText:YKLocalizedString(@"Loading...")];
      [_activityLabel startAnimating];
      if (!_momentary)
        [self setPullAmount:_pullHeight];
      break;
  }
    
  // Image animation
  if (state == YKUIPullRefreshPulling && _state != YKUIPullRefreshPulling) {
    // From not pulling to pulling
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    _imageView.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
    [UIView commitAnimations];      
  } else if (state != YKUIPullRefreshPulling && _state == YKUIPullRefreshPulling) {
    // From pulling to not pulling
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    _imageView.layer.transform = CATransform3DMakeRotation(0, 0.0f, 0.0f, 1.0f);                                               
    [UIView commitAnimations];          
  }
  
  _state = state;
}

@end