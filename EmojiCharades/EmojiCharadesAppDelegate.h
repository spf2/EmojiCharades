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

@interface EmojiCharadesAppDelegate : NSObject <UIApplicationDelegate, RKManagedObjectStoreDelegate> {
    int numDataLayerErrors;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) RKObjectManager *objectManager;
@property (nonatomic, copy) NSString *serviceURL;
@property (copy) NSString *apsToken;

- (void)showError: (NSString *)message;
- (void)configure;

@end
