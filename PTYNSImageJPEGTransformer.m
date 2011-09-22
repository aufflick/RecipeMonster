//
//  PTYNSImageTransformer.m
//  RecipeMonster
//
//  Created by Mark Aufflick on 22/09/11.
//  Copyright 2011 Pumptheory Pty Ltd. All rights reserved.
//

#import "PTYNSImageJPEGTransformer.h"

@implementation PTYNSImageJPEGTransformer

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

+ (Class)transformedValueClass
{
    return [NSData class];
}

- (id)transformedValue:(id)value
{
    NSBitmapImageRep * rep = [[(NSImage *)value representations] objectAtIndex:0];
    
    NSData * data = [rep representationUsingType:NSJPEGFileType properties:nil];
    
    return data;
}

- (id)reverseTransformedValue:(id)value
{
    NSImage * image = [[NSImage alloc] initWithData:(NSData *)value];
    
    return image;
}

@end
