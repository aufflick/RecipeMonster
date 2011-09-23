//
//  RecipeMonsterAppDelegate.h
//  RecipeMonster
//
//  Created by Mark Aufflick on 22/09/11.
//  Copyright 2011 Pumptheory Pty Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RecipeMonsterAppDelegate : NSObject <NSApplicationDelegate>
{
    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    NSManagedObjectModel *__managedObjectModel;
    NSManagedObjectContext *__mainQueueManagedObjectContext;
}

@property (assign) IBOutlet NSWindow * window;
@property (assign) IBOutlet NSTableView * recipeListTableView;
@property (assign) IBOutlet NSArrayController *recipeArrayController;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext * mainQueueManagedObjectContext;

- (NSManagedObjectContext *) createManagedObjectContextWithParent:(NSManagedObjectContext *)parentContext
                                               andConcurrencyType:(NSManagedObjectContextConcurrencyType)ct;
- (NSManagedObjectContext *) createManagedObjectContext;

- (IBAction)addRecipe:(id)sender;
- (IBAction)viewThisObject:(id)sender;
- (IBAction)viewInNewMOC:(id)sender;

@end

RecipeMonsterAppDelegate * TheAppDelegate(void);
