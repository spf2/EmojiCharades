//
//  ECKeyboardViewController.h
//  EmojiCharades
//
//  Created by Steve Farrell on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECKeyboardView.h"


@protocol ECKeyboardDelegate
- (void)emojiButtonTap:(UIButton *)emojiButton;
- (void)backspaceButtonTap:(UIBarButtonItem *)sender;
- (void)spaceButtonTap:(UIBarButtonItem *)sender;
@end

@interface ECKeyboardViewController : UIViewController<UIScrollViewDelegate>

- (IBAction)scrollValueChanged:(id)sender;

@property (nonatomic, retain) id<ECKeyboardDelegate> delegate;
@property (nonatomic, retain) ECKeyboardView *kbdView;

@end
