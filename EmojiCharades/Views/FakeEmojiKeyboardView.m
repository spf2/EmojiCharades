//
//  FakeEmojiKeyboardView.m
//  EmojiCharades
//
//  Created by Steve Farrell on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FakeEmojiKeyboardView.h"

@interface FakeEmojiKeyboardView (PrivateMethods)
- (void)layoutKeyboardPage:(int)page;
- (void)backspaceButtonTap:(UIBarButtonItem *)sender;
@end

@implementation FakeEmojiKeyboardView

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize toolbar = _toolbar;
@synthesize delegate = _delegate;
@synthesize charPages = _charPages;
@synthesize backButton = _backButton;

- (void)layoutKeyboardPage:(int)page
{
    static int utf16CharWidth = 2;
    CGRect pageFrame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    UIView *keyboardView = [[UIView alloc] initWithFrame:pageFrame];
    CGSize gridSize = CGSizeMake(7, 3);
    CGSize buttonSize = CGSizeMake(pageFrame.size.width / gridSize.width, pageFrame.size.height / gridSize.height);
    NSString* emojiChars = [_charPages objectAtIndex:page];
    int emojiCharsLen = emojiChars.length / utf16CharWidth;
    int numPages = ceil(emojiCharsLen / (gridSize.width * gridSize.height));
    for (int i = 0; i < numPages; i++) {
        for (int y = 0; y < gridSize.height; y++) {
            for (int x = 0; x < gridSize.width; x++) {
                int idx = (gridSize.width * gridSize.height * i) + (gridSize.width * y) + x;
                if (idx >= emojiCharsLen) break;
                NSString *emoji = [emojiChars substringWithRange:[emojiChars rangeOfComposedCharacterSequenceAtIndex:idx * utf16CharWidth]];
                CGRect buttonFrame = CGRectMake((i * pageFrame.size.width) + (x * buttonSize.width), y * buttonSize.height, buttonSize.width, buttonSize.height);
                UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
                [button addTarget:_delegate action:@selector(emojiButtonTap:) forControlEvents:UIControlEventTouchUpInside];
                [button setTitle:emoji forState:UIControlStateNormal];
                [keyboardView addSubview:button];
                [button release];
            }
        }
    }
    _pageControl.numberOfPages = numPages;
    _scrollView.contentSize = CGSizeMake(self.frame.size.width * numPages, self.frame.size.height);
    [_scrollView addSubview:keyboardView];
    [keyboardView release];
}

- (void)layoutSubviews
{
    int pagerHeight = 10;
    int toolbarHeight = 30;
    _pageControl.frame = CGRectMake(0, 0, self.frame.size.width, pagerHeight);
    _scrollView.frame = CGRectMake(0, pagerHeight, self.frame.size.width, self.frame.size.height - pagerHeight - toolbarHeight);
    _toolbar.frame = CGRectMake(0, pagerHeight + _scrollView.frame.size.height, self.frame.size.width, toolbarHeight);
    // TODO(spf): trying to find a good time to call layoutkeyboardPage.  The problem with calling it here is that
    // it is invoked many times while scrolling.
    [self layoutKeyboardPage:0];
    _backButton.action = @selector(backspaceButtonTap:);

    [super layoutSubviews];
}

- (void)backspaceButtonTap:(UIBarButtonItem *)sender
{
    [_delegate backspaceButtonTap:sender];
}

- (void)dealloc
{
    [_scrollView release];
    [_pageControl release];
    [_toolbar release];
    [_backButton release];
    [super dealloc];
}


NSString * const _page0 = @"\U0001F604\U0001F60A\U0001F603\U0001F609\U0001F60D\U0001F618\U0001F61A\U0001F633\U0001F60C\U0001F601\U0001F61C\U0001F61D\U0001F612\U0001F60F\U0001F613\U0001F614\U0001F61E\U0001F616\U0001F625\U0001F630\U0001F628\U0001F623\U0001F622\U0001F62D\U0001F602\U0001F632\U0001F631\U0001F620\U0001F621\U0001F62A\U0001F637\U0001F47F\U0001F47D\U0001F49B\U0001F499\U0001F49C\U0001F497\U0001F49A\U0001F494\U0001F493\U0001F498\U0001F31F\U0001F4A2\U0001F4A4\U0001F4A8\U0001F4A6\U0001F3B6\U0001F3B5\U0001F525\U0001F4A9\U0001F44D\U0001F44E\U0001F44C\U0001F44A";

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.charPages = [NSArray arrayWithObjects:_page0, nil];
    }
    return self;
}

@end
