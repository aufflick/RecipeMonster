//
//  MGA_CoreData+Convenience.m
//  AufflickCocoaAdditions
//
//  Created by Mark Aufflick on 17/08/11.
//  Copyright 2011 Pumptheory Pty Ltd. All rights reserved.
//

#import "PTY_CoreData+Convenience.h"

@implementation NSManagedObject (PTY_NSManagedObject_Convenience)

#pragma mark - Class Methods

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
}

+ (NSFetchRequest *)fetchRequestForAllObjectsInContext:(NSManagedObjectContext *)context
                                             withError:(NSError **)error
{
    NSEntityDescription *entity = [self entityDescriptionInContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];

    return request;
}

+ (NSArray *)findAllObjectsInContext:(NSManagedObjectContext *)context
                           withError:(NSError **)error
{
    NSFetchRequest *request = [self fetchRequestForAllObjectsInContext:context withError:error];
    
    return [context executeFetchRequest:request error:error];
}

+ (NSFetchRequest *)fetchRequestForObjectsMatchingPredicate:(NSPredicate *)predicate
                                                  inContext:(NSManagedObjectContext *)context
                                                  withError:(NSError **)error
{
    return [self fetchRequestForObjectsMatchingPredicate:predicate withSortDescriptors:nil inContext:context withError:error];
}


+ (NSArray *)findObjectsMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context withError:(NSError **)error
{
    return [self findObjectsMatchingPredicate:predicate withSortDescriptors:nil inContext:context withError:error];
}

+ (NSFetchRequest *)fetchRequestForObjectsMatchingPredicate:(NSPredicate *)predicate
                                        withSortDescriptors:(NSArray *)sortDescriptors
                                                  inContext:(NSManagedObjectContext *)context
                                                  withError:(NSError **)error
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName]
                                              inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    
    if (predicate)
        [fetchRequest setPredicate:predicate];
    
    if (sortDescriptors)
        [fetchRequest setSortDescriptors:sortDescriptors];

    return fetchRequest;
}

+ (NSArray *)findObjectsMatchingPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)sortDescriptors
                                inContext:(NSManagedObjectContext *)context withError:(NSError **)error
{
    NSFetchRequest * fetchRequest = [self fetchRequestForObjectsMatchingPredicate:predicate 
                                                              withSortDescriptors:sortDescriptors
                                                                        inContext:context
                                                                        withError:error];
    
    return [context executeFetchRequest:fetchRequest error:error];
}

+ (id)createEntityInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

+ (NSString *)entityName
{
    return NSStringFromClass(self);
}

+ (NSUInteger)totalCountInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fr = [[NSFetchRequest alloc] initWithEntityName:[self entityName]];
    __block NSUInteger count;
    [context performBlockAndWait:^{
        count = [context countForFetchRequest:fr error:nil];
    }];
    
    return count;
}

+ (NSString *)generateUUID
{
    CFUUIDRef newUUID = CFUUIDCreate(NULL);
    CFStringRef uuidString = CFUUIDCreateString(NULL, newUUID);
    
    NSString * ret = [(NSString *)uuidString copy];
    
    CFRelease(uuidString);
    CFRelease(newUUID);

    return ret;
}

@end

@implementation NSManagedObjectContext (PTY_NSManagedObjectContext_Convenience)

- (void)saveWithErrorHandler:(void(^)(NSError *))errorHandler
{
    return [self saveWithErrorHandler:errorHandler andSuccessHandler:nil];
}

- (void)saveWithErrorHandler:(void(^)(NSError *))errorHandler andSuccessHandler:(void(^)(void))successHandler
{
    [self performBlockAndWait:^{
        NSError * error;
        if ([self hasChanges] && ![self save:&error])
        {
            if (!errorHandler)
            {
                NSLog(@"error saving moc and no error handler supplied: %@", [error userInfo]);
                abort();
            }
            
            errorHandler(error);
        }
        else
        {
            if (successHandler)
                successHandler();
        }
    }];
}



@end
