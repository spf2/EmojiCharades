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
@dynamic apsToken;
@dynamic facebookID;

static ECUser* selfUser = nil;

+ (RKManagedObjectMapping *)setupMappingWithObjectManager:(RKObjectManager *)objectManager {
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForClass:ECUser.class];
    mapping.primaryKeyAttribute = @"userID";
    [mapping mapKeyPathsToAttributes:
     @"id", @"userID",
     @"name", @"name",
     @"created_at", @"createdAt",
     @"updated_at", @"updatedAt",
     @"aps_token", @"apsToken",
     @"facebook_id", @"facebookID",
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
    NSNumber *selfID = selfUser.userID;
    [[NSUserDefaults standardUserDefaults] setValue:selfID forKey:@"selfID"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    selfUser = nil;
}

+ (ECUser *)userByPredicate:(NSPredicate *) predicate
{
    NSManagedObjectContext *moc = RKObjectManager.sharedManager.objectStore.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"ECUser" inManagedObjectContext:moc];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error fetching user %@", [error localizedDescription]);
    }
    if ([array count] > 0) {
        return [array objectAtIndex:0];    
    }
    return nil;    
}

+ (ECUser *)userByID:(NSNumber *)userID
{
    return [self userByPredicate:[NSPredicate predicateWithFormat:@"(userID = %@)", userID]];
}

+ (ECUser *)userByName:(NSString *)name
{
   return [self userByPredicate:[NSPredicate predicateWithFormat:@"(name = %@)", name]];
}

+ (ECUser *)selfUser 
{
    if (selfUser == nil) {
        NSNumber *selfID = [[NSUserDefaults standardUserDefaults] objectForKey:@"selfID"];
        if (selfID) {
            selfUser = [[self userByID: selfID] retain];
        }
    }
    return selfUser;
}


@end
