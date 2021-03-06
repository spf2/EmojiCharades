//
//  ECGameCellView.m
//  EmojiCharades
//
//  Created by Gabriel Handford on 8/22/11.
//  Copyright 2011. All rights reserved.
//

#import "ECGameCellView.h"
#import "NSDate+timeAgo.h"
#import "YKCGUtils.h"

@implementation ECGameCellView

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.layout = [YKLayout layoutForView:self];

    _userImageView = [[YKUIImageView alloc] init];
    _userImageView.cornerRadius = 6.0;
    _userImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:_userImageView];
    [_userImageView release];
    
    _userNameLabel = [[UILabel alloc] init];
    _userNameLabel.highlightedTextColor = [UIColor whiteColor];
    _userNameLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    _userNameLabel.font = [UIFont systemFontOfSize:14];
    _userNameLabel.backgroundColor = [UIColor clearColor];
    _userNameLabel.shadowColor = [UIColor whiteColor];
    _userNameLabel.shadowOffset = CGSizeMake(0, 1);
    _userNameLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [self addSubview:_userNameLabel];
    [_userNameLabel release];
    
    _timeAgoLabel = [[UILabel alloc] init];
    _timeAgoLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    _timeAgoLabel.highlightedTextColor = [UIColor whiteColor];
    _timeAgoLabel.font = [UIFont systemFontOfSize:14];
    _timeAgoLabel.backgroundColor = [UIColor clearColor];
    _timeAgoLabel.shadowColor = [UIColor whiteColor];
    _timeAgoLabel.shadowOffset = CGSizeMake(0, 1);
    _timeAgoLabel.textAlignment = UITextAlignmentRight;
    [self addSubview:_timeAgoLabel];
    [_timeAgoLabel release];
    
    _hintLabel = [[UILabel alloc] init];
    _hintLabel.backgroundColor = [UIColor clearColor];
    _hintLabel.font = [UIFont systemFontOfSize:18];
    _hintLabel.numberOfLines = 0;
    _hintLabel.lineBreakMode = UILineBreakModeWordWrap;
    [self addSubview:_hintLabel];
    [_hintLabel release];
    
    _statusLabel = [[UILabel alloc] init];
    _statusLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];    
    _statusLabel.highlightedTextColor = [UIColor whiteColor];
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.font = [UIFont systemFontOfSize:14];
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
  
  CGRect userImageViewFrame = [layout setFrame:CGRectMake(x, y, 20, 20) view:_userImageView];
  x += userImageViewFrame.size.width + 9;
  
  CGRect userNameLabelFrame = [layout setFrame:CGRectMake(x, y, 154, 20) view:_userNameLabel];
  x += userNameLabelFrame.size.width + 12;
  [layout setFrame:CGRectMake(x, y, size.width - x - 25, 20) view:_timeAgoLabel];
  y += 26;

  x = 12; // Reset x
  
  // Leave padding on right for disclosure icon
  CGRect hintLabelFrame = [layout setFrame:CGRectMake(x, y, size.width - x - 25, 0) view:_hintLabel sizeToFit:YES];
  y += hintLabelFrame.size.height + 4;
  
  CGRect statusLabelFrame = [layout setFrame:CGRectMake(x, y, size.width - x - 25, 0) view:_statusLabel sizeToFit:YES];
  y += statusLabelFrame.size.height + 6;
  
  return CGSizeMake(size.width, y);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
  _highlighted = highlighted;
  if (highlighted) {
    _userNameLabel.shadowColor = nil;
    _timeAgoLabel.shadowColor = nil;
    _statusLabel.shadowColor = nil;
  } else {
    _userNameLabel.shadowColor = [UIColor whiteColor];
    _timeAgoLabel.shadowColor = [UIColor whiteColor];
    _statusLabel.shadowColor = [UIColor whiteColor];
  }
  [self setNeedsDisplay];
}

- (void)setUserName:(NSString *)userName userImageURLString:(NSString *)userImageURLString lastModifiedDate:(NSDate *)lastModifiedDate hint:(NSString *)hint status:(NSString *)status {
  _userNameLabel.text = [NSString stringWithFormat:@"By %@", userName];
  _timeAgoLabel.text = [lastModifiedDate timeAgo];
  _hintLabel.text = hint;
  _statusLabel.text = status;
  
  [_userImageView setURLString:userImageURLString];
  [self setNeedsLayout];
}

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  CGContextRef context = UIGraphicsGetCurrentContext();
  /*
  YKCGContextDrawLine(context, 0, 0.5, self.frame.size.width, 0.5, [UIColor whiteColor].CGColor, 1.0); // Top border
  YKCGContextDrawLine(context, 0, self.frame.size.height - 0.5, self.frame.size.width, self.frame.size.height - 0.5, [UIColor colorWithWhite:0.6 alpha:1.0].CGColor, 1.0); // Bottom border
   */
  
  if (!_highlighted) {
    YKCGContextDrawLine(context, 0, 0.5, self.frame.size.width, 0.5, [UIColor colorWithWhite:0.6 alpha:1.0].CGColor, 1.0); // Top border
    YKCGContextDrawLine(context, 0, 1.5, self.frame.size.width, 1.5, [UIColor whiteColor].CGColor, 1.0);
  }
}

@end


@implementation ECGameTableViewCell

@synthesize gameCellView=_gameCellView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
    _gameCellView = [[ECGameCellView alloc] init];
    [self.contentView addSubview:_gameCellView];
    [_gameCellView release];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  _gameCellView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
  [super setHighlighted:highlighted animated:animated];
  [_gameCellView setHighlighted:highlighted animated:NO];
}

- (CGSize)sizeThatFits:(CGSize)size {
  return [_gameCellView sizeThatFits:size];
}

@end
