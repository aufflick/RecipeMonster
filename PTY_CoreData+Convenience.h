//
//  MGA_CoreData+Convenience.h
//  AufflickCocoaAdditions
//
//  Created by Mark Aufflick on 17/08/11.
//  Copyright 2011 Pumptheory Pty Ltd. All rights reserved.
//



@interface NSManagedObject (PTY_NSManagedObject_Convenience)

/*
 * Core Data helper methods
 */

// defined
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;

+ (NSArray *)findAllObjectsInContext:(NSManagedObjectContext *)context withError:(NSError **)error;

+ (NSArray *)findObjectsMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context withError:(NSError **)error;

+ (NSArray *)findObjectsMatchingPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)sortDescriptors
                                inContext:(NSManagedObjectContext *)context withError:(NSError **)error;

+ (id)createEntityInContext:(NSManagedObjectContext *)context;

+ (NSString *)entityName;

+ (NSUInteger)totalCountInContext:(NSManagedObjectContext *)context; // NB - could be NSNotFound

+ (NSString *)generateUUID;

@end

@interface NSManagedObjectContext (PTY_NSManagedObjectContext_Convenience)

- (void)saveWithErrorHandler:(void(^)(NSError *))errorHandler;
- (void)saveWithErrorHandler:(void(^)(NSError *))errorHandler andSuccessHandler:(void(^)(void))successHandler;

@end