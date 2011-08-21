//
//  ECKeyboardView.m
//  EmojiCharades
//
//  Created by Steve Farrell on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECKeyboardView.h"
#import "Constants.h"

@interface ECKeyboardView (PrivateMethods)
- (void)layoutKeyboardCategoryEntry:(CategoryEntry *)entry;
- (void)backspaceButtonTap:(UIBarButtonItem *)sender;
- (void)categoryButtonTap:(UIBarButtonItem *)sender;
- (void)switchToCategory:(CategoryEntry *)entry;
- (CGRect)pageFrame;
@end

@implementation CategoryEntry
@synthesize chars = _chars, view = _view, numPages = _numPages, buttonItem = _buttonItem;
@end

@implementation ECKeyboardView

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize toolbar = _toolbar;
@synthesize delegate = _delegate;
@synthesize entries = _entries;
@synthesize backButton = _backButton;

- (void)initialize
{
    _backButton.action = @selector(backspaceButtonTap:);
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:self.backButton, nil];
    for (CategoryEntry *entry in self.entries) {
        UIView *categoryView = [[UIView alloc] initWithFrame:self.pageFrame];
        entry.view = categoryView;
        entry.buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"X" style:UIBarButtonItemStyleBordered target:self action:@selector(categoryButtonTap:)];
        [items addObject:entry.buttonItem];
        [self layoutKeyboardCategoryEntry:entry];
        [categoryView release];
    }
    self.toolbar.items = items;
    [items release];
    
    [self switchToCategory:[self.entries objectAtIndex:0]];
}

- (CGRect)pageFrame
{
    return CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
}

- (void)layoutKeyboardCategoryEntry:(CategoryEntry *)entry
{
    CGRect frame = self.pageFrame;
    CGSize gridSize = CGSizeMake(7, 3);
    CGSize buttonSize = CGSizeMake(frame.size.width / gridSize.width, frame.size.height / gridSize.height);
    int emojiCharsLen = entry.chars.length / ECUTF16Width;
    entry.numPages = ceil(emojiCharsLen / (gridSize.width * gridSize.height));
    for (int page = 0; page < entry.numPages; page++) {
        for (int y = 0; y < gridSize.height; y++) {
            for (int x = 0; x < gridSize.width; x++) {
                int idx = (gridSize.width * gridSize.height * page) + (gridSize.width * y) + x;
                if (idx >= emojiCharsLen) break;
                NSString *emoji = [entry.chars substringWithRange:[entry.chars rangeOfComposedCharacterSequenceAtIndex:idx * ECUTF16Width]];
                CGRect buttonFrame = CGRectMake((page * frame.size.width) + (x * buttonSize.width), y * buttonSize.height, buttonSize.width, buttonSize.height);
                UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
                [button addTarget:_delegate action:@selector(emojiButtonTap:) forControlEvents:UIControlEventTouchUpInside];
                [button setTitle:emoji forState:UIControlStateNormal];
                [entry.view addSubview:button];
                [button release];
            }
        }
    }
}

- (void)layoutSubviews
{
    int pagerHeight = 10;
    int toolbarHeight = 30;
    _pageControl.frame = CGRectMake(0, 0, self.frame.size.width, pagerHeight);
    _scrollView.frame = CGRectMake(0, pagerHeight, self.frame.size.width, self.frame.size.height - pagerHeight - toolbarHeight);
    _toolbar.frame = CGRectMake(0, pagerHeight + _scrollView.frame.size.height, self.frame.size.width, toolbarHeight);

    [super layoutSubviews];
}

- (void)backspaceButtonTap:(UIBarButtonItem *)sender
{
    [_delegate backspaceButtonTap:sender];
}

- (void)categoryButtonTap:(UIBarButtonItem *)sender
{
    for (CategoryEntry *entry in self.entries) {
        if (entry.buttonItem == sender) {
            [self switchToCategory:entry];
        }
    }
}

- (void)switchToCategory:(CategoryEntry *)entry
{
    for (CategoryEntry *e in self.entries) {
        [e.view removeFromSuperview];
    }
    [_scrollView addSubview: entry.view];
    _pageControl.numberOfPages = entry.numPages;
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * entry.numPages, _scrollView.frame.size.height);
}

- (void)dealloc
{
    [_scrollView release];
    [_pageControl release];
    [_toolbar release];
    [_backButton release];
    [_entries release];
    [super dealloc];
}

NSString * const _category0 = @"\U0001F604\U0001F60A\U0001F603\U0001F609\U0001F60D\U0001F618\U0001F61A\U0001F633\U0001F60C\U0001F601\U0001F61C\U0001F61D\U0001F612\U0001F60F\U0001F613\U0001F614\U0001F61E\U0001F616\U0001F625\U0001F630\U0001F628\U0001F623\U0001F622\U0001F62D\U0001F602\U0001F632\U0001F631\U0001F620\U0001F621\U0001F62A\U0001F637\U0001F47F\U0001F47D\U0001F49B\U0001F499\U0001F49C\U0001F497\U0001F49A\U0001F494\U0001F493\U0001F498\U0001F31F\U0001F4A2\U0001F4A4\U0001F4A8\U0001F4A6\U0001F3B6\U0001F3B5\U0001F525\U0001F4A9\U0001F44D\U0001F44E\U0001F44C\U0001F44A";

NSString * const _category1 = @"\U0001F4A6\U0001F3B6\U0001F3B5\U0001F525\U0001F4A9\U0001F44D\U0001F44E\U0001F44C\U0001F44A";

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        NSMutableArray *entries = [[NSMutableArray alloc] init];
        for (NSString *chars in [NSArray arrayWithObjects:_category0, _category1, nil]) {
            CategoryEntry *entry = [[CategoryEntry alloc] init];
            entry.chars = chars;
            [entries addObject:entry];
        }
        self.entries = [NSArray arrayWithArray: entries];
        [entries release];
    }
    return self;
}

@end
