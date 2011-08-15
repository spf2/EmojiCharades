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
    NSString *selfName = selfUser.name;
    [[NSUserDefaults standardUserDefaults] setValue:selfName forKey:@"selfName"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    selfUser = nil;
}

+ (ECUser *)selfUser 
{
    static ECUser* selfUser = nil;
    if (selfUser == nil) {
        NSString *selfName = [[NSUserDefaults standardUserDefaults] objectForKey:@"selfName"];
        if (selfName) {
            selfUser = [[self userByName: selfName] retain];
        }
    }
    return selfUser;
}

+ (ECUser *)userByName:(NSString *)name
{
    NSManagedObjectContext *moc = RKObjectManager.sharedManager.objectStore.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"ECUser" inManagedObjectContext:moc];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name = %@)", name];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error fetching user %@: %@", name, [error localizedDescription]);
    }
    if ([array count] == 1) {
        return [array objectAtIndex:0];    
    }
    return nil;
}

@end
