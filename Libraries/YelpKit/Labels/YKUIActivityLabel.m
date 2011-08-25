//
//  YKUIActivityLabel.m
//  YelpKit
//
//  Created by Gabriel Handford on 4/6/10.
//  Copyright 2010 Yelp. All rights reserved.
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

#import "YKUIActivityLabel.h"
#import <GHKitIOS/GHNSString+Utils.h>
#import "YKCGUtils.h"
#import "YKLocalized.h"

@implementation YKUIActivityLabel

@synthesize textLabel=_textLabel, detailLabel=_detailLabel, imageView=_imageView;

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _textLabel.text = YKLocalizedString(@"Loading...");
    _textLabel.font = [UIFont systemFontOfSize:16.0];
    _textLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1.0];
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.contentMode = UIViewContentModeCenter;
    _textLabel.textAlignment = UITextAlignmentLeft;
    [self addSubview:_textLabel];
    [_textLabel release];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.hidesWhenStopped = YES;
    [self addSubview:_activityIndicator];
    [_activityIndicator release];  

    _imageView = [[UIImageView alloc] init];
    _imageView.hidden = YES;
    [self addSubview:_imageView];
    [_imageView release];
    
    [self setNeedsLayout];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  CGSize size = self.frame.size;
  CGFloat height = 20;  
  
  CGSize lineSize = CGSizeZero;
  if (![NSString gh_isBlank:_textLabel.text]) {
    lineSize = [_textLabel.text sizeWithFont:_textLabel.font constrainedToSize:size
                               lineBreakMode:UILineBreakModeTailTruncation];    
  }
  
  if (![NSString gh_isBlank:_detailLabel.text]) height += 20;
  
  if (_activityIndicator.isAnimating || !_imageView.hidden) lineSize.width += 24;
  
  CGFloat x = YKCGFloatToCenter(lineSize.width, size.width, 0);
  CGFloat y = YKCGFloatToCenter(height, size.height, 0);
  
  _activityIndicator.frame = CGRectMake(x, y, 20, 20);
  if (_activityIndicator.isAnimating) x += 24;
  
  _imageView.frame = CGRectMake(x, y, 20, 20);
  if (!_imageView.hidden) x += 24;

  _textLabel.frame = CGRectMake(x, y, size.width, 20);
  y += 24;
  _detailLabel.frame = CGRectMake(0, y, size.width, 20);  
}

- (void)startAnimating {
  _imageView.hidden = YES;
  [_activityIndicator startAnimating];
  [self setNeedsLayout];
}

- (void)stopAnimating {
  [_activityIndicator stopAnimating];
  if (_imageView.image)
    _imageView.hidden = NO;
  [self setNeedsLayout];
}

- (void)setText:(NSString *)text {
  self.textLabel.text = text;
}

- (BOOL)isAnimating {
  return [_activityIndicator isAnimating];  
}

- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)activityIndicatorViewStyle {
  _activityIndicator.activityIndicatorViewStyle = activityIndicatorViewStyle;
}

- (UIActivityIndicatorViewStyle)activityIndicatorViewStyle {
  return _activityIndicator.activityIndicatorViewStyle;
}

- (void)setImage:(UIImage *)image {
  if (image) {
    _activityIndicator.hidden = YES;
    _imageView.hidden = NO;
    _imageView.image = image;
  } else {
    _activityIndicator.hidden = NO;
    _imageView.hidden = YES;
  }
  [self setNeedsLayout];
  [self setNeedsDisplay];
}

- (UILabel *)detailLabel {
  if (!_detailLabel) {
    _detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _detailLabel.font = [UIFont systemFontOfSize:14.0];
    _detailLabel.textColor = [UIColor colorWithWhite:0.45 alpha:1.0];
    _detailLabel.textAlignment = UITextAlignmentCenter;
    _detailLabel.contentMode = UIViewContentModeCenter;
    [self addSubview:_detailLabel];
    [_detailLabel release];
    [self setNeedsLayout];
  }
  return _detailLabel;
}

@end
