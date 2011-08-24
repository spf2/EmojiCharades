//
//  YELabelTableViewCell.m
//  YelpKit
//
//  Created by Gabriel Handford on 8/23/11.
//  Copyright 2011 Yelp. All rights reserved.
//

#import "YELabelTableViewCell.h"

@implementation YELabelTableViewCell

@synthesize cellView=_cellView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
    _cellView = [[YELabelCellView alloc] init];
    [self.contentView addSubview:_cellView];
    [_cellView release];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  _cellView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (CGSize)sizeThatFits:(CGSize)size {
  return [_cellView sizeThatFits:size];
}

@end

