//
//  ECTurn.h
//  EmojiCharades
//
//  Created by Steve Farrell on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@class ECGame;
@class ECUser;

@interface ECTurn : NSManagedObject

@property (nonatomic, retain) NSNumber *turnID;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSString *guess;
@property (nonatomic, retain) ECUser *user;
@property (nonatomic, retain) ECGame *game;
@property (nonatomic, retain) NSNumber *result;

+ (void)setupMappingWithObjectManager:(RKObjectManager *)objectManager 
                      withUserMapping:(RKManagedObjectMapping *)userMapping 
                      withGameMapping:(RKManagedObjectMapping *)gameMapping;
+ (void)setupObjectRouter:(RKObjectRouter *)objectRouter;

@end
