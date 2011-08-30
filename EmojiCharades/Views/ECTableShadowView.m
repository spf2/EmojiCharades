//
//  ECTableShadowView.m
//  EmojiCharades
//
//  Created by Rowan Nairn on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECTableShadowView.h"
#import "YKCGUtils.h"

@implementation ECTableShadowView

- (id)initWithFrame:(CGRect)frame
{
    frame.size.height = 6;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    YKCGContextDrawLine(context, 0, 0.5, self.frame.size.width, 0.5, [UIColor colorWithWhite:0.6 alpha:1.0].CGColor, 1.0); // Top border
    YKCGContextDrawLinearGradient(context, CGRectMake(0, 1, self.frame.size.width, self.frame.size.height - 1),[UIColor colorWithWhite:0.7 alpha:1.0].CGColor, [UIColor colorWithWhite:0.8 alpha:1.0].CGColor);
}



@end
