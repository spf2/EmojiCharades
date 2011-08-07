//
//  PlayGameController.m
//  EmojiCharades
//
//  Created by Steve Farrell on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayGameController.h"

@implementation PlayGameController
@synthesize hintLabel;
@synthesize metadataLabel;
@synthesize turnTableView;
@synthesize guessTextField;
@synthesize guessButton;
@synthesize game;

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
    if (theTextField == self.guessTextField) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    hintLabel.text = game.hint;
    metadataLabel.text = [NSString stringWithFormat:@"%@ at %@", game.owner.name, game.createdAt];
}

- (void)viewDidUnload
{
    [self setHintLabel:nil];
    [self setTurnTableView:nil];
    [self setGuessTextField:nil];
    [self setGuessButton:nil];
    [self setMetadataLabel:nil];
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
    [hintLabel release];
    [turnTableView release];
    [guessTextField release];
    [guessButton release];
    [metadataLabel release];
    [super dealloc];
}
@end
