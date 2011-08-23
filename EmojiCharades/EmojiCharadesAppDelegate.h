//
//  EmojiCharadesAppDelegate.h
//  EmojiCharades
//
//  Created by Steve Farrell on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestKit/RestKit.h"
#import "Restkit/CoreData/CoreData.h"
#import "FBConnect.h"

@interface EmojiCharadesAppDelegate : NSObject <UIApplicationDelegate, RKManagedObjectStoreDelegate, RKObjectLoaderDelegate, FBSessionDelegate, FBRequestDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) RKObjectManager *objectManager;
@property (nonatomic, copy) NSString *serviceURL;
@property (nonatomic, copy) NSString *apsToken;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, readonly) BOOL ready;

@end
