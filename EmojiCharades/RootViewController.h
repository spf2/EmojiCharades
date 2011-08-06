//
//  RootViewController.h
//  EmojiCharades
//
//  Created by Steve Farrell on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
#import "SetupViewController.h"
#import "EmojiCharadesAppDelegate.h"
#import <RestKit/RestKit.h>

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate,RKObjectLoaderDelegate, SetupViewDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) EmojiCharadesAppDelegate *emojiCharadesDelegate;
@property (nonatomic, retain) SetupViewController *setupController;

- (void)userSetup;
- (void)loadGamesFromService;

@end
