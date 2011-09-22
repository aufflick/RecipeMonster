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

@end
