//
//  ResultController.m
//  EmojiCharades
//
//  Created by Steve Farrell on 8/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResultController.h"
#import "Constants.h"
#import "ECGame.h"
#import "ECTurn.h"

@implementation ResultController

@synthesize hintTextLabel = _hintTextLabel;
@synthesize hintMetadataLabel = _hintMetadataLabel;
@synthesize guessTextLabel = _guessTextLabel;
@synthesize guessMetadataLabel = _guessMetadataLabel;
@synthesize rightButton = _rightButton;
@synthesize wrongButton = _wrongButton;
@synthesize turn = _turn;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)rightButtonPressed:(id)sender 
{
    _turn.result = [NSNumber numberWithInt:ECResultRight];
    _turn.game.winningTurn = _turn;
    [[RKObjectManager sharedManager] putObject:_turn delegate:self];
}

- (void)wrongButtonPressed:(id)sender
{
    _turn.result = [NSNumber numberWithInt:ECResultWrong];
    [[RKObjectManager sharedManager] putObject:_turn delegate:self];
}


#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
    [_delegate resultOk:_turn];
}


- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _hintTextLabel.text = _turn.game.hint;
    _guessTextLabel.text = _turn.guess;
}

- (void)viewDidUnload
{
    [self setHintTextLabel:nil];
    [self setHintMetadataLabel:nil];
    [self setGuessTextLabel:nil];
    [self setGuessMetadataLabel:nil];
    [self setRightButton:nil];
    [self setWrongButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_hintTextLabel release];
    [_hintMetadataLabel release];
    [_guessTextLabel release];
    [_guessMetadataLabel release];
    [_rightButton release];
    [_wrongButton release];
    [super dealloc];
}
 
@end
