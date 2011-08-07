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

+ (RKManagedObjectMapping *)setupMappingWithObjectManager:(RKObjectManager *)objectManager {
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForClass:ECUser.class];
    mapping.primaryKeyAttribute = @"userID";
    [mapping mapKeyPathsToAttributes:
     @"id", @"userID",
     @"name", @"name",
     @"created_at", @"createdAt",
     @"updated_at", @"updatedAt",
     nil];
    [mapping.dateFormatStrings addObject:ECDateFormat];
    [objectManager.mappingProvider registerMapping:mapping withRootKeyPath:@"user"];
    
    return mapping;
}

+ (void) setupObjectRouter:(RKObjectRouter *)objectRouter {
    [objectRouter routeClass:ECUser.class toResourcePath:@"/user" forMethod:RKRequestMethodPOST];
    [objectRouter routeClass:ECUser.class toResourcePath:@"/user/(userID)"];
}

+ (void) setSelfUser:(ECUser *)selfUser {
    NSString *selfUserURI = selfUser.objectID.URIRepresentation.absoluteString;
    [[NSUserDefaults standardUserDefaults] setValue:selfUserURI forKey:@"selfObjectURI"];
	[[NSUserDefaults standardUserDefaults] synchronize];    
}

+ (ECUser *)selfUser {
    NSString *selfUserURI = [[NSUserDefaults standardUserDefaults] objectForKey:@"selfObjectURI"];
    if (!selfUserURI) return nil;
    NSManagedObjectContext *moc = RKObjectManager.sharedManager.objectStore.managedObjectContext;
    NSManagedObjectID *selfObjectID = [moc.persistentStoreCoordinator managedObjectIDForURIRepresentation: [NSURL URLWithString:selfUserURI]];
    if (!selfObjectID) return nil;
    return (ECUser *)[moc objectWithID:selfObjectID];
}

@end
