//
//  RootViewController.m
//  EmojiCharades
//
//  Created by Steve Farrell on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "ShowGamesController.h"

@interface RootViewController (PrivateMethods)
- (void)showGames;
@end

@implementation RootViewController

@synthesize playButtonItem = _playButtonItem;

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

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = _playButtonItem;
    _playButtonItem.target = self;
    _playButtonItem.action = @selector(showGames);
    [self showGames];
}

- (void)showGames
{
    ShowGamesController *showGames = [[ShowGamesController alloc] initWithNibName:@"ShowGamesController" bundle:nil];
    [self.navigationController pushViewController:showGames animated:YES];
    [showGames release];
}

- (void)viewDidUnload
{
    [self setPlayButtonItem:nil];
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
    [playButtonItem release];
    [super dealloc];
}
@end
