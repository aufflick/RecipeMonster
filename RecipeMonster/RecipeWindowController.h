//
//  RecipeWindowController.h
//  RecipeMonster
//
//  Created by Mark Aufflick on 22/09/11.
//  Copyright 2011 Pumptheory Pty Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <WebKit/WebKit.h>
#import "Recipe.h"

@interface RecipeWindowController : NSWindowController

@property (retain) Recipe * recipe;
@property (assign) IBOutlet WebView *webView;

- (IBAction)save:(id)sender;
- (IBAction)refetch:(id)sender;

@end
