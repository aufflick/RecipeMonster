//
//  DownloadWindow.h
//  RecipeMonster
//
//  Created by Mark Aufflick on 26/09/11.
//  Copyright 2011 Pumptheory Pty Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>
#import "PunchFork.h"

@interface DownloadWindowController : NSWindowController <PunchForkDelegate> {
    NSProgressIndicator *_insertingProgressIndicator;
}



@property (retain) NSString * searchString;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (retain) NSManagedObjectContext * moc;
@property (assign) IBOutlet NSProgressIndicator *insertingProgressIndicator;

- (IBAction)go:(id)sender;

@end
