//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "NetworkBuildService.h"
#import "BuildStatusUpdater.h"
#import "NetworkBuildStatusUpdater.h"
#import "GenericServerReportBuilder.h"
#import "ServerReport.h"
#import "NSError+BuildWatchAdditions.h"
#import "ThreadedServerReportBuilder.h"


@interface AsynchronousReportBuilder : NSObject
{
    NSObject<ServerReportBuilder> * builder;

    NSString * serverUrl;
    NSData * data;
    NSError * error;

    ServerReport * report;
}

@property (nonatomic, copy) NSString * serverUrl;
@property (nonatomic, retain) NSObject<ServerReportBuilder> * builder;
@property (nonatomic, copy) NSData * data;
@property (nonatomic, copy) NSError * error;
@property (nonatomic, copy) ServerReport * report;

- (id) initWithBuilder:(NSObject<ServerReportBuilder> *)aBuilder
             serverUrl:(NSString *)aServerUrl
                  data:(NSData *)someData;

- (void) buildServerReport;
@end

@implementation AsynchronousReportBuilder

@synthesize serverUrl, builder, data, error, report;

- (void) dealloc
{
    [builder release];
    [serverUrl release];
    [data release];
    [error release];
    [report release];
    [super dealloc];
}

- (id) initWithBuilder:(NSObject<ServerReportBuilder> *)aBuilder
             serverUrl:(NSString *)aServerUrl
                  data:(NSData *)someData
{
    if (self = [super init]) {
        self.builder = aBuilder;
        self.serverUrl = aServerUrl;
        self.data = someData;
    }

    return self;
}

- (void) buildServerReport
{
    NSError * err;

    self.report = [builder serverReportFromUrl:serverUrl data:data error:&err];
    if (err)
        self.error = err;  // take ownership of the error object
}

@end


@interface NetworkBuildService (Private)
- (void) parseDataAsynchronously:(NSData *)data
                         fromUrl:(NSString *)serverUrl
                     withBuilder:(NSObject<ServerReportBuilder> *)builder;
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
    [asyncBuilders release];
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
        asyncBuilders = [[NSMutableDictionary alloc] init];
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

    [asyncBuilders removeObjectForKey:serverUrl];
}

#pragma mark BuildStatusUpdater protocol implementation

- (void) updater:(NSObject<BuildStatusUpdater> *)updater
  didReceiveData:(NSData *)data
{
    NSString * serverUrl = [self serverUrlForUpdater:updater];

    NSAssert(delegate, @"Delegate is nil.");
    NSObject<ServerReportBuilder> * builder =
        [delegate builderForServer:serverUrl];

    NSError * error = nil;

    if (builder)
        [self parseDataAsynchronously:data
                              fromUrl:serverUrl
                          withBuilder:builder];
    else {
        error = [NSError errorWithLocalizedDescription:
             NSLocalizedString(@"ccserver.unsupported.message", @"")];
        [delegate
            attemptToGetReportFromServer:serverUrl didFailWithError:error];
    }
}

- (void) parseDataAsynchronously:(NSData *)data
                         fromUrl:(NSString *)serverUrl
                     withBuilder:(NSObject<ServerReportBuilder> *)builder
{
    AsynchronousReportBuilder * asyncBuilder =
        [[AsynchronousReportBuilder alloc] initWithBuilder:builder
                                                 serverUrl:serverUrl
                                                      data:data];

    SEL sel = @selector(buildServerReport);
    NSMethodSignature * sig = [asyncBuilder methodSignatureForSelector:sel];
    NSInvocation * invocation =
        [NSInvocation invocationWithMethodSignature:sig];

    [invocation setTarget:asyncBuilder];
    [invocation setSelector:sel];
    [invocation retainArguments];

    AsynchronousInvocation * ai = [AsynchronousInvocation invocation];
    [asyncBuilders setObject:ai forKey:serverUrl];

    [ai executeInvocationAsynchronously:invocation
                   returnValueRecipient:self
                               selector:@selector(builderFinished:)];
}

- (void) builderFinished:(NSInvocation *)invocation
{
    AsynchronousReportBuilder * builder = [invocation target];

    ServerReport * report = builder.report;
    NSString * serverUrl = builder.serverUrl;
    NSError * error = builder.error;

    if (error)
        [delegate
         attemptToGetReportFromServer:serverUrl didFailWithError:error];
    else
        [delegate report:report receivedFrom:serverUrl];

    [asyncBuilders removeObjectForKey:serverUrl];
    [builder release];
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
