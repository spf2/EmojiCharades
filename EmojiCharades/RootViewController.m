//
//  RootViewController.m
//  EmojiCharades
//
//  Created by Steve Farrell on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayGameController.h"
#import "RootViewController.h"
#import "ECGame.h"
#import "Constants.h"
#import "ECGameCellView.h"

@interface RootViewController ()
- (void)configureCell:(ECGameTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation RootViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize createGameController = _createGameController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _gameRequestInFlight = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIBarButtonItem *createButton = [[UIBarButtonItem alloc] initWithTitle:@"New Game" style:UIBarButtonItemStyleBordered target:self action:@selector(showCreateGame)];
    self.navigationItem.rightBarButtonItem = createButton;
    self.navigationItem.title = @"Emojinary";
    [createButton release];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    [[self refreshTableView] setRefreshHeaderEnabled:YES];
    [[self refreshTableView] setRefreshDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // refresh
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (YKUIRefreshTableView *)refreshTableView {
  return (YKUIRefreshTableView *)self.tableView;
}

- (void)refreshData
{
    [[self refreshTableView] setRefreshing:YES];
    if (!_gameRequestInFlight) {
        _gameRequestInFlight = YES;
        [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/game" delegate:self];
    }
}

#pragma mark Delegates (YKUIRefreshTableView)

- (void)refreshTableViewShouldRefresh:(YKUIRefreshTableView *)refreshTableView {
  [self refreshData];
}

#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
  [[self refreshTableView] setRefreshing:NO];
    _gameRequestInFlight = NO;
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastUpdatedAt"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"Games loaded ok: %d", [objects count]);
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
  [[self refreshTableView] setRefreshing:NO];
    _gameRequestInFlight = NO;
	UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Error" 
                                                     message:[error localizedDescription] 
                                                    delegate:nil 
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[alert show];
	NSLog(@"Hit error: %@", error);
}

- (void)showCreateGame {
    self.createGameController = [[[CreateGameController alloc]
                                  initWithNibName:@"CreateGameController" bundle:nil] autorelease];
    [_createGameController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    _createGameController.delegate = self;
    [self presentModalViewController:_createGameController animated:YES];
}

- (void) gameCreatedOk:(ECGame *)game {
    [self dismissModalViewControllerAnimated:YES];
}

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ECGameTableViewCell";
    
    ECGameTableViewCell *cell = (ECGameTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ECGameTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECGame *game = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return game.owner == [ECUser selfUser] && game.turns.count == 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[RKObjectManager sharedManager] deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath] delegate:self];
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
  return [cell sizeThatFits:CGSizeMake(tableView.frame.size.width, FLT_MAX)].height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayGameController *playGameController = [[PlayGameController alloc] initWithNibName:@"PlayGameController" bundle:nil];
    ECGame *game = [self.fetchedResultsController objectAtIndexPath:indexPath];
    playGameController.game = game;
    [self.navigationController pushViewController:playGameController animated:YES];
    [playGameController release];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [(YKUIRefreshTableView *)self.tableView scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  [(YKUIRefreshTableView *)self.tableView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [_fetchedResultsController release];
    [super dealloc];
}

- (void)configureCell:(ECGameTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ECGame *game = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  // TODO(steve): Need a valid Facebook id for the picture
  NSString *userImageURLString = (game.owner.facebookID ? [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", game.owner.facebookID] : nil);
    
    if (game.doneAt) {        
      NSString *status = [NSString stringWithFormat:@"✓ %@ (%@ got it!)", game.winningTurn.guess, game.winningTurn.user.name];
      [cell.gameCellView setUserName:game.owner.name userImageURLString:userImageURLString lastModifiedDate:game.createdAt hint:game.hint status:status];
    } else {
      NSString *status = [NSString stringWithFormat:@"%@ guess%@", game.numTurns, game.numTurns.intValue == 1 ? @"" : @"es"];
      [cell.gameCellView setUserName:game.owner.name userImageURLString:userImageURLString lastModifiedDate:game.createdAt hint:game.hint status:status];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)insertNewObject
{
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = RKObjectManager.sharedManager.objectStore.managedObjectContext;
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"createdAt"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    /*
     Set up the fetched results controller.
    */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"ECGame"
                                   inManagedObjectContext:RKObjectManager.sharedManager.objectStore.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"createdAt"
                                        ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:RKObjectManager.sharedManager.objectStore.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];

	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(ECGameTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

@end
