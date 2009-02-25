//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "NetworkBuildService.h"
#import "BuildStatusUpdater.h"
#import "NetworkBuildStatusUpdater.h"
#import "GenericServerReportBuilder.h"
#import "ServerReport.h"
#import "NSError+BuildWatchAdditions.h"

@interface NetworkBuildService (Private)
- (NSObject<BuildStatusUpdater> *) createUpdaterForServerUrl:
    (NSString *)serverUrl;
- (void) destroyUpdater:(NSObject<BuildStatusUpdater> *)updater;
- (NSString *) serverUrlForUpdater:(NSObject<BuildStatusUpdater> *)updater;
+ (id)keyForUpdater:(NSObject<BuildStatusUpdater> *)updater;
+ (NSObject<BuildStatusUpdater> *) updaterFromKey:(NSValue *)key;
@end

@implementation NetworkBuildService

@synthesize delegate;

- (void) dealloc
{
    [delegate release];
    [updaters release];
    [super dealloc];
}

#pragma mark Initializers

- (id) init
{
    return [self initWithDelegate:nil];
}

- (id) initWithDelegate:(NSObject<BuildServiceDelegate> *)aDelegate
{
    if (self = [super init]) {
        self.delegate = aDelegate;
        updaters = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (void) refreshDataForServer:(NSString *)serverUrl
{
    NSLog(@"Starting request to refresh data for server: '%@'.", serverUrl);

    NSObject<BuildStatusUpdater> * updater =
        [self createUpdaterForServerUrl:serverUrl];

    [updater startUpdate];
}

- (void) cancelRefreshForServer:(NSString *)serverUrl
{
    NSLog(@"Canceling server refresh for: '%@'.", serverUrl);

    for (NSValue * key in updaters) {
        NSString * updaterUrl = [updaters objectForKey:key];
        if ([serverUrl isEqualToString:updaterUrl]) {
            NSObject<BuildStatusUpdater> * updater =
                [[self class] updaterFromKey:key];

            [updater cancelUpdate];
            [self destroyUpdater:updater];
            break;
        }
    }
}

#pragma mark BuildStatusUpdater protocol implementation

- (void) updater:(NSObject<BuildStatusUpdater> *)updater
  didReceiveData:(NSData *)data
{
    NSString * serverUrl = [self serverUrlForUpdater:updater];

    NSAssert(delegate, @"Delegate is nil.");
    NSObject<ServerReportBuilder> * builder =
        [delegate builderForServer:serverUrl];

    ServerReport * report = nil;
    NSError * error = nil;

    if (!builder)
        error = [NSError errorWithLocalizedDescription:
             NSLocalizedString(@"ccserver.unsupported.message", @"")];
    else
        report = [builder serverReportFromUrl:serverUrl
                                         data:data
                                        error:&error];

    if (!builder || error)
        [delegate
            attemptToGetReportFromServer:serverUrl didFailWithError:error];
    else
        [delegate report:report receivedFrom:serverUrl];

    [self destroyUpdater:updater];
}

- (void) updater:(NSObject<BuildStatusUpdater> *)updater
 didReceiveError:(NSError *)error
{
    [delegate attemptToGetReportFromServer:[self serverUrlForUpdater:updater]
                          didFailWithError:error];
    [self destroyUpdater:updater];
}

#pragma mark Helper methods

- (NSObject<BuildStatusUpdater  > *) createUpdaterForServerUrl:
    (NSString *)serverUrl
{
    NetworkBuildStatusUpdater * updater = [[NetworkBuildStatusUpdater alloc]
        initWithUrl:[NSURL URLWithString:serverUrl]
           delegate:self];

    [updaters setObject:serverUrl forKey:[[self class] keyForUpdater:updater]];
    NSLog(@"Created updater: '%@' for URL: '%@'.", updater, serverUrl);

    return updater;
}

- (void) destroyUpdater:(NSObject<BuildStatusUpdater> *)updater
{
    NSLog(@"Destroying updater: '%@'.", updater);
    [updaters removeObjectForKey:[[self class] keyForUpdater:updater]];
    [updater release];
}

- (NSString *) serverUrlForUpdater:(NSObject<BuildStatusUpdater> *)updater
{
    return [updaters objectForKey:[[self class] keyForUpdater:updater]];
}

+ (id) keyForUpdater:(NSObject<BuildStatusUpdater> *)updater
{
    return [NSValue valueWithNonretainedObject:updater];
}

+ (NSObject<BuildStatusUpdater> *) updaterFromKey:(NSValue *)key
{
    return [key nonretainedObjectValue];
}

@end
