//
//  ECGame.h
//  EmojiCharades
//
//  Created by Steve Farrell on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "ECUser.h"

@interface ECGame : NSManagedObject

@property (nonatomic, retain) NSNumber *gameID;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSDate *doneAt;
@property (nonatomic, retain) NSString *hint;
@property (nonatomic, retain) ECUser *owner;
@property (nonatomic, retain) NSArray *turns;

+ (void)setupMappingWithObjectManager:(RKObjectManager *)objectManager;
+ (void) setupObjectRouter:(RKObjectRouter *)objectRouter;

@end
