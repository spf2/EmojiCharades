//
//  CreateGameController.h
//  EmojiCharades
//
//  Created by Steve Farrell on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <RestKit/CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "ECKeyboardViewController.h"

@class CreateGameView;
@class ECGame;
@class ECUser;

@protocol CreateGameDelegate
// Game will be null if canceled
- (void) gameCreatedOk:(ECGame *)game;
@end

@interface CreateGameController : UIViewController <UITextFieldDelegate, RKObjectLoaderDelegate, ECKeyboardDelegate> {
    ECKeyboardViewController *_emojiKeyboard;
}
 
- (IBAction)createGameDone:(id)sender;
- (IBAction)createGameCancel:(id)sender;

@property (nonatomic, retain) IBOutlet CreateGameView *createGameView;
@property (nonatomic, retain) id<CreateGameDelegate> delegate;
@property (nonatomic, retain) IBOutlet ECKeyboardViewController *emojiKeyboard;

@end
