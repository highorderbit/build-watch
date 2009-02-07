//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "BuildWatchAppController.h"
#import "ServerReport.h"
#import "ProjectReport.h"
#import "RegexKitLite.h"

@class Server, Project;

static NSString * SERVER_GROUP_NAME_ALL = @"servergroups.all.label";

@interface BuildWatchAppController (Private)
- (void) setActiveServerGroupName:(NSString *) activeServer;
- (void) setServers:(NSDictionary *)newServers;
- (void) setServerGroupPatterns:(NSDictionary *)newServerGroupPatterns;
- (void) setServerNames:(NSDictionary *)newServerNames;
- (void) setProjectDisplayNames:(NSDictionary *)newProjectDisplayNames;
- (void) setProjectTrackedStates:(NSDictionary *)newProjectTrackedStates;
- (void) updatePropertiesForProjectReports:(NSArray *)projectReports
                                withServer:(NSString *)server;
- (void) removeMissingProjectPropertiesWithProjects:(NSArray *)newProjects
                                          andServer:(NSString *)server;
- (NSArray *) projectIdsForServer:(NSString *)server;
- (NSArray *) projectIdsForServerGroupName:(NSString *)serverGroupName;
- (NSArray *) serverGroupNames;
+ (NSString *) keyForProject:(NSString *)project andServer:(NSString *)server;
@end

@implementation BuildWatchAppController

@synthesize persistentStore;
@synthesize serverGroupNameSelector;
@synthesize projectSelector;
@synthesize projectReporter;
@synthesize buildService;
@synthesize serverDataRefresherDelegate;

- (void) dealloc
{
    [servers release];
    [serverGroupPatterns release];
    [serverNames release];
    [serverGroupNameSelector release];
    [projectSelector release];
    [projectReporter release];
    [projectDisplayNames release];
    [projectTrackedStates release];
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
    [self setServers:[persistentStore getServers]];
    [self setServerGroupPatterns:[persistentStore getServerGroupPatterns]];
    [self setServerNames:[persistentStore getServerNames]];
    [self setProjectDisplayNames:[persistentStore getProjectDisplayNames]];
    [self setProjectTrackedStates:[persistentStore getProjectTrackedStates]];
        
    [self refreshAllServerData];
    
    [serverGroupNameSelector
     selectServerGroupNamesFrom:[self serverGroupNames]];

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
    [serverDataRefresherDelegate didRefreshDataForServer:server];
    [self updatePropertiesForProjectReports:[report projectReports]
                                 withServer:server];
    
    // Set projects for server
    NSMutableArray * projects = [[NSMutableArray alloc] init];
    
    for (ProjectReport * projReport in [report projectReports])
        [projects addObject:projReport.name];

    [servers setObject:projects forKey:server];

    [self removeMissingProjectPropertiesWithProjects:projects andServer:server];
    
    [projects release];
    
    // update project ids
    NSMutableArray * projectIds = [[NSMutableArray alloc] init];
    
    for (ProjectReport * projReport in [report projectReports])
        [projectIds addObject:[[self class]
                               keyForProject:projReport.name
                                   andServer:server]];

    [projectIds release];
    
    // Push updates to project selector
    if(activeServerGroupName != nil) {
        NSString * serverGroupPattern =
            [serverGroupPatterns objectForKey:activeServerGroupName];
        BOOL serverMatchesActiveGroupNameRegEx =
            [server isMatchedByRegex:serverGroupPattern];
        NSArray * projectIdsForActiveServerGroup =
            [self projectIdsForServerGroupName:activeServerGroupName];
    
        if(serverMatchesActiveGroupNameRegEx)
            [projectSelector selectProjectFrom:projectIdsForActiveServerGroup];
    }
    //
    // 1. Update UI for toolbar.
    //
}

#pragma mark ServerSelectorDelegate protocol implementation

- (void) userDidSelectServerGroupName:(NSString *)serverGroupName
{
    //
    // 1. Load data from model as appropriate.
    // 2. Give data to projects controller.
    // 3. Orchestrate the display of the projects controller's view.
    //

    NSLog(@"User selected server group name: %@.", serverGroupName);
    [self setActiveServerGroupName:serverGroupName];
    [projectSelector
     selectProjectFrom:[self projectIdsForServerGroupName:serverGroupName]]; 
}

- (BOOL) canServerGroupBeDeleted:(NSString *)serverGroupName
{
    return ![serverGroupName isEqual:
        NSLocalizedString(SERVER_GROUP_NAME_ALL, @"")];
}

- (void) deleteServerGroupWithName:(NSString *)serverGroupName
{
    NSArray * projectIds = [self projectIdsForServer:serverGroupName];
    for (NSString * projectId in projectIds)
        [projectDisplayNames removeObjectForKey:projectId];

    [servers removeObjectForKey:serverGroupName];
    [serverNames removeObjectForKey:serverGroupName];
}

#pragma mark ProjectSelectorDelegate protocol implementation

- (void) userDidSelectProject:(NSString *)project
{
    //
    // 1. Load data from model as appropriate.
    // 2. Give data to project controller.
    // 3. Orchestrate the display of the project controller's view.
    //

    NSLog(@"User selected project: %@.", project);
    [projectReporter reportDetailsForProject:project];
}

- (void) userDidDeselectServerGroupName
{
    [self setActiveServerGroupName:nil]; 
}

- (NSString *) displayNameForProject:(NSString *)project
{
    NSString * displayName = [projectDisplayNames objectForKey:project];
    NSAssert2(
        displayName != nil,
        @"Unable to find display name for project %@.  Display names: %@",
        project,
        projectDisplayNames);
    
    return displayName;
}

- (NSString *) displayNameForCurrentProjectGroup
{
    return activeServerGroupName;
}

- (BOOL) trackedStateForProject:(NSString *)project
{
    return [[projectTrackedStates objectForKey:project] boolValue];
}

- (void) setTrackedState:(BOOL)state onProject:(NSString *)project
{
    [projectTrackedStates setObject:[NSNumber numberWithBool:state]
                             forKey:project];
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

#pragma mark ServerDataRefresher implementation

- (void) refreshAllServerData
{
    NSArray * serverKeys = [servers allKeys];
    
    for (NSString * server in serverKeys) {
        [serverDataRefresherDelegate refreshingDataForServer:server];
        [buildService refreshDataForServer:server];
    }
}

#pragma mark Accessors

- (void) setActiveServerGroupName:(NSString *) server
{
    [server retain];
    [activeServerGroupName release];
    activeServerGroupName = server;
}

- (void) setServers:(NSDictionary *)newServers
{
    NSMutableDictionary * tempServers = [newServers mutableCopy];
    [servers release];
    servers = tempServers;
}

- (void) setServerGroupPatterns:(NSDictionary *)newServerGroupPatterns
{
    NSMutableDictionary * tempGroupNamePatterns =
        [newServerGroupPatterns mutableCopy];
    [serverGroupPatterns release];
    serverGroupPatterns = tempGroupNamePatterns;
}

- (void) setServerNames:(NSDictionary *)newServerNames
{
    NSMutableDictionary * tempServerNames = [newServerNames mutableCopy];
    [serverNames release];
    serverNames = tempServerNames;
}

- (void) setProjectDisplayNames:(NSDictionary *)newProjectDisplayNames;
{
    NSMutableDictionary * tempProjectDisplayNames =
        [newProjectDisplayNames mutableCopy];
    [projectDisplayNames release];
    projectDisplayNames = tempProjectDisplayNames;
}

- (void) setProjectTrackedStates:(NSDictionary *)newProjectTrackedStates
{
    NSMutableDictionary * tempProjectTrackedStates =
        [newProjectTrackedStates mutableCopy];
    [projectTrackedStates release];
    projectTrackedStates = tempProjectTrackedStates;
}

#pragma mark Private helper functions

- (NSArray *) projectIdsForServer:(NSString *)server
{
    NSMutableArray * projectIds = [NSMutableArray array];
    
    for (NSString * project in [servers objectForKey:server])
        [projectIds addObject:
         [BuildWatchAppController keyForProject:project andServer:server]];
    
    return projectIds;
}

- (NSArray *) projectIdsForServerGroupName:(NSString *)serverGroupName
{
    NSMutableArray * projectIds =[[[NSMutableArray alloc] init] autorelease];
    NSString * regEx = [serverGroupPatterns objectForKey:serverGroupName];
    
    for (NSString * server in [servers allKeys])
        if ([server isMatchedByRegex:regEx])
            [projectIds addObjectsFromArray:[self projectIdsForServer:server]];
    
    return projectIds;
}

- (void) updatePropertiesForProjectReports:(NSArray *)projectReports
                                withServer:(NSString *)server
{
    for (ProjectReport * projReport in projectReports) {
        NSString * projectKey =
        [[self class] keyForProject:projReport.name andServer:server];
        
        [projectDisplayNames setObject:projReport.name forKey:projectKey];
        [projectTrackedStates setObject:[NSNumber numberWithBool:YES]
                                 forKey:projectKey];
    }
}

- (void) removeMissingProjectPropertiesWithProjects:(NSArray *)newProjects
                                          andServer:(NSString *)server
{
    NSMutableArray * missingProjectIds = [[NSMutableArray alloc] init];
    // find missing projects and create keys from them
    for (NSString * project in [servers objectForKey:server])
        if (![newProjects containsObject:project])
            [missingProjectIds
             addObject:[[self class]keyForProject:project andServer:server]];
    
    [projectDisplayNames removeObjectsForKeys:missingProjectIds];
    [projectTrackedStates removeObjectsForKeys:missingProjectIds];
    
    [missingProjectIds release];
}

- (NSArray *) serverGroupNames
{
    NSMutableArray * serverGroupNames = [[servers allKeys] mutableCopy];
    [serverGroupNames addObject:NSLocalizedString(SERVER_GROUP_NAME_ALL, @"")];
    
    return serverGroupNames;
}

#pragma mark static utility functions

+ (NSString *) keyForProject:(NSString *)project andServer:(NSString *)server
{
    return [NSString stringWithFormat:@"%@|%@", server, project];
}

@end
