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
#import "SetupUserController.h"

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate,RKObjectLoaderDelegate, SetupUserDelegate, CreateGameDelegate> {
}


@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) SetupUserController *setupController;
@property (nonatomic, retain) CreateGameController *createGameController;

- (void)userSetup;

@end
