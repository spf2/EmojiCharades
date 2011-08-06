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

+ (RKManagedObjectMapping *)setupMappingWithObjectManager:(RKObjectManager *)objectManager;
+ (void)setupObjectRouter:(RKObjectRouter *)objectRouter;

@end
