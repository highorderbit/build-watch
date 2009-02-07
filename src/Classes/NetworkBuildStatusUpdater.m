//
//  Copyright High Order Bit, Inc. 2009 . All rights reserved.
//

#import "NetworkBuildStatusUpdater.h"

@interface NetworkBuildStatusUpdater (Private)
- (void)setData:(NSData *)someData;
@end


@implementation NetworkBuildStatusUpdater

- (id)initWithUrl:(NSURL *)aUrl
         delegate:(NSObject<BuildStatusUpdaterDelegate> *)aDelegate
{
    if (self = [super init]) {
        url = [aUrl retain];
        delegate = [aDelegate retain];
    }

    return self;
}

- (void) dealloc
{
    [delegate release];
    [url release];
    [connection release];
    [data release];
    [super dealloc];
}

#pragma mark BuildStatusUpdater implementation

- (void) startUpdate
{
    [self setData:[NSData data]];
    NSURLRequest * req = [NSURLRequest requestWithURL:url];
    connection = [[NSURLConnection connectionWithRequest:req
                                                delegate:self] retain];

    [connection start];
}

- (void) cancelUpdate
{
    [connection cancel];
}

#pragma mark NSURLConnection protocol functions

- (void) connection:(NSURLConnection *)conn didReceiveData:(NSData *)moreData
{
    [data appendData:moreData];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)conn
{
    [delegate updater:self didReceiveData:data];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
    [delegate updater:self didFailWithError:error];
}

#pragma mark Accessors

- (void)setData:(NSData *)someData
{
    NSMutableData * tmp = [someData mutableCopy];
    [data release];
    data = tmp;
}

@end
