//
//  FakeEmojiKeyboardViewController.h
//  EmojiCharades
//
//  Created by Steve Farrell on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FakeEmojiKeyboardView.h"

@interface FakeEmojiKeyboardViewController : UIViewController<FakeEmojiKeyboardDelegate, UIScrollViewDelegate>

- (IBAction)scrollValueChanged:(id)sender;

@property (nonatomic, retain) id<FakeEmojiKeyboardDelegate> delegate;

@end
