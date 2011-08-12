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
@dynamic game;

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
     @"game_id", @"gameID",
     @"user_id", @"userID",
     nil];
    [gameMapping mapRelationship:@"turns" withMapping:mapping];
    [mapping connectRelationship:@"game" withObjectForPrimaryKeyAttribute:@"gameID"];
    [mapping mapRelationship:@"user" withMapping:userMapping];
    [mapping.dateFormatStrings addObject:ECDateFormat];
    [objectManager.mappingProvider registerMapping:mapping withRootKeyPath:@"turn"];
    
    // tweak serialization
    RKObjectMapping *serializationMapping = [objectManager.mappingProvider serializationMappingForClass:ECTurn.class];
    [serializationMapping removeMappingForKeyPath:@"user"];
    [serializationMapping removeMappingForKeyPath:@"userID"];
    [serializationMapping removeMappingForKeyPath:@"gameID"];
    [serializationMapping mapKeyPath:@"user.userID" toAttribute:@"user_id"];
    [serializationMapping mapKeyPath:@"game.gameID" toAttribute:@"game_id"];
}


+ (void) setupObjectRouter:(RKObjectRouter *)objectRouter {
    [objectRouter routeClass:ECTurn.class toResourcePath:@"/game/(game.gameID)/turn" forMethod:RKRequestMethodPOST];
    [objectRouter routeClass:ECTurn.class toResourcePath:@"/game/(game.gameID)/turn/(turnID)"];
}

@end
