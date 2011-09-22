//
//  Recipe.h
//  RecipeMonster
//
//  Created by Mark Aufflick on 22/09/11.
//  Copyright (c) 2011 Pumptheory Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "PTY_CoreData+Convenience.h"

@interface Recipe : NSManagedObject

@property (nonatomic, retain) NSImage * thumbnail;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * urlString;

@end
