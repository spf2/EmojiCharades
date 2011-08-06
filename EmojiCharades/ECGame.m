//
//  ECGame.m
//  EmojiCharades
//
//  Created by Steve Farrell on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECGame.h"
#import "ECTurn.h"
#import "ECUser.h"
#import "Constants.h"

@implementation ECGame

@dynamic gameID;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic doneAt;
@dynamic hint;
@dynamic owner;
@dynamic turns;

+ (RKObjectMapping *)setupMappingWithObjectManager:(RKObjectManager *)objectManager withUserMapping:(RKManagedObjectMapping *)userMapping {
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForClass:ECGame.class];
    mapping.primaryKeyAttribute = @"gameID";
    [mapping mapKeyPathsToAttributes:@"id", @"gameID",
     @"hint", @"hint",
     @"created_at", @"createdAt",
     @"updated_at", @"updatedAt",
     @"done_at", @"doneAt",
     nil];
    [mapping mapRelationship:@"owner" withMapping:userMapping];
    [mapping.dateFormatStrings addObject:ECDateFormat];
    [objectManager.mappingProvider registerMapping:mapping withRootKeyPath:@"game"];
    return mapping;
}

+ (void) setupObjectRouter:(RKObjectRouter *)objectRouter {    
    [objectRouter routeClass:ECGame.class toResourcePath:@"/game/(gameID)"];
}

@end
