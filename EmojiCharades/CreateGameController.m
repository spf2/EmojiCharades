//
//  CreateGameController.m
//  EmojiCharades
//
//  Created by Steve Farrell on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CreateGameController.h"
#import <QuartzCore/QuartzCore.h>

@implementation CreateGameController

@synthesize doneButton = _doneButton;
@synthesize hintTextView = _hintTextView;
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

- (BOOL)textFieldShouldReturn:(id)sender {
    if (sender == _hintTextView) {
        [self createGameDone:sender];
    }
    return YES;
}

- (IBAction)createGameDone:(id)sender {
    if ([_hintTextView.text length] > 0) {
        ECGame* newGame = [ECGame object];
        newGame.hint = [_hintTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        newGame.updatedAt = newGame.createdAt = [NSDate date];
        newGame.owner = [ECUser selfUser];
        [[RKObjectManager sharedManager] postObject:newGame delegate:self];
    }
    [_hintTextView resignFirstResponder];
}

- (IBAction)createGameCancel:(id)sender {
    _hintTextView.text = @"";
    [_delegate gameCreatedOk: nil];
}


#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)game {
    [_delegate gameCreatedOk:game];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
	NSLog(@"Hit error: %@", error);
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:@"Error" 
                          message:@"Error saving game" 
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
    _hintTextView.layer.cornerRadius = 5;
    _hintTextView.clipsToBounds = YES;
}

- (void)viewDidUnload
{
    [self setHintTextView:nil];
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
    [_doneButton release];
    [_hintTextView release];
    [super dealloc];
}
@end
