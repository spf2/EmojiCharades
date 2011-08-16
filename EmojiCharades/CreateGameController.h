//
//  CreateGameController.h
//  EmojiCharades
//
//  Created by Steve Farrell on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECGame.h"
#import "ECUser.h"

@protocol CreateGameDelegate
// Game will be null if canceled
- (void) gameCreatedOk:(ECGame *)game;
@end

@interface CreateGameController : UIViewController <UITextFieldDelegate, RKObjectLoaderDelegate> 

- (IBAction)createGameDone:(id)sender;
- (IBAction)createGameCancel:(id)sender;

@property (nonatomic, retain) id<CreateGameDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet UITextView *hintTextView;

@end
