//
//  DownloadWindow.m
//  RecipeMonster
//
//  Created by Mark Aufflick on 26/09/11.
//  Copyright 2011 Pumptheory Pty Ltd. All rights reserved.
//

#import "DownloadWindowController.h"

#import "RecipeMonsterAppDelegate.h"
#import "Recipe.h"

@interface DownloadWindowController ()

@property (retain) PunchFork * pf;

@end

@implementation DownloadWindowController

@synthesize searchString=_searchString;
@synthesize moc=_moc;
@synthesize insertingProgressIndicator = _insertingProgressIndicator;
@synthesize pf=_pf;
@synthesize progressIndicator = _progressIndicator;

- (IBAction)go:(id)sender
{
    self.pf = [[PunchFork alloc] init];
    self.pf.delegate = self;
    [self.pf startDownloadForSearchString:self.searchString];
    [self.progressIndicator startAnimation:self];
}

#pragma mark - PunchForkDelegate methods

- (void)punchFork:(PunchFork *)pf downloadFailed:(NSError *)error
{
    NSAlert * alert = [NSAlert alertWithError:error];
    [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:NULL];
    [self.progressIndicator stopAnimation:self];
}

- (void)punchFork:(PunchFork *)pf recipesReceived:(NSArray *)recipes
{
    NSManagedObjectContext * moc = self.moc;
    
    [moc performBlock:^(void) {
        [self.insertingProgressIndicator performSelectorOnMainThread:@selector(startAnimation:) withObject:nil waitUntilDone:NO];
        for (NSDictionary * recipeDict in recipes)
        {
            Recipe * recipe = [Recipe createEntityInContext:moc];
            recipe.title = [recipeDict objectForKey:@"title"];
            recipe.urlString = [recipeDict objectForKey:@"pf_url"];
            
            NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[recipeDict objectForKey:@"thumb"]]];
            recipe.thumbnail = [[NSImage alloc] initWithData:imageData];
        }
    }];
}

- (void)punchForkDownloadFinished:(PunchFork *)pf
{
    NSManagedObjectContext * moc = self.moc;
    
    [moc performBlock:^(void) {
        [self.insertingProgressIndicator performSelectorOnMainThread:@selector(stopAnimation:) withObject:nil waitUntilDone:NO];
        [moc save:nil];
    }];
    [self.progressIndicator stopAnimation:self];
}

@end
