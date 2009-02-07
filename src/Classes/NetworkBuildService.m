//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "NetworkBuildService.h"
#import "BuildStatusUpdater.h"
#import "NetworkBuildStatusUpdater.h"
#import "CcrbServerReportBuilder.h"

@interface NetworkBuildService (Private)
- (NSObject<BuildStatusUpdater> *) createUpdaterForServerUrl:
    (NSString *)serverUrl;
- (void) destroyUpdater:(NSObject<BuildStatusUpdater> *)updater;
- (NSString *) serverUrlForUpdater:(NSObject<BuildStatusUpdater> *)updater;
+ (id)keyForUpdater:(NSObject<BuildStatusUpdater> *)updater;
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
    NSObject<BuildStatusUpdater> * updater =
        [self createUpdaterForServerUrl:serverUrl];
    [updater startUpdate];
}

#pragma mark BuildStatusUpdater protocol implementation

- (void) updater:(NSObject<BuildStatusUpdater> *)updater
  didReceiveData:(NSData *)data
{
    NSObject<ServerReportBuilder> * builder =
        [[CcrbServerReportBuilder alloc] init];

    NSString * serverUrl = [self serverUrlForUpdater:updater];

    NSError * error = nil;
    ServerReport * report = [builder serverReportFromData:data error:&error];

    if (error)
        [delegate
            attemptToGetReportFromServer:serverUrl didFailWithError:error];
    else
        [delegate report:report receivedFrom:serverUrl];

    [self destroyUpdater:updater];
}

- (void) updater:(NSObject<BuildStatusUpdater> *)updater
didFailWithError:(NSError *)error
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

    return [updater autorelease];
}

- (void) destroyUpdater:(NSObject<BuildStatusUpdater> *)updater
{
    [updaters removeObjectForKey:[[self class] keyForUpdater:updater]];
}

- (NSString *) serverUrlForUpdater:(NSObject<BuildStatusUpdater> *)updater
{
    return [updaters objectForKey:[[self class] keyForUpdater:updater]];
}

+ (id)keyForUpdater:(NSObject<BuildStatusUpdater> *)updater
{
    return [NSValue valueWithNonretainedObject:updater];
}

@end
