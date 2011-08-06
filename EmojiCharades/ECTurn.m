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

+ (void)setupMappingWithObjectManager:(RKObjectManager *)objectManager 
                      withUserMapping:(RKObjectMapping *)userMapping 
                      withGameMapping:(RKObjectMapping *)gameMapping {
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForClass:ECTurn.class];
    mapping.primaryKeyAttribute = @"turnID";
    [mapping mapKeyPathsToAttributes:@"id", @"turnID",
     @"guess", @"guess",
     @"result", @"result", 
     @"created_at", @"createdAt",
     @"updated_at", @"updatedAt",
     nil];
    [mapping mapRelationship:@"user" withMapping:userMapping];
    [mapping mapRelationship:@"game" withMapping:gameMapping];
    [mapping.dateFormatStrings addObject:ECDateFormat];
    [objectManager.mappingProvider registerMapping:mapping withRootKeyPath:@"turn"];
}


+ (void) setupObjectRouter:(RKObjectRouter *)objectRouter {
    [objectRouter routeClass:ECTurn.class toResourcePath:@"/turn/(turnID)"];
}

@end
