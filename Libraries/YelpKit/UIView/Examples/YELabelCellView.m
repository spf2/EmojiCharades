//
//  YELabelCellView.m
//  YelpKit
//
//  Created by Gabriel Handford on 8/22/11.
//  Copyright 2011 Yelp. All rights reserved.
//

#import "YELabelCellView.h"
#import "YKCGUtils.h"

@implementation YELabelCellView

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.layout = [YKLayout layoutForView:self];

    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:14];
    _nameLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.shadowColor = [UIColor whiteColor];
    _nameLabel.shadowOffset = CGSizeMake(0, 1);
    _nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [self addSubview:_nameLabel];
    [_nameLabel release];
        
    _statusLabel = [[UILabel alloc] init];
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.font = [UIFont systemFontOfSize:14];
    _statusLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    _statusLabel.shadowColor = [UIColor whiteColor];
    _statusLabel.shadowOffset = CGSizeMake(0, 1);
    _statusLabel.numberOfLines = 0;
    _statusLabel.lineBreakMode = UILineBreakModeWordWrap;
    [self addSubview:_statusLabel];
    [_statusLabel release];
  }
  return self;
}

- (CGSize)layout:(id<YKLayout>)layout size:(CGSize)size {
  CGFloat x = 12;
  CGFloat y = 6;
  
  CGRect nameLabelFrame = [layout setFrame:CGRectMake(x, y, size.width - x - 25, 20) view:_nameLabel sizeToFit:YES];
  y += nameLabelFrame.size.height + 6;

  CGRect statusLabelFrame = [layout setFrame:CGRectMake(x, y, size.width - x - 25, 0) view:_statusLabel sizeToFit:YES];
  y += statusLabelFrame.size.height + 6;
  
  return CGSizeMake(size.width, y);
}

- (void)setName:(NSString *)name status:(NSString *)status {
  _nameLabel.text = name;
  _statusLabel.text = status;  
  [self setNeedsLayout];
}

// Example of line drawing (border)
- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  CGContextRef context = UIGraphicsGetCurrentContext();
  YKCGContextDrawLine(context, 0, 0.5, self.frame.size.width, 0.5, [UIColor colorWithWhite:0.6 alpha:1.0].CGColor, 1.0); // Top border
  YKCGContextDrawLine(context, 0, 1.5, self.frame.size.width, 1.5, [UIColor whiteColor].CGColor, 1.0);
}

@end
