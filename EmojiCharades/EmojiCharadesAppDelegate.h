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

@class ECUser;
@class Facebook;

@interface EmojiCharadesAppDelegate : NSObject <UIApplicationDelegate, RKManagedObjectStoreDelegate, FBSessionDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) RKObjectManager *objectManager;
@property (nonatomic, copy) NSString *serviceURL;
@property (nonatomic, readonly) BOOL ready;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, copy) NSString *apsToken;
@property (nonatomic, retain) id<FBSessionDelegate> fbSessionDelegate;

- (void)refreshCurrentView;

@end
