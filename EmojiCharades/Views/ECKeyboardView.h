//
//  ECKeyboardView.h
//  EmojiCharades
//
//  Created by Steve Farrell on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryEntry : NSObject;

@property (nonatomic, copy) NSString* chars;
@property (nonatomic, retain) UIView* view;
@property (nonatomic, assign) int numPages;
@property (nonatomic, retain) UIBarButtonItem *buttonItem;

@end

@interface ECKeyboardView : UIView;

@property (nonatomic, retain) NSArray *entries;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *spaceButton;

- (void)layoutKeyboard;

@end

unichar const _category0[7*16], _category1[7*7+4], _category2[7*19+2], _category3[7*10], _category4[7*14+3];

