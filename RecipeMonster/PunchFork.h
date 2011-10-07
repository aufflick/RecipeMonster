//
//  PunchFork.h
//  RecipeMonster
//
//  Created by Mark Aufflick on 26/09/11.
//  Copyright 2011 Pumptheory Pty Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PunchForkDelegate;

@interface PunchFork : NSObject <NSURLConnectionDelegate>

@property __weak id<PunchForkDelegate> delegate;

- (void)startDownloadForSearchString:(NSString *)searchString;

@end

@protocol PunchForkDelegate <NSObject>

@required

- (void)punchFork:(PunchFork *)pf recipesReceived:(NSArray *)recipes;
- (void)punchFork:(PunchFork *)pf downloadFailed:(NSError *)error;
- (void)punchForkDownloadFinished:(PunchFork *)pf;

@end
