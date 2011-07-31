//
//  EmojiCharadesAppDelegate.m
//  EmojiCharades
//
//  Created by Steve Farrell on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EmojiCharadesAppDelegate.h"

#import "RootViewController.h"
#import "SetupViewController.h"
#import "SMXMLDocument.h"

@implementation EmojiCharadesAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize navigationController = _navigationController;
@synthesize receivedData;
@synthesize urlConnection;
@synthesize userCache;
@synthesize dateFormatter;
@synthesize serviceURL;
@synthesize userName;

NSString * const DateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DateFormat];
    [self configure];
    return YES;
}

- (void)configure
{
    NSString *bundlePath = [[NSBundle mainBundle] 
                            pathForResource:@"Info" 
                            ofType:@"plist"];
    NSDictionary *properties = [NSDictionary dictionaryWithContentsOfFile:bundlePath];
    self.serviceURL = [properties valueForKey:@"Service URL"];
    self.userName = [properties valueForKey:@"User Name"];
}

- (BOOL)needsSetup
{
    return self.userName == nil;
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

- (void)tryToSetUserName:(NSString *)userName notify:(id<UserSetupDelegate>) delegate {

}


- (void)populateGames
{
    
    NSString *uri = [NSString stringWithFormat:@"%@/game.xml", self.serviceURL];
    NSURLRequest *request = [NSURLRequest 
                             requestWithURL:[NSURL URLWithString:uri]
                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                             timeoutInterval:60.0];
    urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (urlConnection) {
        receivedData = [[NSMutableData data] retain];
    } else {
        NSLog(@"Could not fetch data from: %@", request.URL);
        [self showError:@"Could not fetch data"];
    }
}

- (void) mergeDataFromService
{    
    NSError *error;
    NSMutableDictionary *currentGames = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *currentUsers = [[NSMutableDictionary alloc] init];
    SMXMLDocument *document = [SMXMLDocument documentWithData:receivedData error:&error];
    for (SMXMLElement *gameElem in [document.root childrenNamed:@"game"]) {
        NSString *gameId = [[gameElem childNamed:@"id"] value];
        [currentGames setObject:gameElem forKey:gameId];
        NSString *userId = [[gameElem childNamed:@"owner-id"] value];
        [currentUsers setObject:[gameElem childNamed:@"owner"] forKey:userId];
        for (SMXMLElement *turnElem in [[gameElem childNamed:@"turns"] childrenNamed:@"turn"]) {
            NSString *turnUserId = [[turnElem childNamed:@"user-id"] value];
            [currentUsers setObject:[turnElem childNamed:@"user"] forKey:turnUserId];
        }
    }
    NSLog(@"%d games, %d users from server", [currentGames count], [currentUsers count]);
    
    NSManagedObjectContext *context = [self managedObjectContext];
    [context lock];
    NSEntityDescription *userEntity = [NSEntityDescription 
                                       entityForName:@"User"
                                       inManagedObjectContext:context];
    NSEntityDescription *gameEntity = [NSEntityDescription 
                                       entityForName:@"Game"
                                       inManagedObjectContext:context];
    
    self.userCache = [[NSMutableDictionary alloc] init];
    [self performMerge:currentUsers withEntity:userEntity];
    [self performMerge:currentGames withEntity:gameEntity];
    [self.userCache removeAllObjects];
    
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        [self showError:@"Couldn't save"];
    }
    [context unlock];
}

- (void) performMerge:(NSMutableDictionary *)currentDict
           withEntity:(NSEntityDescription *)entity
{
    BOOL isGame = [[entity name] isEqualToString:@"Game"];
    NSInteger numSkipped = 0, numUpdated = 0, numCreated = 0;
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError* error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id IN %@", [currentDict allKeys]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjs = [context executeFetchRequest:fetchRequest error:&error];
    NSEnumerator *fetchedObjsEnum = fetchedObjs.objectEnumerator;
    NSManagedObject *fetchedObj;
    while ((fetchedObj = fetchedObjsEnum.nextObject)) {
        NSString *objId = [[fetchedObj valueForKey:@"id"] stringValue];
        SMXMLElement *serverElem = [currentDict objectForKey:objId];
        NSString *serverUpdatedAtStr = [[serverElem childNamed:@"updated-at"] value];
        NSDate *serverUpdatedAt = [dateFormatter dateFromString:serverUpdatedAtStr];
        NSDate *fetchedUpdatedAt = [fetchedObj valueForKey:@"updated_at"];
        NSComparisonResult result = [serverUpdatedAt compare:fetchedUpdatedAt];
        if (result != NSOrderedSame) {
            if (isGame) {
                [self saveGame:serverElem gameObj:fetchedObj];
            } else {
                [self saveUser:serverElem userObj:fetchedObj];
            }
            numUpdated++;
        } else {
            numSkipped++;
        }
        [currentDict removeObjectForKey:objId]; 
    }
    
    NSEnumerator *currentElemEnum = [currentDict objectEnumerator];
    SMXMLElement *currentElem;
    while (currentElem = [currentElemEnum nextObject]) {
        if (isGame) {
            [self saveGame:currentElem gameObj:NULL];
        } else {
            [self saveUser:currentElem userObj:NULL];
        }
        numCreated++;
    }
    NSLog(@"%@ skipped: %d updated: %d created: %d", 
          [entity name], numSkipped, numUpdated, numCreated);
}

- (void) saveGame:(SMXMLElement *)gameElem gameObj:(NSManagedObject *)game
{
    NSManagedObjectContext *context = self.managedObjectContext;
    if (!game) {
        game = [NSEntityDescription
                insertNewObjectForEntityForName:@"Game" 
                inManagedObjectContext:context];
    }
    [game setValue:[[gameElem childNamed:@"hint"] value] forKey:@"hint"];
    [game setValue:[dateFormatter dateFromString:[[gameElem childNamed:@"updated-at"] value]] 
            forKey:@"updated_at"];
    [game setValue:[dateFormatter dateFromString:[[gameElem childNamed:@"created-at"] value]]
            forKey:@"created_at"];
    NSString *doneAtStr = [[gameElem childNamed:@"done-at"] value];
    if (doneAtStr) {
        [game setValue:[dateFormatter dateFromString:doneAtStr] forKey:@"done_at"];
    }
    NSString *gameId = [[gameElem childNamed:@"id"] value];
    [game setValue:[NSNumber numberWithInteger:[gameId integerValue]] forKey:@"id"];
    NSManagedObject *user = [self.userCache objectForKey:[[gameElem childNamed:@"owner-id"] value]];
    [game setValue:user forKey:@"owner"];
    NSSet *turns = [game valueForKey:@"turns"];
    NSMutableSet *turnIds = [[NSMutableSet alloc] init];
    NSEnumerator *turnsEnum = [turns objectEnumerator];
    NSManagedObject *turn;
    while (turn = [turnsEnum nextObject]) {
        [turnIds addObject:[turn valueForKey:@"id"]];
    }
    
    for (SMXMLElement *turnElem in [gameElem childrenNamed:@"turn"]) {
        NSString *turnId = [[turnElem childNamed:@"id"] value];
        if ([turnIds containsObject:turnId]) continue;
        NSManagedObject *turn = [NSEntityDescription
                                 insertNewObjectForEntityForName:@"Turn" 
                                 inManagedObjectContext:context];
        [turn setValue:[NSNumber numberWithInteger:[turnId integerValue]] forKey:@"id"];
        [turn setValue:[[turnElem childNamed:@"guess"] value] forKey:@"guess"];
        [turn setValue:[dateFormatter dateFromString:[[turnElem childNamed:@"updated-at"] value]] forKey:@"updated_at"];
        [turn setValue:[dateFormatter dateFromString:[[turnElem childNamed:@"created-at"] value]] forKey:@"created_at"];
        user = [self.userCache objectForKey:[[turnElem childNamed:@"user-id"] value]];
        [turn setValue:user forKey:@"user"];
        [turn setValue:game forKey:@"game"];
    }
}

- (void) saveUser: (SMXMLElement *)userElem userObj:(NSManagedObject *)user
{
    NSManagedObjectContext *context = [self managedObjectContext];
    if (!user) {
        user = [NSEntityDescription
                insertNewObjectForEntityForName:@"User" 
                inManagedObjectContext:context];
    }
    [user setValue:[[userElem childNamed:@"name"] value] forKey:@"name"];
    [user setValue:[dateFormatter dateFromString:[[userElem childNamed:@"updated-at"] value]]
            forKey:@"updated_at"];
    [user setValue:[dateFormatter dateFromString:[[userElem childNamed:@"created-at"] value]]
            forKey:@"created_at"];
    NSString *userId = [[userElem childNamed:@"id"] value];
    [user setValue:[NSNumber numberWithInteger:[userId integerValue]] forKey:@"id"];
    [self.userCache setObject:user forKey:userId];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response
{
    [receivedData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData: (NSData *)data
{
    [receivedData appendData:data];     
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog( @"Succeeded! Received %d bytes of data", [receivedData length] );
    [self mergeDataFromService];
    [urlConnection release];
    [receivedData release];
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
    [self saveContext];
}

- (void)dealloc
{
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [_navigationController release];
    [super dealloc];
}

- (void)awakeFromNib
{
    RootViewController *rootViewController = (RootViewController *)[self.navigationController topViewController];
    rootViewController.managedObjectContext = self.managedObjectContext;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"EmojiCharades" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"EmojiCharades.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error - deleting store %@, %@", error, [error userInfo]);
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
