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
#import "ResultController.h"

@interface PlayGameController : UIViewController<NSFetchedResultsControllerDelegate, RKObjectLoaderDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, ResultControllerDelegate> {
}

@property (nonatomic, retain) IBOutlet UILabel *hintLabel;
@property (nonatomic, retain) IBOutlet UILabel *metadataLabel;
@property (nonatomic, retain) IBOutlet UITableView *turnTableView;
@property (nonatomic, retain) IBOutlet UITextField *guessTextField;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *guessButton;
@property (nonatomic, retain) ECGame *game;
@property (nonatomic, retain) IBOutlet UIToolbar *guessToolbar;

- (void) moveTextViewForKeyboard:(NSNotification*)note up: (BOOL) up;
- (IBAction)guessEditingDidEnd:(id)sender;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (ECTurn *)turnAtIndexPath: (NSIndexPath *)indexPath;

@end
