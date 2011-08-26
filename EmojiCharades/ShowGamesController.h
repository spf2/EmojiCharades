//
//  RootViewController.h
//  EmojiCharades
//
//  Created by Steve Farrell on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>

#import "CreateGameController.h"
#import "PlayGameController.h"
#import "YKUIRefreshTableView.h"

@interface ShowGamesController : UITableViewController <NSFetchedResultsControllerDelegate, RKObjectLoaderDelegate, CreateGameDelegate, YKUIRefreshTableViewDelegate> {
    BOOL _gameRequestInFlight;
    BOOL _hideSolutions;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) CreateGameController *createGameController;
@property (nonatomic, retain) IBOutlet UISegmentedControl *filterSegmentedControl;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *newGameButton;

- (IBAction)filterChanged:(id)sender;
- (void)refreshData;
- (YKUIRefreshTableView *)refreshTableView;

@end
