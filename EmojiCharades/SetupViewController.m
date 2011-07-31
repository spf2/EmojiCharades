//
//  SetupViewController.m
//  EmojiCharades
//
//  Created by Steve Farrell on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SetupViewController.h"

@implementation SetupViewController

@synthesize doneButton;
@synthesize warningLabel;
@synthesize delegate;
@synthesize userNameTextField;

- (IBAction)userNameDone:(id)sender {
    [delegate addedUserName:userNameTextField.text];
}

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

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.userNameTextField) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

- (void)showWarning:(NSString *)message {
    warningLabel.text = message;
    userNameTextField.text = @"";
}

- (IBAction)userNameEditingDidBegin:(id)sender {
    warningLabel.text = @"";
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setDoneButton:nil];
    [self setWarningLabel:nil];
    [super viewDidUnload];
    self.userNameTextField = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [userNameTextField release];
    [doneButton release];
    [warningLabel release];
    [super dealloc];
}
- (IBAction)userNameChanged:(id)sender {
}
@end
