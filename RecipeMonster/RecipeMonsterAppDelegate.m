//
//  RecipeMonsterAppDelegate.m
//  RecipeMonster
//
//  Created by Mark Aufflick on 22/09/11.
//  Copyright 2011 Pumptheory Pty Ltd. All rights reserved.
//

#import "RecipeMonsterAppDelegate.h"

#import "RecipeWindowController.h"
#import "DownloadWindowController.h"

#define MOMD_NAME @"RecipeMonster"
#define PERSISTENT_STORE_FILE_NAME @"RecipeMonster.storedata"
#define PERSISTENT_STORE_TYPE NSXMLStoreType


@implementation RecipeMonsterAppDelegate

@synthesize window=_window;
@synthesize recipeListTableView = _recipeListTableView;
@synthesize recipeArrayController = _recipeArrayController;

- (NSURL *)applicationFilesDirectory
{

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    return [libraryURL URLByAppendingPathComponent:@"RecipeMonster"];
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *) mainQueueManagedObjectContext
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __mainQueueManagedObjectContext = [self createManagedObjectContextWithParent:nil 
                                                                  andConcurrencyType:NSMainQueueConcurrencyType];
    });
    
    return __mainQueueManagedObjectContext;
}

- (NSManagedObjectContext *) createManagedObjectContext
{
    return [self createManagedObjectContextWithParent:self.mainQueueManagedObjectContext 
                                   andConcurrencyType:NSPrivateQueueConcurrencyType];
}

- (NSManagedObjectContext *) createManagedObjectContextWithParent:(NSManagedObjectContext *)parentContext andConcurrencyType:(NSManagedObjectContextConcurrencyType)ct;
{
    NSManagedObjectContext *newManagedObjectContext = nil;
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil)
    {
        newManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:ct];
        
        if (parentContext)
            newManagedObjectContext.parentContext = parentContext;
        else
            [newManagedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
	if (!newManagedObjectContext)
    {
        NSLog(@"RecipeMonster could not create self.managedObjectContext");
    }
    
    return newManagedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:MOMD_NAME
                                                         ofType:@"momd"];
        
        NSAssert(path != nil, @"Unable to find DataModel in main bundle");
        NSURL *url = [NSURL fileURLWithPath:path];
        __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
        
    });
    
    return __managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        BOOL inError = NO;
        
        NSManagedObjectModel *mom = [self managedObjectModel];
        if (!mom) {
            NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
            inError = YES;
        }
        
        if (!inError)
        {
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
            NSError *error = nil;
            
            NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
            
            if (!properties) {
                BOOL ok = NO;
                if ([error code] == NSFileReadNoSuchFileError) {
                    ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
                }
                if (!ok) {
                    [[NSApplication sharedApplication] presentError:error];
                    inError = YES;
                }
            }
            else {
                if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
                    // Customize and localize this error.
                    NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
                    error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
                    
                    [[NSApplication sharedApplication] presentError:error];
                    inError = YES;
                }
            }
            
            if (!inError)
            {
                
                NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:PERSISTENT_STORE_FILE_NAME];
                __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
                if (![__persistentStoreCoordinator addPersistentStoreWithType:PERSISTENT_STORE_TYPE configuration:nil URL:url options:nil error:&error])
                {
                    [[NSApplication sharedApplication] presentError:error];
                    [__persistentStoreCoordinator release], __persistentStoreCoordinator = nil;
                }
            }
        }
    });
    
    return __persistentStoreCoordinator;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    /*
    if (!__mainQueueManagedObjectContext) {
        return NSTerminateNow;
    }

    if (![[self mainQueueManagedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }

    if (![[self mainQueueManagedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }

    NSError *error = nil;
    if (![[self mainQueueManagedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
     */

    return NSTerminateNow;
}

#pragma mark - IBActions

- (IBAction)viewThisObject:(id)sender
{
    RecipeWindowController * wc = [[RecipeWindowController alloc] init];
    NSNib * nib = [[NSNib alloc] initWithNibNamed:@"RecipeWindow" bundle:[NSBundle mainBundle]];
    [nib instantiateNibWithOwner:wc topLevelObjects:nil];
    
    Recipe * recipe = [[self.recipeArrayController arrangedObjects] objectAtIndex:[self.recipeListTableView rowForView:sender]];
    wc.recipe = recipe;
    [wc.window makeKeyAndOrderFront:self];
}

- (IBAction)viewInNewMOC:(id)sender
{
    RecipeWindowController * wc = [[RecipeWindowController alloc] init];
    NSNib * nib = [[NSNib alloc] initWithNibNamed:@"RecipeWindow" bundle:[NSBundle mainBundle]];
    [nib instantiateNibWithOwner:wc topLevelObjects:nil];

    NSManagedObjectContext * newMoc = [self createManagedObjectContext];

    Recipe * mainQueueRecipeObject = [[self.recipeArrayController arrangedObjects] objectAtIndex:[self.recipeListTableView rowForView:sender]];
    
    __block Recipe * recipe = nil;
    [newMoc performBlockAndWait:^(void) {
        recipe = (Recipe *)[newMoc objectWithID:[mainQueueRecipeObject objectID]];
    }];
    
    wc.recipe = recipe;
    [wc.window makeKeyAndOrderFront:self];
}

- (IBAction)download:(id)sender
{
    DownloadWindowController * wc = [[DownloadWindowController alloc] init];
    
    wc.moc = [TheAppDelegate() createManagedObjectContext];
    
    NSNib * nib = [[NSNib alloc] initWithNibNamed:@"DownloadWindow" bundle:[NSBundle mainBundle]];
    [nib instantiateNibWithOwner:wc topLevelObjects:nil];
    
    [wc.window makeKeyAndOrderFront:self];
}

- (IBAction)saveButton:(id)sender
{
    NSManagedObjectContext * moc = self.mainQueueManagedObjectContext;
    [moc performBlock:^(void) {
        [moc save:nil];
    }];
}

- (IBAction)addRecipe:(id)sender
{
    RecipeWindowController * wc = [[RecipeWindowController alloc] init];
    NSNib * nib = [[NSNib alloc] initWithNibNamed:@"RecipeWindow" bundle:[NSBundle mainBundle]];
    [nib instantiateNibWithOwner:wc topLevelObjects:nil];
    
    NSManagedObjectContext * newMoc = [self createManagedObjectContext];

    __block Recipe * newRecipe = nil;
    [newMoc performBlockAndWait:^(void) {
        newRecipe = [Recipe createEntityInContext:newMoc];
    }];
    
    wc.recipe = newRecipe;
    [wc.window makeKeyAndOrderFront:self];
}


@end

RecipeMonsterAppDelegate * TheAppDelegate(void)
{
    return (RecipeMonsterAppDelegate *)[[NSApplication sharedApplication] delegate];
}
