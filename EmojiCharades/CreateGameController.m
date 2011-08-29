//
//  CreateGameController.m
//  EmojiCharades
//
//  Created by Steve Farrell on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CreateGameController.h"
#import "Views/CreateGameView.h"
#import "ECGame.h"
#import "ECUser.h"
#import "Constants.h"

@implementation CreateGameController

@synthesize createGameView = _createGameView;
@synthesize delegate = _delegate;
@synthesize emojiKeyboard = _emojiKeyboard;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _emojiKeyboard.delegate = self;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)createGameDone:(id)sender 
{
    NSString *trimmedHint = [_createGameView.hintTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmedHint length] > 0) {
        ECGame* newGame = [ECGame object];
        newGame.hint = trimmedHint;
        newGame.updatedAt = newGame.createdAt = [NSDate date];
        newGame.owner = [ECUser selfUser];
        [[RKObjectManager sharedManager] postObject:newGame delegate:self];
    }
    [_createGameView.hintTextView resignFirstResponder];
}

- (IBAction)createGameCancel:(id)sender 
{
    _createGameView.hintTextView.text = @"";
    [_delegate gameCreatedOk: nil];
}

- (void)insertAtCursor:(NSString *)text
{
    NSRange replaceRange = _createGameView.hintTextView.selectedRange;
    _createGameView.hintTextView.text = [_createGameView.hintTextView.text stringByReplacingCharactersInRange:replaceRange withString:text];
    replaceRange.length = 0;
    replaceRange.location += 1;
    _createGameView.hintTextView.selectedRange = replaceRange;
}

#pragma mark ECKeyboardDelegate methods

- (void)emojiButtonTap:(UIButton *)emojiButton
{
    [self insertAtCursor:emojiButton.titleLabel.text];
}

- (void)backspaceButtonTap:(UIBarButtonItem *)backspaceButton
{
    int len = _createGameView.hintTextView.text.length;
    if (len > 0) {
        NSRange deleteRange = _createGameView.hintTextView.selectedRange;
        if (deleteRange.length == 0) {
            deleteRange.location -= 1;
            deleteRange.length = 1;
        }
        _createGameView.hintTextView.text = [_createGameView.hintTextView.text stringByReplacingCharactersInRange:deleteRange withString:@""];
        deleteRange.length = 0;
        _createGameView.hintTextView.selectedRange = deleteRange;
    }
}

- (void)spaceButtonTap:(UIBarButtonItem *)sender
{
    [self insertAtCursor:ECSeparator];
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
    self.emojiKeyboard = [[[ECKeyboardViewController alloc]
                                  initWithNibName:@"ECKeyboardViewController" bundle:nil] autorelease];
    _emojiKeyboard.delegate = self;
    _createGameView.hintTextView.inputView = _emojiKeyboard.view;
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    _createGameView = nil;
    [self setEmojiKeyboard:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)dealloc {
    [_createGameView release];
    [_emojiKeyboard release];
    [super dealloc];
}
@end
