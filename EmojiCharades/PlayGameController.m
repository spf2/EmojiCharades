//
//  PlayGameController.m
//  EmojiCharades
//
//  Created by Steve Farrell on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayGameController.h"

#import "ResultController.h"
#import "ECTurn.h"
#import "Constants.h"

@implementation PlayGameController

@synthesize playGameView = _playGameView;
@synthesize game = _game;

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
    if (_game.doneAt) {
        _playGameView.guessTextField.hidden = YES;
    }
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
#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    // Trigger data refresh every time the user goes to, or returns to, this view.
    [[RKObjectManager sharedManager] getObject:_game delegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _playGameView.hintLabel.text = _game.hint;
    _playGameView.metadataLabel.text = [NSString stringWithFormat:@"%@ at %@", _game.owner.name, _game.createdAt];
    _playGameView.guessTextField.hidden = _game.doneAt != nil;
   
    _playGameView.guessTextField.delegate = self;
    _playGameView.turnTableView.dataSource = self;
    _playGameView.turnTableView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidUnload
{
    self.playGameView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark UITableViewDelegate methods

static BOOL userCanGiveResultFor(ECGame *game, ECTurn *turn) {
    return !game.doneAt && 
    (game.owner && game.owner.userID == [ECUser selfUser].userID) && 
    (!turn.result || turn.result.intValue == ECResultNone);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECTurn* turn = [self turnAtIndexPath:indexPath];
    if (userCanGiveResultFor(_game, turn)) {
        ResultController *resultController = [[ResultController alloc] initWithNibName:@"ResultController" bundle:nil];
        resultController.delegate = self;
        resultController.turn = turn;
        [self.navigationController pushViewController:resultController animated:YES];
        [resultController release];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return _game.turns.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    ECTurn* turn = [self turnAtIndexPath:indexPath];
    cell.textLabel.text = turn.guess;
    
    if (turn.result.intValue == ECResultWrong) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ is wrong", turn.user.name];
        cell.detailTextLabel.textColor = [UIColor redColor];
    } else if (turn.result.intValue == ECResultRight) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ is right", turn.user.name];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];        
    } else {
        if (_game.doneAt) {
            cell.detailTextLabel.text = turn.user.name;    
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ at %@", turn.user.name, turn.createdAt];
        }
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    if (userCanGiveResultFor(_game, turn)) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECTurn *turn = [self turnAtIndexPath:indexPath];
    return turn.user == [ECUser selfUser] && [turn.result isEqualToNumber:[NSNumber numberWithInt:ECResultNone]] && !turn.game.doneAt;
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
    [super dealloc];
}
@end
