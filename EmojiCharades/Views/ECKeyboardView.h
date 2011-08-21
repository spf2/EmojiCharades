//
//  ECKeyboardView.h
//  EmojiCharades
//
//  Created by Steve Farrell on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ECKeyboardDelegate
- (void)emojiButtonTap:(UIButton *)emojiButton;
- (void)backspaceButtonTap:(UIBarButtonItem *)backspaceButton;
@end


@interface CategoryEntry : NSObject;

@property (nonatomic, copy) NSString* chars;
@property (nonatomic, retain) UIView* view;
@property (nonatomic, assign) int numPages;
@property (nonatomic, retain) UIBarButtonItem *buttonItem;

@end


@interface ECKeyboardView : UIView;

@property (nonatomic, retain) id<ECKeyboardDelegate> delegate;
@property (nonatomic, retain) NSArray *entries;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;

- (void)initialize;

@end
