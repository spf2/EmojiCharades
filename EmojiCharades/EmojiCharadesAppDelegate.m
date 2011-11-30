//
//  EmojiCharadesAppDelegate.m
//  EmojiCharades
//
//  Created by Steve Farrell on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EmojiCharadesAppDelegate.h"
#import "RootViewController.h"

#import "ECUser.h"
#import "ECGame.h"
#import "ECTurn.h"
#import "Constants.h"

@interface EmojiCharadesAppDelegate (PrivateMethods)
- (void)initializeDataLayer;
- (void)showMessage:(NSString *)message;
- (void)showError:(NSError *)error;
- (void)configure;
@end

@implementation EmojiCharadesAppDelegate

@synthesize objectManager = _objectManager;
@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize serviceURL = _serviceURL;
@synthesize facebook = _facebook;
@synthesize apsToken = _apsToken;
@synthesize fbSessionDelegate = _fbSessionDelegate;
@dynamic ready;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    [self configure];
    
    [self initializeDataLayer];
    
    // Start visuals
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)configure
{
    NSString *bundlePath = [[NSBundle mainBundle] 
                            pathForResource:@"Info" 
                            ofType:@"plist"];
    NSDictionary *properties = [NSDictionary dictionaryWithContentsOfFile:bundlePath];
    self.serviceURL = [properties valueForKey:@"Service URL"];
    
#if TARGET_IPHONE_SIMULATOR
    self.serviceURL = @"http://localhost:3000";
    // Enable some verbose logging
    //RKLogConfigureByName("RestKit/UI", RKLogLevelTrace);
    //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    //RKLogConfigureByName("RestKit/Network*", RKLogLevelDebug);
#endif
}

- (BOOL)ready
{
    return RKObjectManager.sharedManager.client.username != nil;
}

- (void)initializeDataLayer 
{
    self.objectManager = [RKObjectManager objectManagerWithBaseURL:self.serviceURL];
    [RKClient sharedClient].requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;    
    self.objectManager.serializationMIMEType = RKMIMETypeJSON;
    NSString *databaseName = @"EmojiCharades.sqlite";
    self.objectManager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:databaseName usingSeedDatabaseName:nil managedObjectModel:nil delegate:self];
    
    RKManagedObjectMapping *userMapping = [ECUser setupMappingWithObjectManager:self.objectManager];
    RKManagedObjectMapping *gameMapping = [ECGame setupMappingWithObjectManager:self.objectManager 
                                                                withUserMapping:userMapping];
    [ECTurn setupMappingWithObjectManager:self.objectManager 
                          withUserMapping:userMapping 
                          withGameMapping:gameMapping];
    
    [ECUser setupObjectRouter:self.objectManager.router];
    [ECTurn setupObjectRouter:self.objectManager.router];
    [ECGame setupObjectRouter:self.objectManager.router];
}

- (void)showMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:@"Error" 
                          message:message delegate:nil 
                          cancelButtonTitle:@"Ok" 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];    
}

- (void)showError:(NSError *)error
{
    [self showMessage:[error localizedDescription]];
}

- (void)managedObjectStore:(RKManagedObjectStore *)objectStore didFailToCreatePersistentStoreCoordinatorWithError:(NSError *)error 
{
    NSLog(@"Error with persistent store: %@", [error localizedDescription]);
    [self showError:error];
    [self.objectManager.objectStore deletePersistantStore];
}

- (void)refreshCurrentView
{
    if (self.ready) {
        UIViewController *currentView = [self.navigationController topViewController];
        if ([currentView respondsToSelector:@selector(refreshData)]) {
            [currentView performSelector:@selector(refreshData)];
        }
    }
}

# pragma mark Facebook

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [self.facebook handleOpenURL:url];
}

- (void)fbDidLogin
{
    [[NSUserDefaults standardUserDefaults] setValue:self.facebook.accessToken forKey:@"facebookAccessToken"];
    [[NSUserDefaults standardUserDefaults] setValue:self.facebook.expirationDate forKey:@"facebookExpirationDate"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    [_fbSessionDelegate fbDidLogin];
}

- (void)fbDidLogout
{
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"facebookAccessToken"];
    [_fbSessionDelegate fbDidLogout];
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    NSLog(@"User canceled: %d", cancelled);
    [_fbSessionDelegate fbDidNotLogin:cancelled];
}

#pragma mark - Urban Airship


// See http://mobile.tutsplus.com/tutorials/iphone/ios-sdk_push-notifications_part-2/
- (void)application:(UIApplication*)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    // Convert the token to a hex string and make sure it's all caps
    NSMutableString *tokenString = [NSMutableString stringWithString:[[deviceToken description] uppercaseString]];
    [tokenString replaceOccurrencesOfString:@"<" withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];
    [tokenString replaceOccurrencesOfString:@">" withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];
    [tokenString replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];
    self.apsToken = tokenString;
    
    NSString *urlFormat = @"https://go.urbanairship.com/api/device_tokens/%@";
    NSURL *registrationURL = [NSURL URLWithString:[NSString stringWithFormat:urlFormat, tokenString]];
    NSMutableURLRequest *registrationRequest = [[NSMutableURLRequest alloc] initWithURL:registrationURL];
    [registrationRequest setHTTPMethod:@"PUT"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:registrationRequest delegate:self];
    [connection start];
    
    NSLog(@"Registering for push notifications...");
}

- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    // Check for previous failures
    if ([challenge previousFailureCount] > 0) {
        // We've already tried - something is wrong with our credentials
        NSLog(@"Urban Airship credentials invalid");
        return;
    }
    
    // Send our Urban Airship credentials
    NSURLCredential *airshipCredentials = [NSURLCredential credentialWithUser:@"kqlyyLTxTIenRxYTuMOCvg"
                                                                     password:@"GzJohR-ORbCi0soEAnxBhg"
                                                                  persistence:NSURLCredentialPersistenceNone];
    [[challenge sender] useCredential:airshipCredentials
           forAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:@"Error" 
                          message:[error localizedDescription] 
                          delegate:nil 
                          cancelButtonTitle:@"Ok" 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if ((httpResponse.statusCode / 100) == 2) {
        NSLog(@"We successfully registered for push notifications");
    } else {
        NSLog(@"We failed to register for push notifications");
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle:@"Error" 
                              message:[NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode] 
                              delegate:nil 
                              cancelButtonTitle:@"Ok" 
                              otherButtonTitles:nil];
        [alert show];
        [alert release];    
    }
}

- (void)application:(UIApplication*)application
didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    // Inform the user that registration failed
    NSString* failureMessage = @"There was an error while trying to \
    register for push notifications.";
    UIAlertView* failureAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                           message:failureMessage
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
    [failureAlert show];
    [failureAlert release];
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    // Notify the current view, if it cares.
    UIViewController *currentView = [self.navigationController topViewController];
    if ([currentView respondsToSelector:@selector(applicationWillEnterForeground)]) {
        [currentView performSelector:@selector(applicationWillEnterForeground)];
    }

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
#if !TARGET_IPHONE_SIMULATOR
    // Register for alert notifications
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge];
    //NSDictionary *pushInfo = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];  
#endif
    [application setApplicationIconBadgeNumber:0];
    [self refreshCurrentView];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [_objectManager release];
    [super dealloc];
}

- (void)awakeFromNib
{
    //    RootViewController *rootViewController = (RootViewController *)[self.navigationController topViewController];
}

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
