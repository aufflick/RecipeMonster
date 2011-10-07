//
//  PunchFork.m
//  RecipeMonster
//
//  Created by Mark Aufflick on 26/09/11.
//  Copyright 2011 Pumptheory Pty Ltd. All rights reserved.
//

#import "PunchFork.h"

@interface PunchFork ()

@property (retain) NSString * punchForkApiURLString;
@property (retain) NSString * punchForkApiSecret;
@property (retain) NSString * nextRequestCursor;
@property (retain) NSString * searchString;
@property (retain) NSURLConnection * conn;
@property (retain) NSMutableData * receivedData;

- (NSString *)apiURLString;
- (void)continueDownload;

@end

@implementation PunchFork

@synthesize punchForkApiURLString=_punchForkApiURLString;
@synthesize punchForkApiSecret=_punchForkApiSecret;
@synthesize nextRequestCursor=_nextRequestCursor;
@synthesize conn=_conn;
@synthesize receivedData=_receivedData;
@synthesize delegate=_delegate;
@synthesize searchString=_searchString;

- (id)init
{
    if ((self = [super init]))
    {
        NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"PunchForkApiAccount" ofType:@"plist"];
        NSDictionary * plist = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        self.punchForkApiURLString = [plist objectForKey:@"PunchForkApiUrlString"];
        self.punchForkApiSecret = [plist objectForKey:@"PunchForkApiKey"];
    }
    
    return self;
}

// NB: This is a naive approach to downloading.
// For all the recent complaining, ASIHTTPRequest is the easiest way to handle most cases.

// For minimal external requirements, NSJSONSerialization is being used. YAJL would be a better choice
// under iOS so the stream can be deserialised as chunks come in, reducing overall memory use and
// elapsed time.

- (void)startDownloadForSearchString:(NSString *)searchString
{
    self.nextRequestCursor = nil;
    self.searchString = searchString;
    [self continueDownload];
}

- (void)continueDownload
{
    NSString * urlString = [self apiURLString];
    if (self.nextRequestCursor)
        urlString = [urlString stringByAppendingFormat:@"&cursor=%@", self.nextRequestCursor];
    
    NSURLRequest * req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                      timeoutInterval:60.0];
    
    self.conn = [NSURLConnection connectionWithRequest:req delegate:self];
    if (!self.conn)
    {
        [self.delegate punchFork:self downloadFailed:RPMMakeError(RPMPunchForkURLConnectionCouldntBeCreated,
                                                                  @"Couldn't create the connection to PunchFork's api")];
    }

}

- (NSURL *)apiURLString
{
    return [NSString stringWithFormat:@"%@/recipes?key=%@&q=%@",
            self.punchForkApiURLString,
            self.punchForkApiSecret,
            self.searchString];
}

#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.receivedData = [[NSMutableData alloc] initWithLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.receivedData = nil;
    [self.delegate punchFork:self downloadFailed:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError * error;
    NSDictionary * res = [NSJSONSerialization JSONObjectWithData:self.receivedData options:0 error:&error];
    
    NSArray * recipes = [res objectForKey:@"recipes"];
    
    self.receivedData = nil;
    self.conn = nil;

    if (recipes)
    {
        [self.delegate punchFork:self recipesReceived:recipes];
        self.nextRequestCursor = [res objectForKey:@"next_cursor"];
        
        if (self.nextRequestCursor && [self.nextRequestCursor length])
        {
            [self continueDownload];
        }
        else
        {
            [self.delegate punchForkDownloadFinished:self];
        }
    }
    else
    {
        if (!res)
        {
            [self.delegate punchFork:self downloadFailed:error];
        }
        else
        {
            [self.delegate punchFork:self downloadFailed:RPMMakeError(RPMPunchForkUnexpectedResultFormat, @"Missing recipes key")];
        }        
    }    
}


@end
