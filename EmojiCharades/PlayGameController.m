//
//  PlayGameController.m
//  EmojiCharades
//
//  Created by Steve Farrell on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayGameController.h"
#import "NSDate+timeAgo.h"
#import "ResultController.h"
#import "ECTurn.h"
#import "Constants.h"
#import "ECTurnCellView.h"

@interface PlayGameController (PrivateMethods)
-(void)refreshUI;
-(void)refreshData;
@end

@implementation PlayGameController

@synthesize playGameView = _playGameView;
@synthesize game = _game;
@synthesize timer = _timer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == _playGameView.guessTextField) {
        [_playGameView.guessTextField resignFirstResponder];
        ECTurn* newTurn = [ECTurn object];
        newTurn.guess = _playGameView.guessTextField.text;
        newTurn.updatedAt = newTurn.createdAt = [NSDate date];
        newTurn.user = [ECUser selfUser];
        newTurn.game = _game;
        [[RKObjectManager sharedManager] postObject:newTurn delegate:self];
        _playGameView.guessTextField.enabled = NO;
    }
    return YES;
}

-(void) keyboardWillShow:(NSNotification *)note {
    [self moveTextViewForKeyboard:note up:YES];
}

-(void) keyboardWillHide:(NSNotification *)note {
    [self moveTextViewForKeyboard:note up:NO];    
}


// This madness is needed so that the keyboard doesn't obscure the text-entry box.
- (void) moveTextViewForKeyboard:(NSNotification*)note up: (BOOL) up {
    NSDictionary* userInfo = [note userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    // Animate up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newToolbarFrame = _playGameView.guessToolbar.frame;
    CGRect newTableViewFrame = _playGameView.turnTableView.frame;
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    int delta = keyboardFrame.size.height * (up ? 1 : -1);
    
    newTableViewFrame.size.height -= delta;
    newToolbarFrame.origin.y -= delta;
    
    _playGameView.guessToolbar.frame = newToolbarFrame;
    _playGameView.turnTableView.frame = newTableViewFrame;
    
    [UIView commitAnimations];
}

- (IBAction)guessEditingDidEnd:(id)sender {
}

#pragma mark ResultControllerDelegate methods

- (void)resultOk:(ECTurn *)turn
{
    [self.navigationController popViewControllerAnimated:YES];
    [_playGameView.turnTableView reloadData];
}

#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)_ 
{
    _playGameView.guessTextField.enabled = YES;
    _playGameView.guessTextField.text = @"";
    [_playGameView.turnTableView reloadData];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error 
{
    _playGameView.guessTextField.enabled = YES;
	NSLog(@"Hit error: %@", error);
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:@"Error" 
                          message:@"Error saving turn" 
                          delegate:nil 
                          cancelButtonTitle:@"Ok" 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];    
    
}

- (void)refreshData
{
    // Trigger data refresh every time the user goes to, or returns to, this view.
    [[RKObjectManager sharedManager] getObject:_game delegate:self];
    // And reset the timer, triggering a refresh now.
    [self.timer setFireDate:[NSDate date]];

}

- (void)refreshUI
{
    [_playGameView.turnTableView reloadData];
    _playGameView.metadataLabel.text = [NSString stringWithFormat:@"%@ - %@", _game.owner.name, _game.createdAt.timeAgo];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [self refreshData];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    _playGameView.hintLabel.text = _game.hint;
   
    _playGameView.guessTextField.delegate = self;
    _playGameView.turnTableView.dataSource = self;
    _playGameView.turnTableView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if (_timer == nil) {
        self.timer = [NSTimer timerWithTimeInterval:60.f target:self selector:@selector(refreshUI) userInfo:nil repeats:YES];
        NSRunLoop *runner = [NSRunLoop currentRunLoop];
        [runner addTimer:_timer forMode: NSDefaultRunLoopMode];
    }
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self.timer invalidate];
    self.timer = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark UITableViewDelegate methods

static BOOL userCanGiveResultFor(ECGame *game, ECTurn *turn) {
    return (game.owner && game.owner.userID == [ECUser selfUser].userID);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECTurn* turn = [self turnAtIndexPath:indexPath];
    if (userCanGiveResultFor(_game, turn)) {
        _selectedTurn = turn;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:turn.guess delegate:self cancelButtonTitle:@”Cancel” destructiveButtonTitle:nil otherButtonTitles: @"Yup", @"Nope", nil];
        [actionSheet showInView:self.view];
        [actionSheet release];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        _turn.result = [NSNumber numberWithInt:ECResultRight];
        [[RKObjectManager sharedManager] putObject:_turn delegate:self];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return _game.turns.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ECTurnTableViewCell";
    
    ECTurnTableViewCell *cell = (ECTurnTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ECTurnTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(ECTurnTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ECTurn* turn = [self turnAtIndexPath:indexPath];
    cell.textLabel.text = turn.guess;
    
    NSString *userImageURLString = (turn.user.facebookID ? [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",turn.user.facebookID] : nil);
    
    [cell.turnCellView setUserName:turn.user.name userImageURLString:userImageURLString lastModifiedDate:turn.createdAt text:turn.guess 
                            status:turn.result.intValue];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    if (userCanGiveResultFor(_game, turn)) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECTurn *turn = [self turnAtIndexPath:indexPath];
    return turn.user == [ECUser selfUser] && [turn.result isEqualToNumber:[NSNumber numberWithInt:ECResultNone]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[RKObjectManager sharedManager] deleteObject:[self turnAtIndexPath:indexPath] delegate:self];
    }   
}

- (ECTurn *)turnAtIndexPath: (NSIndexPath *)indexPath {
    // TODO this resorts all turns for /each/ row... instead only sort when game changes.
    NSComparator byID = ^(id a, id b) {
        return [[b turnID] compare:[a turnID]];
    };
    NSArray *sorted = [[_game.turns allObjects] sortedArrayUsingComparator:byID];                       
    ECTurn *turn = [sorted objectAtIndex:indexPath.row];
    return turn;
}

- (void)dealloc {
    [_playGameView release];
    [_game release];
    [_timer release];
    [super dealloc];
}
@end
