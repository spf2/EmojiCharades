//
//  ECKeyboardViewController.m
//  EmojiCharades
//
//  Created by Steve Farrell on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECKeyboardViewController.h"
#import "ECKeyboardView.h"

@interface ECKeyboardViewController (PrivateMethods);
- (void)switchToCategory:(CategoryEntry *)entry;
- (void)categoryButtonTap:(UIBarButtonItem *)sender;
- (void)emojiButtonTap:(UIButton *)sender;
- (void)scrollToPage:(int)page animated:(BOOL)animated;
@end

@implementation ECKeyboardViewController

@synthesize delegate = _delegate;
@synthesize kbdView = _kbdView;
@synthesize currentEntry = _currentEntry;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)viewDidLoad
{
    self.kbdView = (ECKeyboardView *)self.view;
    _kbdView.scrollView.delegate = self;
    [_kbdView layoutKeyboard];
    _kbdView.backButton.target = _delegate;
    _kbdView.backButton.action = @selector(backspaceButtonTap:);
    _kbdView.spaceButton.target = _delegate;
    _kbdView.spaceButton.action = @selector(spaceButtonTap:);
    for (CategoryEntry *entry in _kbdView.entries) {
        entry.buttonItem.target = self;
        entry.buttonItem.action = @selector(categoryButtonTap:);
        for (UIButton *emojiButton in entry.view.subviews) {
            [emojiButton addTarget:self action:@selector(emojiButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    [self switchToCategory:[_kbdView.entries objectAtIndex:0]];
    [super viewDidLoad];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender 
{
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _kbdView.scrollView.frame.size.width;
    int page = floor((_kbdView.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _kbdView.pageControl.currentPage = page;
    _currentEntry.currentPage = page;
}

- (void)scrollValueChanged:(id)sender
{
    [self scrollToPage:_kbdView.pageControl.currentPage animated:YES];
}

- (void)scrollToPage:(int)page animated:(BOOL)animated
{
    CGRect rect = CGRectMake(_kbdView.scrollView.frame.size.width * page, 0, _kbdView.scrollView.frame.size.width, _kbdView.scrollView.frame.size.height);
    [_kbdView.scrollView scrollRectToVisible:rect animated:animated];
    _currentEntry.currentPage = page;
}

- (void)categoryButtonTap:(UIBarButtonItem *)sender
{
    for (CategoryEntry *entry in _kbdView.entries) {
        if (entry.buttonItem == sender) {
            [self switchToCategory:entry];
        }
    }
}

- (void)emojiButtonTap:(UIButton *)sender
{
    [_delegate emojiButtonTap:sender];
}

- (void)switchToCategory:(CategoryEntry *)entry
{
    if (entry == _currentEntry) {
        entry.currentPage = 0;
    }
    _currentEntry = nil;
    for (CategoryEntry *e in _kbdView.entries) {
        [e.view removeFromSuperview];
    }
    [_kbdView.scrollView addSubview: entry.view];
    _kbdView.pageControl.numberOfPages = entry.pageCount;
    _kbdView.scrollView.contentSize = CGSizeMake(_kbdView.scrollView.frame.size.width * entry.pageCount, _kbdView.scrollView.frame.size.height);
    _currentEntry = entry;
    [self scrollToPage:entry.currentPage animated:NO];

}

- (void)dealloc
{
    [_kbdView release];
    [super dealloc];
}

@end
