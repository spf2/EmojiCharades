//
//  ResultController.m
//  EmojiCharades
//
//  Created by Steve Farrell on 8/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResultController.h"
#import "Constants.h"

@implementation ResultController

@synthesize hintTextLabel;
@synthesize hintMetadataLabel;
@synthesize guessTextLabel;
@synthesize guessMetadataLabel;
@synthesize rightButton;
@synthesize wrongButton;
@synthesize turn;
@synthesize delegate;

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
    turn.result = [NSNumber numberWithInt:ECResultRight];
    [[RKObjectManager sharedManager] putObject:turn delegate:self];
}

- (void)wrongButtonPressed:(id)sender
{
    turn.result = [NSNumber numberWithInt:ECResultWrong];
    [[RKObjectManager sharedManager] putObject:turn delegate:self];
}


#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
    [delegate resultOk:turn];
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
    
    hintTextLabel.text = turn.game.hint;
    guessTextLabel.text = turn.guess;
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
    [hintTextLabel release];
    [hintMetadataLabel release];
    [guessTextLabel release];
    [guessMetadataLabel release];
    [rightButton release];
    [wrongButton release];
    [super dealloc];
}

@end
