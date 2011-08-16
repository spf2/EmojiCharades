//
//  PlayGameController.h
//  EmojiCharades
//
//  Created by Steve Farrell on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECGame.h"
#import "ECTurn.h"
#import "ECUser.h"
#import "ResultController.h"
#import "PlayGameView.h"

@interface PlayGameController : UIViewController<NSFetchedResultsControllerDelegate, RKObjectLoaderDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, ResultControllerDelegate> {
}

@property (nonatomic, retain) IBOutlet PlayGameView *playGameView;
@property (nonatomic, retain) IBOutlet UITableView *turnTableView;
@property (nonatomic, retain) IBOutlet UITextField *guessTextField;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *guessButton;
@property (nonatomic, retain) IBOutlet UIToolbar *guessToolbar;
@property (nonatomic, retain) ECGame *game;

- (void) moveTextViewForKeyboard:(NSNotification*)note up: (BOOL) up;
- (IBAction)guessEditingDidEnd:(id)sender;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (ECTurn *)turnAtIndexPath: (NSIndexPath *)indexPath;

@end
