//
//  EmojiCharadesAppDelegate.m
//  EmojiCharades
//
//  Created by Steve Farrell on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EmojiCharadesAppDelegate.h"

#import "RootViewController.h"
#import "SetupUserController.h"

#import "ECUser.h"
#import "ECGame.h"
#import "ECTurn.h"
#import "Constants.h"

@implementation EmojiCharadesAppDelegate

@synthesize objectManager = _objectManager;
@synthesize window = _window;
@synthesize navigationController = _navigationController;

@synthesize serviceURL;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    [self configure];
    
    // Enable some verbose logging
    RKLogConfigureByName("RestKit/UI", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/Network*", RKLogLevelDebug);

    self.objectManager = [RKObjectManager objectManagerWithBaseURL:self.serviceURL];
    [RKRequestQueue sharedQueue].showsNetworkActivityIndicatorWhenBusy = YES;
    NSString *databaseName = @"EmojiCharades.sqlite";
    
    self.objectManager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:databaseName];
    if (false) {
        [self.objectManager.objectStore deletePersistantStore];
    }

    self.objectManager.serializationMIMEType = RKMIMETypeJSON;
    
    RKObjectMapping *userMapping = [ECUser setupMappingWithObjectManager:self.objectManager];
    RKObjectMapping *gameMapping = [ECGame setupMappingWithObjectManager:self.objectManager 
                                                         withUserMapping:userMapping];
    [ECTurn setupMappingWithObjectManager:self.objectManager 
                          withUserMapping:userMapping 
                          withGameMapping:gameMapping];

    [ECUser setupObjectRouter:self.objectManager.router];
    [ECTurn setupObjectRouter:self.objectManager.router];
    [ECGame setupObjectRouter:self.objectManager.router];
    
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
    
#ifdef DEBUG
    self.serviceURL = @"http://localhost:3000";
#endif
}

- (void)showError:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:@"Error" 
                          message:message delegate:nil 
                          cancelButtonTitle:@"Ok" 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];    
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
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
