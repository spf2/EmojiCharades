//
//  RootViewController.h
//  EmojiCharades
//
//  Created by Steve Farrell on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootView.h"
#import "RestKit/RestKit.h"
#import "Restkit/CoreData/CoreData.h"
#import "FBConnect.h"
#import "ShowGamesController.h"

@interface RootViewController : UIViewController<RKObjectLoaderDelegate, FBRequestDelegate, FBSessionDelegate>

@property (nonatomic, retain) IBOutlet RootView *rootView;
@property (nonatomic, assign) Facebook *facebook;
@property (nonatomic, retain) ShowGamesController *showGamesController;

@end
