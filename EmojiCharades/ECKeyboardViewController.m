//
//  ECKeyboardViewController.m
//  EmojiCharades
//
//  Created by Steve Farrell on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECKeyboardViewController.h"
#import "ECKeyboardView.h"

@implementation ECKeyboardViewController

@synthesize delegate = _delegate;

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
    ECKeyboardView *kbdView = (ECKeyboardView *)self.view;
    kbdView.delegate = self;
    kbdView.scrollView.delegate = self;
    [kbdView initialize];
    [super viewDidLoad];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender 
{
    ECKeyboardView *kbdView = (ECKeyboardView *)self.view;
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = kbdView.scrollView.frame.size.width;
    int page = floor((kbdView.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    kbdView.pageControl.currentPage = page;
}

- (void)scrollValueChanged:(id)sender
{
    ECKeyboardView *kbdView = (ECKeyboardView *)self.view;
    int page = kbdView.pageControl.currentPage;
    CGRect rect = CGRectMake(kbdView.scrollView.frame.size.width * page, 0, kbdView.scrollView.frame.size.width, kbdView.scrollView.frame.size.height);
    [kbdView.scrollView scrollRectToVisible:rect animated:YES];
}

- (void)emojiButtonTap:(UIButton *)emojiButton
{
    [_delegate emojiButtonTap:emojiButton];
}

- (void)backspaceButtonTap:(UIBarButtonItem *)backspaceButton
{
    [_delegate backspaceButtonTap:backspaceButton];
}

- (void)dealloc
{
    [super dealloc];
}

@end
