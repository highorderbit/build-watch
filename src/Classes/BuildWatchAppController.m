//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "BuildWatchAppController.h"
#import "ServerReportBuilder.h"
#import "ServerReport.h"
#import "ProjectReport.h"
#import "RegexKitLite.h"
#import "SFHFKeychainUtils.h"

@class Server, Project;

static NSString * SERVER_GROUP_NAME_ALL = @"servergroups.all.label";

@interface BuildWatchAppController (Private)
- (void) setActiveServerGroupName:(NSString *) activeServer;
- (void) setActiveProjectId:(NSString *) activeProjectId;
- (void) setServers:(NSDictionary *)newServers;
- (void) setServerGroupPatterns:(NSDictionary *)newServerGroupPatterns;
- (void) setServerNames:(NSDictionary *)newServerNames;
- (void) setServerDashboardLinks:(NSDictionary *)newDashboardLinks;
- (void) setServerGroupSortOrder:(NSArray *)serverGroupNames;
- (void) setServerUsernames:(NSDictionary *)newServerUsernames;
- (void) setServerPasswords:(NSDictionary *)newServerPasswords;
- (void) setProjectDisplayNames:(NSDictionary *)newProjectDisplayNames;
- (void) setProjectLabels:(NSDictionary *)newProjectLabels;
- (void) setProjectDescriptions:(NSDictionary *)newProjectDescriptions;
- (void) setProjectPubDates:(NSDictionary *)newProjectPubDates;
- (void) setProjectLinks:(NSDictionary *)newProjectLinks;
- (void) setProjectForceBuildLinks:(NSDictionary *)newProjectForceBuildLinks;
- (void) setProjectBuildSucceededStates:
    (NSDictionary *)newProjectBuildSucceededStates;
- (void) setProjectTrackedStates:(NSDictionary *)newProjectTrackedStates;
- (void) setServerReportBuilders:(NSDictionary *)newServerReportBuilders;
- (void) updatePropertiesForProjectReports:(NSArray *)projectReports
                                withServer:(NSString *)server;
- (void) removeMissingProjectPropertiesWithProjects:(NSArray *)newProjects
                                          andServer:(NSString *)server;
- (NSArray *) serversMatchingGroupName:(NSString *)groupName;
- (NSArray *) projectIdsForServer:(NSString *)server;
- (NSArray *) projectIdsForServerGroupName:(NSString *)serverGroupName;
- (NSArray *) sortedServerGroupNames;
- (void) loadPasswordsFromKeychain;
- (void) savePasswordsToKeychain;
+ (NSString *) keyForProject:(NSString *)project andServer:(NSString *)server;
@end

@implementation BuildWatchAppController

@synthesize persistentStore;
@synthesize serverGroupNameSelector;
@synthesize projectSelector;
@synthesize projectReporter;
@synthesize serverGroupCreator;
@synthesize serverGroupEditor;
@synthesize buildService;
@synthesize serverDataRefresherDelegate;

- (void) dealloc
{
    [servers release];
    [serverGroupPatterns release];
    [serverNames release];
    [serverDashboardLinks release];
    [serverGroupSortOrder release];
    [serverUsernames release];
    [serverPasswords release];
    [serverGroupNameSelector release];
    [projectSelector release];
    [projectReporter release];
    [projectDisplayNames release];
    [projectLabels release];
    [projectDescriptions release];
    [projectPubDates release];
    [projectLinks release];
    [projectForceBuildLinks release];
    [projectBuildSucceededStates release];
    [projectTrackedStates release];
    [serverReportBuilders release];
    [persistentStore release];
    [serverGroupCreator release];
    [serverGroupEditor release];
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
    [self setServerDashboardLinks:[persistentStore getServerDashboardLinks]];
    [self setServerGroupSortOrder:[persistentStore getServerGroupSortOrder]];
    
    [self setServerUsernames:[persistentStore getServerUsernames]];
    [self loadPasswordsFromKeychain];
        
    [self setProjectDisplayNames:[persistentStore getProjectDisplayNames]];
    [self setProjectLabels:[persistentStore getProjectLabels]];
    [self setProjectDescriptions:[persistentStore getProjectDescriptions]];
    [self setProjectPubDates:[persistentStore getProjectPubDates]];
    [self setProjectLinks:[persistentStore getProjectLinks]];
    [self setProjectForceBuildLinks:
     [persistentStore getProjectForceBuildLinks]];

    [self setProjectBuildSucceededStates:
     [persistentStore getProjectBuildSucceededStates]];
    
    [self setProjectTrackedStates:[persistentStore getProjectTrackedStates]];

    [self setServerReportBuilders:[persistentStore getServerReportBuilders]];
    
    [self refreshAllServerData];

    [serverGroupNameSelector
     selectServerGroupNamesFrom:[self sortedServerGroupNames] animated:NO];
    
    [self setActiveServerGroupName:[persistentStore getActiveServerGroupName]];
    [self setActiveProjectId:[persistentStore getActiveProjectId]];
    
    if (servers.count == 0)
        [serverGroupCreator createServerGroup];
    else if (activeServerGroupName) {
        NSArray * activeProjectIds =
            [self projectIdsForServerGroupName:activeServerGroupName];
        [projectSelector selectProjectFrom:activeProjectIds animated:NO];
        
        if (activeProjectId)
            [projectReporter reportDetailsForProject:activeProjectId
                                            animated:NO];
    }
}

- (void) persistState
{
    [persistentStore saveServers:servers];
    [persistentStore saveServerGroupPatterns:serverGroupPatterns];
    [persistentStore saveServerNames:serverNames];
    [persistentStore saveServerDashboardLinks:serverDashboardLinks];
    [persistentStore saveServerGroupSortOrder:serverGroupSortOrder];
    [persistentStore saveServerUsernames:serverUsernames];
    [self savePasswordsToKeychain];
    [persistentStore saveProjectDisplayNames:projectDisplayNames];
    [persistentStore saveProjectLabels:projectLabels];
    [persistentStore saveProjectDescriptions:projectDescriptions];
    [persistentStore saveProjectPubDates:projectPubDates];
    [persistentStore saveProjectLinks:projectLinks];
    [persistentStore saveProjectForceBuildLinks:projectForceBuildLinks];
    [persistentStore saveProjectBuildSucceededStates:
     projectBuildSucceededStates];
    [persistentStore saveProjectTrackedStates:projectTrackedStates];
    [persistentStore saveActiveServerGroupName:activeServerGroupName];
    [persistentStore saveActiveProjectId:activeProjectId];
}

#pragma mark BuildServiceDelegate implementation

- (void) report:(ServerReport *)report receivedFrom:(NSString *)server
{
    [serverDataRefresherDelegate
     didRefreshDataForServer:server
                 displayName:[serverNames objectForKey:server]];
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
    
        // Push updates to active view
        if ([projectIds containsObject:activeProjectId])
            [projectReporter reportDetailsForProject:activeProjectId
                                            animated:NO];
        else if (activeServerGroupName) {
            NSString * serverGroupPattern =
                [serverGroupPatterns objectForKey:activeServerGroupName];
            BOOL serverMatchesActiveGroupNameRegEx =
                [server isMatchedByRegex:serverGroupPattern];
            NSArray * projectIdsForActiveServerGroup =
                [self projectIdsForServerGroupName:activeServerGroupName];
    
            if (serverMatchesActiveGroupNameRegEx)
                [projectSelector
                 selectProjectFrom:projectIdsForActiveServerGroup animated:NO];
        } else
            [serverGroupNameSelector
             selectServerGroupNamesFrom:[self sortedServerGroupNames]
             animated:NO];
        
        [projectIds release];
    }
}

- (void) attemptToGetReportFromServer:(NSString *)serverUrl
                     didFailWithError:(NSError *)error
{
    NSLog(@"Failed to refresh server: '%@'. '%@'.", serverUrl, error);
    [serverDataRefresherDelegate
     failedToRefreshDataForServer:serverUrl
                      displayName:[serverNames objectForKey:serverUrl]
                            error:error];
}

- (NSObject<ServerReportBuilder> *) builderForServer:(NSString *)serverUrl
{
    NSEnumerator * iter = [serverReportBuilders keyEnumerator];

    for (NSString * mapping = [iter nextObject];
         mapping;
         mapping = [iter nextObject])
    {
        if ([serverUrl isMatchedByRegex:mapping]) {
            NSString * className =
                [serverReportBuilders objectForKey:mapping];

            NSLog(@"Data from '%@' will be handled by a '%@'.",
                serverUrl, className);
            Class class = NSClassFromString(className);

            return [[[class alloc] init] autorelease];
        }
    }

    return nil;
}

#pragma mark ServerSelectorDelegate protocol implementation

- (void) userDidSelectServerGroupName:(NSString *)serverGroupName
{
    NSLog(@"User selected server group name: %@.", serverGroupName);
    [self setActiveServerGroupName:serverGroupName];
    [projectSelector
     selectProjectFrom:[self projectIdsForServerGroupName:serverGroupName]
     animated:YES]; 
}

- (void) userDidDeselectServerGroupName
{
    NSLog(@"User deselected server group name: %@.", activeServerGroupName);
    [self setActiveServerGroupName:nil]; 
}

// Get the url for single-server server groups
- (NSString *) webAddressForServerGroupName:(NSString *)serverGroupName
{
    NSArray * serversInGroup = [self serversMatchingGroupName:serverGroupName];
    NSString * webAddress;
    int numServers = [serversInGroup count];
    if (numServers == 1)
        webAddress = [serversInGroup objectAtIndex:0];
    else
        webAddress =
            [NSString
             stringWithFormat:@"%@ servers",
             [NSNumber numberWithInt:numServers]];
    
    return webAddress;
}

- (int) numBrokenForServerGroupName:(NSString *)serverGroupName
{
    int numBrokenBuilds = 0;
    
    NSArray * projectIds = [self projectIdsForServerGroupName:serverGroupName];
    for (NSString * projectId in projectIds)
        if (![[projectBuildSucceededStates objectForKey:projectId] boolValue] &&
            [[projectTrackedStates objectForKey:projectId] boolValue])
            numBrokenBuilds++;
    
    return numBrokenBuilds;
}

- (BOOL) canServerGroupBeDeleted:(NSString *)serverGroupName
{
    return ![serverGroupName isEqual:
        NSLocalizedString(SERVER_GROUP_NAME_ALL, @"")];
}

- (void) deleteServerGroupWithName:(NSString *)serverGroupName
{
    NSAssert1([self canServerGroupBeDeleted:serverGroupName],
        @"Deleting server group with name '%@', but that server group can not "
        "be deleted.", serverGroupName);

    NSArray * projectIds = [self projectIdsForServer:serverGroupName];
    for (NSString * projectId in projectIds)
        [projectDisplayNames removeObjectForKey:projectId];

    [servers removeObjectForKey:serverGroupName];
    [serverNames removeObjectForKey:serverGroupName];
    [serverDashboardLinks removeObjectForKey:serverGroupName];
    [serverGroupSortOrder removeObject:serverGroupName];
    [serverUsernames removeObjectForKey:serverGroupName];
    [serverPasswords removeObjectForKey:serverGroupName];
}

- (void) createServerGroup
{
    [serverGroupCreator createServerGroup];
}

- (void) editServerGroupName:(NSString *)serverGroupName
{
    NSLog(@"User wants to edit server group: '%@'.", serverGroupName);
    [serverGroupEditor editServerGroup:serverGroupName];
}

- (void) userDidSetServerGroupSortOrder:(NSArray *)serverGroupNames
{
    [self setServerGroupSortOrder:serverGroupNames];
}

#pragma mark ServerGroupCreatorDelegate protocol implementation

- (void) serverGroupCreatedWithDisplayName:(NSString *)serverDisplayName
                     andInitialBuildReport:(ServerReport *)report
{
    NSLog(@"Server group created: '%@', initial report: '%@'.",
          serverDisplayName, report);

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
    [serverNames setObject:serverDisplayName forKey:report.link];
    [serverDashboardLinks setObject:report.dashboardLink forKey:report.link];
    [serverGroupSortOrder addObject:report.link];

    [self report:report receivedFrom:report.link];

    [serverGroupNameSelector 
     selectServerGroupNamesFrom:[self sortedServerGroupNames] animated:YES];
}

- (BOOL) isServerGroupUrlValid:(NSString *)url
{
    return [servers objectForKey:url] == nil;
}

#pragma mark ServerGroupEditorDelegate protocol implementation

- (void) changeDisplayName:(NSString *)serverGroupDisplayName
        forServerGroupName:(NSString *)serverGroupName
{
    [serverNames setObject:serverGroupDisplayName forKey:serverGroupName];
}

#pragma mark Authentication accessors

- (void) setUsername:(NSString *)username forServer:(NSString *)server
{
    [serverUsernames setObject:username forKey:server];
}

- (NSString *) usernameForServer:(NSString *)server
{
    return [serverUsernames objectForKey:server];
}

- (void) setPassword:(NSString *)password forServer:(NSString *)server
{
    [serverPasswords setObject:password forKey:server];
}

- (NSString *) passwordForServer:(NSString *)server
{
    return [serverPasswords objectForKey:server];
}

#pragma mark ProjectSelectorDelegate protocol implementation

- (void) userDidSelectProject:(NSString *)project
{
    NSLog(@"User selected project: %@.", project);
    [self setActiveProjectId:project];
    [projectReporter reportDetailsForProject:project animated:YES];
}

- (void) userDidDeselectProject
{
    NSLog(@"User deselected project: %@.", activeProjectId);
    [self setActiveProjectId:nil];
}

#pragma mark ServerGroupPropertyProvider protocol implementation

- (NSString *) displayNameForServerGroupName:(NSString *)serverGroupName
{
    return [serverNames objectForKey:serverGroupName];
}

- (NSString *) linkForServerGroupName:(NSString *)serverGroupName
{
    return serverGroupName;
}

- (NSString *) dashboardLinkForServerGroupName:(NSString *)serverGroupName
{
    return [serverDashboardLinks objectForKey:serverGroupName];
}

- (NSUInteger) numberOfProjectsForServerGroupName:(NSString *)serverGroupName
{
    return [[servers objectForKey:serverGroupName] count];
}

#pragma mark ProjectPropertyProvider protocol implementation

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

- (NSString *) labelForProject:(NSString *)project
{
    return [projectLabels objectForKey:project];
}

- (NSString *) descriptionForProject:(NSString *)project
{
    return [projectDescriptions objectForKey:project];
}

- (NSDate *) pubDateForProject:(NSString *)project
{
    return [projectPubDates objectForKey:project];
}

- (NSString *) linkForProject:(NSString *)project
{
    return [projectLinks objectForKey:project];
}

- (NSString *) forceBuildLinkForProject:(NSString *)project
{
    return [projectForceBuildLinks objectForKey:project];
}

- (BOOL) buildSucceededStateForProject:(NSString *)project
{
    return [[projectBuildSucceededStates objectForKey:project] boolValue];
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
        [serverDataRefresherDelegate
         refreshingDataForServer:server
                     displayName:[serverNames objectForKey:server]];
        [buildService refreshDataForServer:server];
    }
}

#pragma mark Accessors

- (void) setActiveServerGroupName:(NSString *) server
{
    NSString * temp = [server copy];
    [activeServerGroupName release];
    activeServerGroupName = temp;
}

- (void) setActiveProjectId:(NSString *) newActiveProjectId
{
    NSString * temp = [newActiveProjectId copy];
    [activeProjectId release];
    activeProjectId = temp;
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

- (void) setServerDashboardLinks:(NSDictionary *)newDashboardLinks
{
    NSMutableDictionary * tempDashboardLinks = [newDashboardLinks mutableCopy];
    [serverDashboardLinks release];
    serverDashboardLinks = tempDashboardLinks;
}

- (void) setServerGroupSortOrder:(NSArray *)serverGroupNames
{
    NSMutableArray * temp = [serverGroupNames mutableCopy];
    [serverGroupSortOrder release];
    serverGroupSortOrder = temp;
}

- (void) setServerUsernames:(NSDictionary *)newServerUsernames
{
    NSMutableDictionary * tempServerUsernames =
        [newServerUsernames mutableCopy];
    [serverUsernames release];
    serverUsernames = tempServerUsernames;
}

- (void) setServerPasswords:(NSDictionary *)newServerPasswords
{
    NSMutableDictionary * tempServerPasswords =
        [newServerPasswords mutableCopy];
    [serverPasswords release];
    serverPasswords = tempServerPasswords;
}

- (void) setProjectDisplayNames:(NSDictionary *)newProjectDisplayNames;
{
    NSMutableDictionary * tempProjectDisplayNames =
        [newProjectDisplayNames mutableCopy];
    [projectDisplayNames release];
    projectDisplayNames = tempProjectDisplayNames;
}

- (void) setProjectLabels:(NSDictionary *)newProjectLabels
{
    NSMutableDictionary * tempProjectLabels =
        [newProjectLabels mutableCopy];
    [projectLabels release];
    projectLabels = tempProjectLabels;
    
}

- (void) setProjectDescriptions:(NSDictionary *)newProjectDescriptions
{
    NSMutableDictionary * tempProjectDescriptions =
        [newProjectDescriptions mutableCopy];
    [projectDescriptions release];
    projectDescriptions = tempProjectDescriptions;
}

- (void) setProjectPubDates:(NSDictionary *)newProjectPubDates
{
    NSMutableDictionary * tempProjectPubDates =
        [newProjectPubDates mutableCopy];
    [projectPubDates release];
    projectPubDates = tempProjectPubDates;
}

- (void) setProjectLinks:(NSDictionary *)newProjectLinks
{
    NSMutableDictionary * tempProjectLinks = [newProjectLinks mutableCopy];
    [projectLinks release];
    projectLinks = tempProjectLinks;
}

- (void) setProjectForceBuildLinks:(NSDictionary *)newProjectForceBuildLinks
{
    NSMutableDictionary * tempProjectForceBuildLinks =
        [newProjectForceBuildLinks mutableCopy];
    [projectForceBuildLinks release];
    projectForceBuildLinks = tempProjectForceBuildLinks;
}

- (void) setProjectBuildSucceededStates:
    (NSDictionary *)newProjectBuildSucceededStates
{
    NSMutableDictionary * tempProjectBuildSucceededStates =
        [newProjectBuildSucceededStates mutableCopy];
    [projectBuildSucceededStates release];
    projectBuildSucceededStates = tempProjectBuildSucceededStates;
}

- (void) setProjectTrackedStates:(NSDictionary *)newProjectTrackedStates
{
    NSMutableDictionary * tempProjectTrackedStates =
        [newProjectTrackedStates mutableCopy];
    [projectTrackedStates release];
    projectTrackedStates = tempProjectTrackedStates;
}

- (void) setServerReportBuilders:(NSDictionary *)newServerReportBuilders
{
    NSMutableDictionary * tempServerReportBuilders =
        [newServerReportBuilders mutableCopy];
    [serverReportBuilders release];
    serverReportBuilders = tempServerReportBuilders;
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
        [projectLabels setObject:projReport.label forKey:projectKey];
        [projectDescriptions setObject:projReport.description
                                forKey:projectKey];
        [projectPubDates setObject:projReport.pubDate forKey:projectKey];
        [projectLinks setObject:projReport.link forKey:projectKey];
        [projectForceBuildLinks setObject:projReport.forceBuildLink
                                   forKey:projectKey];
        [projectBuildSucceededStates setObject:
         [NSNumber numberWithBool:projReport.buildSucceeded]
                                        forKey:projectKey];
        
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
    [projectLabels removeObjectsForKeys:missingProjectIds];
    [projectDescriptions removeObjectsForKeys:missingProjectIds];
    [projectPubDates removeObjectsForKeys:missingProjectIds];
    [projectLinks removeObjectsForKeys:missingProjectIds];
    [projectForceBuildLinks removeObjectsForKeys:missingProjectIds];
    [projectBuildSucceededStates removeObjectsForKeys:missingProjectIds];
    [projectTrackedStates removeObjectsForKeys:missingProjectIds];
    
    [missingProjectIds release];
}

- (NSArray *) sortedServerGroupNames
{
    NSMutableArray * serverGroupNames =
        [[serverGroupSortOrder mutableCopy] autorelease];
    [serverGroupNames
        insertObject:NSLocalizedString(SERVER_GROUP_NAME_ALL, @"")
             atIndex:0];

    return serverGroupNames;
}

- (NSArray *) serversMatchingGroupName:(NSString *)groupName
{
    NSMutableArray * matchingServers = [NSMutableArray array];
    for(NSString * server in [servers allKeys]) {
        NSString * serverGroupPattern =
        [serverGroupPatterns objectForKey:groupName];
        
        if ([server isMatchedByRegex:serverGroupPattern])
            [matchingServers addObject:server];
    }
    
    return matchingServers;
}

- (void) loadPasswordsFromKeychain
{
    [self setServerPasswords:[[NSMutableDictionary alloc] init]];
    for (NSString * server in [serverUsernames allKeys]) {
        NSString * username = [serverUsernames objectForKey:server];
        NSError * error;
        NSString * password =
            [SFHFKeychainUtils getPasswordForUsername:username
                                       andServiceName:server
                                                error:&error];
        
        if (!error)
            NSLog([error description]);
        else
            [serverPasswords setObject:password forKey:server];
    }
}

- (void) savePasswordsToKeychain
{
    for (NSString * server in [serverUsernames allKeys]) {
        NSString * username = [serverUsernames objectForKey:server];
        NSString * password = [serverPasswords objectForKey:server];
        
        NSError * error;
        [SFHFKeychainUtils storeUsername:username
                             andPassword:password
                          forServiceName:server
                          updateExisting:YES
                                   error:&error];
        
        if (!error)
            NSLog([error description]);
    }
}

#pragma mark static utility functions

+ (NSString *) keyForProject:(NSString *)project andServer:(NSString *)server
{
    return [NSString stringWithFormat:@"%@|%@", server, project];
}

@end
