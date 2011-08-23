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

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate,RKObjectLoaderDelegate, CreateGameDelegate> {
    BOOL _gameRequestInFlight;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) CreateGameController *createGameController;

- (void)refreshData;

@end
