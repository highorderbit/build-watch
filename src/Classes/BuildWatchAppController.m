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
@synthesize serverGroupCreator;
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
    [serverGroupCreator release];
    [buildService release];
    [super dealloc];
}

- (void) start
{
    [self setServers:[persistentStore getServers]];
    [self setServerGroupPatterns:[persistentStore getServerGroupPatterns]];

    NSMutableDictionary * allServerNames =
        [[[persistentStore getServerNames] mutableCopy] autorelease];
    NSString * allLocalizedName = NSLocalizedString(SERVER_GROUP_NAME_ALL, @"");
    [allServerNames setObject:allLocalizedName forKey:allLocalizedName];
    [self setServerNames:allServerNames];

    [self setProjectDisplayNames:[persistentStore getProjectDisplayNames]];
    [self setProjectTrackedStates:[persistentStore getProjectTrackedStates]];
        
    [self refreshAllServerData];

    [serverGroupNameSelector
     selectServerGroupNamesFrom:[self serverGroupNames]];
}

#pragma mark Some protocol implementation

- (void) report:(ServerReport *)report receivedFrom:(NSString *)server
{
    [serverDataRefresherDelegate didRefreshDataForServer:server];
    if ([servers objectForKey:server]) {
        [self updatePropertiesForProjectReports:[report projectReports]
                                     withServer:server];
    
        // Set projects for server
        NSMutableArray * projects = [[NSMutableArray alloc] init];
    
        for (ProjectReport * projReport in [report projectReports])
            [projects addObject:projReport.name];

        [servers setObject:projects forKey:server];

        [self removeMissingProjectPropertiesWithProjects:projects
                                               andServer:server];
    
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
    
            if (serverMatchesActiveGroupNameRegEx)
                [projectSelector
                    selectProjectFrom:projectIdsForActiveServerGroup];
        }
    }
}

#pragma mark ServerSelectorDelegate protocol implementation

- (void) userDidSelectServerGroupName:(NSString *)serverGroupName
{
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

- (BOOL) trackedStateForProject:(NSString *)project
{
    return [[projectTrackedStates objectForKey:project] boolValue];
}

- (void) setTrackedState:(BOOL)state onProject:(NSString *)project
{
    [projectTrackedStates setObject:[NSNumber numberWithBool:state]
                             forKey:project];
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

#pragma mark StatePersister implementation

- (void) persistState
{
    [persistentStore saveServers:servers];
    [persistentStore saveServerGroupPatterns:serverGroupPatterns];
    [persistentStore saveServerNames:serverNames];
    [persistentStore saveProjectDisplayNames:projectDisplayNames];
    [persistentStore saveProjectTrackedStates:projectTrackedStates];
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
        
        if (![projectTrackedStates objectForKey:projectKey])
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
