//
//  FakeEmojiKeyboardView.h
//  EmojiCharades
//
//  Created by Steve Farrell on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FakeEmojiKeyboardDelegate
- (void)emojiButtonTap:(UIButton *)emojiButton;
- (void)backspaceButtonTap:(UIBarButtonItem *)backspaceButton;
@end

@interface FakeEmojiKeyboardView : UIView;

@property (nonatomic, retain) id<FakeEmojiKeyboardDelegate> delegate;
@property (nonatomic, retain) NSArray *charPages;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;

@end
