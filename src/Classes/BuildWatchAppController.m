//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "BuildWatchAppController.h"
#import "ServerReport.h"
#import "ProjectReport.h"

@class Server, Project;

static NSString * SERVER_GROUP_NAME_ALL = @"servergroups.all.label";

@interface BuildWatchAppController (Private)
- (void) setActiveServerGroupName:(NSString *) activeServer;
- (void) setServers:(NSDictionary *)newServers;
- (void) setServerGroupPatterns:(NSDictionary *)newServerGroupPatterns;
- (void) setServerNames:(NSDictionary *)newServerNames;
- (void) setProjectDisplayNames:(NSDictionary *)newProjectDisplayNames;
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
@synthesize serverGroupCreator;
@synthesize buildService;

- (void) dealloc
{
    [servers release];
    [serverGroupPatterns release];
    [serverNames release];
    [serverGroupNameSelector release];
    [projectSelector release];
    [projectReporter release];
    [projectDisplayNames release];
    [persistentStore release];
    [serverGroupCreator release];
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

    NSMutableDictionary * allServerNames =
        [[[persistentStore getServerNames] mutableCopy] autorelease];
    NSString * allLocalizedName = NSLocalizedString(SERVER_GROUP_NAME_ALL, @"");
    [allServerNames setObject:allLocalizedName forKey:allLocalizedName];
    [self setServerNames:allServerNames];

    [self setProjectDisplayNames:[persistentStore getProjDisplayNames]];
    
    NSArray * serverKeys = [servers allKeys];
    
    for (NSString * server in serverKeys)
        [buildService refreshDataForServer:server];
    
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
    // Update project display names
    for (ProjectReport * projReport in [report projectReports])
        [projectDisplayNames
         setObject:projReport.name
         forKey:[[self class] keyForProject:projReport.name andServer:server]];
    
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
    
    // TODO: change this to compare server against regex and send all projects
    //       in active server group
    if([activeServerGroupName isEqual:server])
        [projectSelector selectProjectFrom:projectIds];

    [projectIds release];
    
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

- (NSString *) displayNameForServerGroupName:(NSString *)serverGroupName
{
    return [serverNames objectForKey:serverGroupName];
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

- (void) createServerGroup
{
    [serverGroupCreator createServerGroup];
}

#pragma mark ServerGroupCreatorDelegate protocol implementation

- (void) serverGroupCreatedWithName:(NSString *)serverName
              andInitialBuildReport:(ServerReport *)report
{
    NSLog(@"Server group created: '%@', initial report: '%@'.",
          serverName, report);

    /*
     * Consider refactoring into a dedicated 'add server group' function.
     */

    NSMutableArray * projectNames = [NSMutableArray array];
    for (ProjectReport * projectReport in report.projectReports)
        [projectNames addObject:projectReport.name];
    [servers setObject:projectNames forKey:report.link];

    [serverGroupPatterns
        setObject:[NSString stringWithFormat:@"^%@$", report.link]
           forKey:report.link];
    [serverNames setObject:serverName forKey:report.link];

    [self report:report receivedFrom:report.link];

    [serverGroupNameSelector 
     selectServerGroupNamesFrom:[self serverGroupNames]];
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
    return [serverNames objectForKey:activeServerGroupName];
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
    NSPredicate * regExPred =
        [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    
    for (NSString * server in [servers allKeys])
        if ([regExPred evaluateWithObject:server] == YES)
            [projectIds addObjectsFromArray:[self projectIdsForServer:server]];
    
    return projectIds;
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
    
    [missingProjectIds release];
}

- (NSArray *) serverGroupNames
{
    NSMutableArray * serverGroupNames =
        [[[servers allKeys] mutableCopy] autorelease];
    [serverGroupNames addObject:NSLocalizedString(SERVER_GROUP_NAME_ALL, @"")];
    
    return serverGroupNames;
}

#pragma mark static utility functions

+ (NSString *) keyForProject:(NSString *)project andServer:(NSString *)server
{
    return [NSString stringWithFormat:@"%@|%@", server, project];
}

@end
