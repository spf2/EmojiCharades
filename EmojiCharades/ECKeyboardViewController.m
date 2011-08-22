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
- (void)emojiButtonTapDone:(UIButton *)sender;
- (void)scrollToPage:(int)page;
@end

@implementation ECKeyboardViewController

@synthesize delegate = _delegate;
@synthesize kbdView = _kbdView;

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
            [emojiButton addTarget:self action:@selector(emojiButtonTapDone:) forControlEvents:UIControlEventTouchUpInside];
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
}

- (void)scrollValueChanged:(id)sender
{
    [self scrollToPage:_kbdView.pageControl.currentPage];
}

- (void)scrollToPage:(int)page
{
    CGRect rect = CGRectMake(_kbdView.scrollView.frame.size.width * page, 0, _kbdView.scrollView.frame.size.width, _kbdView.scrollView.frame.size.height);
    [_kbdView.scrollView scrollRectToVisible:rect animated:YES];
}

- (void)categoryButtonTap:(UIBarButtonItem *)sender
{
    for (CategoryEntry *entry in _kbdView.entries) {
        if (entry.buttonItem == sender) {
            [self switchToCategory:entry];
        }
    }
}

- (void)emojiButtonTapDone:(UIButton *)sender
{
    [sender setBackgroundColor:[UIColor clearColor]];
    [_delegate emojiButtonTap:sender];
}

- (void)switchToCategory:(CategoryEntry *)entry
{
    BOOL same = _kbdView.scrollView.subviews.count > 0 && [[_kbdView.scrollView.subviews objectAtIndex:0] isEqual:entry.view];
    for (CategoryEntry *e in _kbdView.entries) {
        [e.view removeFromSuperview];
    }
    [_kbdView.scrollView addSubview: entry.view];
    _kbdView.pageControl.numberOfPages = entry.numPages;
    if (same) {
        [self scrollToPage:0];
    }
    _kbdView.scrollView.contentSize = CGSizeMake(_kbdView.scrollView.frame.size.width * entry.numPages, _kbdView.scrollView.frame.size.height);
}

- (void)dealloc
{
    [_kbdView release];
    [super dealloc];
}

@end
