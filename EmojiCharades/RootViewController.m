//
//  RootViewController.m
//  EmojiCharades
//
//  Created by Steve Farrell on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "Constants.h"
#import "EmojiCharadesAppDelegate.h"
#import "FBConnect.h"
#import <RestKit/RestKit.h>

@interface RootViewController (PrivateMethods)
- (void)showGames;
- (void)initializeIdentity;
- (void)initializeAuthentication;
- (void)facebookButtonTap:(UIButton *) button;
@end

@implementation RootViewController

@synthesize rootView = _rootView;
@synthesize showGamesController = _showGamesController;
@dynamic facebook;

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


- (void)initializeAuthentication
{
    ECUser *user = ECUser.selfUser;
    if (user.userID) {
        RKObjectManager *om = [RKObjectManager sharedManager];
        om.client.username = [NSString stringWithFormat:@"%@", user.userID];
        om.client.password = user.facebookAccessToken;
        om.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    }
}

- (void)facebookButtonTap:(UIButton *)button
{
    if (self.facebook.isSessionValid) {
        EmojiCharadesAppDelegate *app = (EmojiCharadesAppDelegate *)[[UIApplication sharedApplication] delegate];
        [self.facebook logout:app];
    } else {
        NSArray *permissions = [NSArray arrayWithObjects:@"offline_access", nil];
        [self.facebook authorize:permissions];        
    }
}

#pragma mark Facebook

- (Facebook *)facebook
{
    EmojiCharadesAppDelegate *app = (EmojiCharadesAppDelegate *)[[UIApplication sharedApplication] delegate];
    return app.facebook;
}

- (void)setFacebook:(Facebook *)facebook
{
    EmojiCharadesAppDelegate *app = (EmojiCharadesAppDelegate *)[[UIApplication sharedApplication] delegate];
    app.facebook = facebook;
}

- (void)initializeIdentity
{
    EmojiCharadesAppDelegate *app = (EmojiCharadesAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.facebook = [[Facebook alloc] initWithAppId:ECFacebookAppID andDelegate:app];
    self.facebook.accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"facebookAccessToken"];
    self.facebook.expirationDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"facebookExpirationDate"];
    if (self.facebook.isSessionValid && [ECUser selfUser]) {
        [_rootView.facebookButton setTitle:@"Sign out of Facebook" forState:UIControlStateNormal];
        [self showGames];
    } else {
        _rootView.playButtonItem.enabled = NO;
    }
}


- (void)showGames
{
    [self.navigationController pushViewController:_showGamesController animated:YES];
}


- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Error with facebook: %@", [error localizedDescription]);
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:@"Error" 
                          message:[error localizedDescription] 
                          delegate:nil 
                          cancelButtonTitle:@"Ok" 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];    
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    EmojiCharadesAppDelegate *app = (EmojiCharadesAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *resultDict = (NSDictionary *)result;
    ECUser *user = [ECUser selfUser];
    if (!user) {
        user = [ECUser object];
    }
    user.name = [resultDict valueForKey:@"name"];
    user.facebookID = [NSString stringWithFormat:@"%@", [resultDict valueForKey:@"id"]];
    user.facebookAccessToken = self.facebook.accessToken;
    user.updatedAt = user.createdAt = [NSDate date];
    user.apsToken = app.apsToken;
    [[RKObjectManager sharedManager] putObject:user delegate:self];
     _rootView.playButtonItem.enabled = YES;
}

- (void)fbDidLogin
{
    [_rootView.facebookButton setTitle:@"Sign out of Facebook" forState:UIControlStateNormal];
    [self.facebook requestWithGraphPath:@"me" andDelegate:self];
    [_rootView.activityView startAnimating];
    _rootView.facebookButton.enabled = NO;
}

- (void)fbDidLogout
{
    [_rootView.facebookButton setTitle:@"Sign in with Facebook" forState:UIControlStateNormal];
     _rootView.playButtonItem.enabled = NO;
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(ECUser *)user {
    NSLog(@"user setup ok");
    [_rootView.activityView stopAnimating];
    _rootView.facebookButton.enabled = YES;
    [ECUser setSelfUser:user];
    [self initializeAuthentication];
    [self showGames];
    [_showGamesController refreshData];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    NSLog(@"user setup failed %@", [error localizedDescription]);
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:@"Error" 
                          message:[error localizedDescription] 
                          delegate:nil 
                          cancelButtonTitle:@"Ok" 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];    
    [_rootView.activityView stopAnimating];
    _rootView.facebookButton.enabled = YES;
}


#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.showGamesController = [[[ShowGamesController alloc] initWithNibName:@"ShowGamesController" bundle:nil] autorelease];
    self.navigationItem.rightBarButtonItem = _rootView.playButtonItem;
    _rootView.playButtonItem.target = self;
    _rootView.playButtonItem.action = @selector(showGames);
    [_rootView.facebookButton addTarget:self action:@selector(facebookButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    EmojiCharadesAppDelegate *app = (EmojiCharadesAppDelegate *)[[UIApplication sharedApplication] delegate];
    app.fbSessionDelegate = self;
    [self initializeAuthentication];
    [self initializeIdentity];
}

- (void)viewDidUnload
{
    [self setRootView:nil];
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
    [_rootView release];
    [super dealloc];
}
@end
