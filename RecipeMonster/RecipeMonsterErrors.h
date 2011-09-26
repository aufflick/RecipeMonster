//
//  RecipeMonsterErrors.h
//  RecipeMonster
//
//  Created by Mark Aufflick on 26/09/11.
//  Copyright 2011 Pumptheory Pty Ltd. All rights reserved.
//

// the attribute is required to prevent the clang static analyser from warning us every time
// it compiles a file that doesn't use a particular error code
#define RPMErrorCode static NSInteger __attribute__((unused))

#pragma mark - RPMErrorDomain

static NSString * __attribute__((unused)) RPMErrorDomain = @"com.pumptheory.RecipeMonster.ErrorDomain";

RPMErrorCode RPMPunchForkURLConnectionCouldntBeCreated = 1000;
RPMErrorCode RPMPunchForkUnexpectedResultFormat = 1001;

#pragma mark - Utility Defines

#define RPMMakeError(errorCode, desc, formatArgs...) ([NSError errorWithDomain: RPMErrorDomain code: errorCode \
userInfo:[NSDictionary dictionaryWithObjectsAndKeys:\
[NSString stringWithFormat: desc , ## formatArgs ], \
NSLocalizedDescriptionKey, nil]])
