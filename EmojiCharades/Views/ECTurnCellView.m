//
//  ECTurnCellView.m
//  EmojiCharades
//
//  Created by Rowan on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECTurnCellView.h"
#import "NSDate+timeAgo.h"
#import "Constants.h"
#import "YKCGUtils.h"

@implementation ECTurnCellView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        self.layout = [YKLayout layoutForView:self];
        
        _userImageView = [[YKUIImageView alloc] init];
        _userImageView.cornerRadius = 6.0;
        _userImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_userImageView];
        [_userImageView release];
        
        UIColor *textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
        
        _userNameLabel = [[UILabel alloc] init];
        _userNameLabel.font = [UIFont systemFontOfSize:14];
        _userNameLabel.textColor = textColor;
        _userNameLabel.backgroundColor = [UIColor clearColor];
        _userNameLabel.shadowColor = [UIColor whiteColor];
        _userNameLabel.shadowOffset = CGSizeMake(0, 1);
        _userNameLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self addSubview:_userNameLabel];
        [_userNameLabel release];
        
        _timeAgoLabel = [[UILabel alloc] init];
        _timeAgoLabel.font = [UIFont systemFontOfSize:14];
        _timeAgoLabel.textColor = textColor;
        _timeAgoLabel.backgroundColor = [UIColor clearColor];
        _timeAgoLabel.shadowColor = [UIColor whiteColor];
        _timeAgoLabel.shadowOffset = CGSizeMake(0, 1);
        _timeAgoLabel.textAlignment = UITextAlignmentRight;
        [self addSubview:_timeAgoLabel];
        [_timeAgoLabel release];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.font = [UIFont systemFontOfSize:18];
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = UILineBreakModeWordWrap;
        [self addSubview:_textLabel];
        [_textLabel release];
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
    CGRect hintLabelFrame = [layout setFrame:CGRectMake(x, y, size.width - x - 25, 0) view:_textLabel sizeToFit:YES];
    y += hintLabelFrame.size.height + 4;
    
    return CGSizeMake(size.width, y);
}
    
- (void)setUserName:(NSString *)userName userImageURLString:(NSString *)userImageURLString lastModifiedDate:(NSDate *)lastModifiedDate text:(NSString *)text status:(int)status {
    _userNameLabel.text = [NSString stringWithFormat:@"By %@", userName];
    _timeAgoLabel.text = [lastModifiedDate timeAgo];
    _textLabel.text = text;
    
//    if (status == ECResultWrong) {
//    } else if (status == ECResultRight) {    
//    } else {
//    }
    
    [_userImageView setURLString:userImageURLString];
    [self setNeedsLayout];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    YKCGContextDrawLine(context, 0, 0.5, self.frame.size.width, 0.5, [UIColor colorWithWhite:0.6 alpha:1.0].CGColor, 1.0); // Top border
    YKCGContextDrawLine(context, 0, 1.5, self.frame.size.width, 1.5, [UIColor whiteColor].CGColor, 1.0);
}

@end


@implementation ECTurnTableViewCell

@synthesize turnCellView = _turnCellView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
        _turnCellView = [[ECTurnCellView alloc] init];
        [self.contentView addSubview:_turnCellView];
        [_turnCellView release];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _turnCellView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [_turnCellView sizeThatFits:size];
}

@end
