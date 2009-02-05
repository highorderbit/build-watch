//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "BuildWatchAppController.h"
#import "ServerReport.h"
#import "ProjectReport.h"

@class Server, Project;

@interface BuildWatchAppController (Private)

- (void) setActiveServer:(NSString *) activeServer;

@end

@implementation BuildWatchAppController

@synthesize persistentStore;
@synthesize serverSelector;
@synthesize projectSelector;
@synthesize buildService;

- (void) dealloc
{
    [servers release];
    [serverNames release];
    [projectDisplayNames release];
    [persistentStore release];
    [buildService release];
    [super dealloc];
}

/*
- (id) initWithPersistentStore:(NSObject<ServerPersistentStore> *)persistentStore
             andServerSelector:(NSObject<ServerSelector> *)aServerSelector
{
    if (self = [super init]) {
        serverPersistentStore = [persistentStore retain];
        serverSelector = [aServerSelector retain];
    }
    return self;
}
 */

- (void) start
{
    servers = [[persistentStore getServers] retain];
    serverNames = [[persistentStore getServerNames] retain];
    projectDisplayNames = [[persistentStore getProjDisplayNames] retain];
    
    NSArray * serverKeys = [servers allKeys];
    
    for (NSString * server in serverKeys)
        [buildService refreshDataForServer:server];
    
    [serverSelector selectServerFrom:serverKeys];

    //
    // 1. Fetch existing data (server list).
    // 2. Start refresh of data from network.
    //     2.1: UI is updated.
    //     2.2: Start network communication.
    // 3. Hand something a list of servers to display.
    // 4. Tell something to display the list. ?
    //
}

#pragma mark Some protocol implementation

- (void) report:(ServerReport *)report receivedFrom:(NSString *)server
{
    NSMutableArray * projects = [[NSMutableArray alloc] init];
    
    for (ProjectReport * projReport in [report projectReports])
        [projects addObject:projReport.name];
    
    // TODO: save state
    
    if([activeServer isEqual:server])
        [projectSelector selectProjectFrom:projects];
    
    //
    // 1. Update UI for toolbar.
    // 2. Tell relevant view controller(s) to update themselves.
    //
}

#pragma mark ServerSelectorDelegate protocol implementation

- (void) userDidSelectServer:(NSString *)server
{
    //
    // 1. Load data from model as appropriate.
    // 2. Give data to projects controller.
    // 3. Orchestrate the display of the projects controller's view.
    //

    NSLog(@"User selected server: %@.", server);
    [self setActiveServer:server];
    [projectSelector selectProjectFrom:[servers objectForKey:server]];
}

#pragma mark Some (potentially different) protocol implementation

- (void) userDidSelectProject:(NSString *)project
{
    //
    // 1. Load data from model as appropriate.
    // 2. Give data to project controller.
    // 3. Orchestrate the display of the project controller's view.
    //

    NSLog(@"User selected project: %@.", project);
}

- (void) userDidHideProjects:(NSArray *)projects
{
    //
    // 1. Update model.
    // 2. Orchestrate the updating of the display. (?)
    // 3. Notify other UI elements of change as needed.
    //
}

- (void) userDidShowProjects:(NSArray *)projects
{
    //
    // 1. Update model.
    // 2. Orchestrate the updating of the display. (?)
    // 3. Notify other UI elements of change as needed.
    //
}

- (void) userDidAddServers:(NSArray *)servers
{
    //
    // 1. Save servers/update model.
    // 2. Start refresh of server data (if necessary).
    // 3. Update server controller's list of servers.
    //
}

- (void) userDidRemoveServers:(NSArray *)servers
{
    //
    // 1. Update model.
    // 2. Update server controller's list of servers.
    //
}

- (void) setActiveServer:(NSString *) server
{
    if(activeServer != server) {
        [activeServer release];
        activeServer = [server retain];
    }
}

@end
