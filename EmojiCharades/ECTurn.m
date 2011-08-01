//
//  ECTurn.m
//  EmojiCharades
//
//  Created by Steve Farrell on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECTurn.h"
#import "ECUser.h"
#import "Constants.h"

@implementation ECTurn

@dynamic turnID;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic guess;
@dynamic user;
@dynamic result;

+ (void)setupMappingWithObjectManager:(RKObjectManager *)objectManager {
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForEntityWithName:@"ECTurn"];
    mapping.primaryKeyAttribute = @"turnID";
    [mapping mapKeyPath:@"id" toAttribute:@"turnID"];
    [mapping mapAttributes:@"guess", @"result", nil];
    [mapping mapKeyPathsToAttributes:@"created_at", @"createdAt",
     @"updated_at", @"updatedAt",
     nil];
    [mapping mapRelationship:@"user" withMapping:[RKObjectMapping mappingForClass:ECUser.class]];
    [mapping.dateFormatStrings addObject:ECDateFormat];
    [objectManager.mappingProvider registerMapping:mapping withRootKeyPath:@"turn"];
}

@end
