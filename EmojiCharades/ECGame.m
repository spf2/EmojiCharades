//
//  ECGame.m
//  EmojiCharades
//
//  Created by Steve Farrell on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECGame.h"
#import "ECTurn.h"
#import "Constants.h"

@implementation ECGame

@dynamic gameID;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic doneAt;
@dynamic hint;
@dynamic owner;
@dynamic turns;

+ (void)setupMappingWithObjectManager:(RKObjectManager *)objectManager {
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForEntityWithName:@"ECGame"];
    mapping.primaryKeyAttribute = @"gameID";
    [mapping mapKeyPath:@"id" toAttribute:@"gameID"];
    [mapping mapAttributes:@"hint", nil];
    [mapping mapKeyPathsToAttributes:@"created_at", @"createdAt",
     @"updated_at", @"updatedAt",
     @"done_at", @"doneAt",
     nil];
    [mapping mapRelationship:@"owner" withMapping:[RKObjectMapping mappingForClass:ECUser.class]];
    [mapping hasMany:@"turns" withMapping:[RKObjectMapping mappingForClass:ECTurn.class]];
    [mapping.dateFormatStrings addObject:ECDateFormat];
    [objectManager.mappingProvider registerMapping:mapping withRootKeyPath:@"game"];
}

@end
