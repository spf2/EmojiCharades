//
//  ECUser.h
//  EmojiCharades
//
//  Created by Steve Farrell on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@interface ECUser : NSManagedObject

@property (nonatomic, retain) NSNumber *userID;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *apsToken;
@property (nonatomic, retain) NSString *facebookID;
@property (nonatomic, retain) NSString *facebookAccessToken;

+ (RKManagedObjectMapping *)setupMappingWithObjectManager:(RKObjectManager *)objectManager;
+ (void)setupObjectRouter:(RKObjectRouter *)objectRouter;

// Sets a handle the self user.  Assumes that backing object is in Core Data.
+ (void)setSelfUser:(ECUser *)selfUser;

// Fetches the self user, presuming its been set.
+ (ECUser *)selfUser;
+ (ECUser *)userByName:(NSString *)name;

@end
