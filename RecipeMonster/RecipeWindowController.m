//
//  RecipeWindowController.m
//  RecipeMonster
//
//  Created by Mark Aufflick on 22/09/11.
//  Copyright 2011 Pumptheory Pty Ltd. All rights reserved.
//

#import "RecipeWindowController.h"

@implementation RecipeWindowController

@synthesize recipe=_recipe;
@synthesize webView = _webView;

- (void)loadURL
{
    if ([self.recipe.urlString length])
        [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.recipe.urlString]]];
}

- (void)setRecipe:(Recipe *)recipe
{
    if (recipe == _recipe)
        return;
    
    [_recipe removeObserver:self forKeyPath:@"urlString"];
    _recipe = recipe;
    [recipe addObserver:self forKeyPath:@"urlString" options:0 context:nil];
    
    [self loadURL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self loadURL];
}

- (IBAction)save:(id)sender
{
    [self.recipe.managedObjectContext performBlockAndWait:^(void) {
        [self.recipe.managedObjectContext saveWithErrorHandler:^(NSError * error) {
            
            PerformBlockOnMainThreadAfterDelay(^{
                [[self window] presentError:error];
            }, 0);
            
        }];
    }];
}

- (IBAction)refetch:(id)sender
{
    NSManagedObjectContext * moc = self.recipe.managedObjectContext;
    
    [moc performBlockAndWait:^(void) {
        [moc refreshObject:self.recipe mergeChanges:YES];
    }];
}



@end
