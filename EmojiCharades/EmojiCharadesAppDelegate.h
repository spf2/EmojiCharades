//
//  EmojiCharadesAppDelegate.h
//  EmojiCharades
//
//  Created by Steve Farrell on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMXMLDocument.h"


@interface EmojiCharadesAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, assign) NSMutableData *receivedData;
@property (nonatomic, assign) NSURLConnection *urlConnection;
@property (nonatomic, assign) NSMutableDictionary *userCache;
@property (nonatomic, assign) NSDateFormatter *dateFormatter;
@property (nonatomic, copy) NSString *serviceURL;
@property (nonatomic, copy) NSString *userName;

- (void)showError: (NSString *)message;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)configure;
- (BOOL)needsSetup;
//- (void)tryToSetUserName:(NSString *)userName notify:(id<SetupUserDelegate>) delegate;


@end
