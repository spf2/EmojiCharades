//
//  ECUser.m
//  EmojiCharades
//
//  Created by Steve Farrell on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECUser.h"
#import "Constants.h"

@implementation ECUser

@dynamic userID;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic name;

+ (void)setupMappingWithObjectManager:(RKObjectManager *)objectManager {
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForEntityWithName:@"ECUser"];
    mapping.primaryKeyAttribute = @"userID";
    [mapping mapKeyPath:@"id" toAttribute:@"userID"];
    [mapping mapAttributes:@"name", nil];
    [mapping mapKeyPathsToAttributes:@"created_at", @"createdAt",
     @"updated_at", @"updatedAt",
     nil];
    [mapping.dateFormatStrings addObject:ECDateFormat];
    [objectManager.mappingProvider registerMapping:mapping withRootKeyPath:@"user"];
}

@end
