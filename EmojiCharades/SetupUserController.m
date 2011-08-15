//
//  SetupUserController.m
//  EmojiCharades
//
//  Created by Steve Farrell on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EmojiCharadesAppDelegate.h"
#import "SetupUserController.h"
#import "ECUser.h"

@implementation SetupUserController

@synthesize doneButton;
@synthesize warningLabel;
@synthesize delegate;
@synthesize userNameTextField;

- (IBAction)userNameDone:(id)sender {
    EmojiCharadesAppDelegate *app = (EmojiCharadesAppDelegate *)[[UIApplication sharedApplication] delegate];
    ECUser *user = [ECUser userByName:userNameTextField.text];
    if (user) {
        if (app.apsToken && !user.apsToken) {
            user.apsToken = app.apsToken;
            user.updatedAt = [NSDate date];
            [[RKObjectManager sharedManager] putObject:user delegate:self];
        } else {
            [delegate userSetupOk:user];
        }
    } else {
        user = [ECUser object];
        user.name = userNameTextField.text;
        user.updatedAt = user.createdAt = [NSDate date];
        user.apsToken = app.apsToken;
        [[RKObjectManager sharedManager] postObject:user delegate:self];
    }
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

#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)user {
    [delegate userSetupOk:user];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [self showWarning:@"Already taken; try another."];
	NSLog(@"Hit error: %@", error);
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
