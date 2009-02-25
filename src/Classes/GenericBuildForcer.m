//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "GenericBuildForcer.h"
#import "NSError+BuildWatchAdditions.h"

@interface GenericBuildForcer (Private)
- (NSURLConnection *) connectionForProject:(NSString *)project
                         withForceBuildUrl:(NSString *)projectForceBuildUrl;
- (void) saveConnection:(NSURLConnection *)connection
             forProject:(NSString *)project
          forceBuildUrl:(NSString *)forceBuildUrl;
- (void) destroyConnection:(NSURLConnection *)connection;
- (NSString *) projectForConnection:(NSURLConnection *)connection;
- (NSString *) forceBuildUrlForConnection:(NSURLConnection *)connection;
+ (NSObject *) keyForConnection:(NSURLConnection *)connection;
@end

@implementation GenericBuildForcer

@synthesize delegate;

- (void) dealloc
{
    [projectsForConnections release];
    [forceBuildUrlsForConnections release];
    [super dealloc];
}

- (id) init
{
    if (self = [super init]) {
        projectsForConnections = [[NSMutableDictionary alloc] init];
        forceBuildUrlsForConnections = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (void) forceBuildForProject:(NSString *)project
            withForceBuildUrl:(NSString *)projectForceBuildUrl
{
    NSLog(@"'%@': forcing project: '%@'.", project, projectForceBuildUrl);

    NSURLRequest * req =
        [NSURLRequest requestWithURL:
                [NSURL URLWithString:projectForceBuildUrl]];

    NSURLConnection * connection =
        [[NSURLConnection alloc] initWithRequest:req
                                        delegate:self
                                startImmediately:YES];

    [self saveConnection:connection
              forProject:project
           forceBuildUrl:projectForceBuildUrl];
}

#pragma mark NSURLConnection protocol functions

- (void) connection:(NSURLConnection *)conn didReceiveData:(NSData *)moreData
{
    // we're just throwing the data away
}

- (void)                   connection:(NSURLConnection *)conn
    didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"'%@': Challenged for authentication from: '%@': '%@'.",
        [self projectForConnection:conn], conn,
        [self forceBuildUrlForConnection:conn]);

    [[challenge sender] cancelAuthenticationChallenge:challenge];

    [self destroyConnection:conn];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)conn
{
    [delegate buildForcedForProject:[self projectForConnection:conn]
                  withForceBuildUrl:[self forceBuildUrlForConnection:conn]];

    [self destroyConnection:conn];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
    [delegate forceBuildForProject:[self projectForConnection:conn]
                 withForceBuildUrl:[self forceBuildUrlForConnection:conn]
                  didFailWithError:error];

    [self destroyConnection:conn];
}

#pragma mark Managing connections

- (void) saveConnection:(NSURLConnection *)connection
             forProject:(NSString *)project
          forceBuildUrl:(NSString *)forceBuildUrl
{
    NSObject * connectionKey = [[self class] keyForConnection:connection];

    [projectsForConnections setObject:project forKey:connectionKey];
    [forceBuildUrlsForConnections setObject:forceBuildUrl forKey:connectionKey];
}

- (void) destroyConnection:(NSURLConnection *)connection
{
    NSObject * connectionKey = [[self class] keyForConnection:connection];

    [projectsForConnections removeObjectForKey:connectionKey];
    [forceBuildUrlsForConnections removeObjectForKey:connectionKey];
}

- (NSString *) projectForConnection:(NSURLConnection *)connection
{
    return [projectsForConnections
        objectForKey:[[self class] keyForConnection:connection]];
}

- (NSString *) forceBuildUrlForConnection:(NSURLConnection *)connection
{
    return [forceBuildUrlsForConnections
        objectForKey:[[self class] keyForConnection:connection]];
}

+ (NSObject *) keyForConnection:(NSURLConnection *)connection
{
    return [NSValue valueWithNonretainedObject:connection];
}

@end
