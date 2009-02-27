//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "BuildWatchAppController.h"
#import "ServerReportBuilder.h"
#import "ServerReport.h"
#import "ProjectReport.h"
#import "RegexKitLite.h"
#import "SFHFKeychainUtils.h"
#import "PListUtils.h"
#import "InconsistentStateAlertViewDelegate.h"

@class Server, Project;

static NSString * SERVER_GROUP_NAME_ALL = @"servergroups.all.label";

@interface BuildWatchAppController (Private)

- (void) setActiveServerGroupName:(NSString *) activeServer;
- (void) setActiveProjectId:(NSString *) activeProjectId;

- (void) setServers:(NSDictionary *)newServers;
- (void) setServerDashboardLinks:(NSDictionary *)newDashboardLinks;
- (void) setServerUsernames:(NSDictionary *)newServerUsernames;
- (void) setServerPasswords:(NSDictionary *)newServerPasswords;

- (void) setServerGroupNames:(NSDictionary *)newServerGroupNames;
- (void) setServerGroupPatterns:(NSDictionary *)newServerGroupPatterns;
- (void) setServerGroupRemovableStates:
    (NSDictionary *)newServerGroupRemovableStates;
- (void) setServerGroupSortOrder:(NSArray *)serverGroupNames;

- (void) setProjectNames:(NSDictionary *)newProjectNames;
- (void) setProjectForceBuildLinks:(NSDictionary *)newProjectForceBuildLinks;

- (void) setBuildLabels:(NSDictionary *)newBuildLabels;
- (void) setBuildDescriptions:(NSDictionary *)newBuildDescriptions;
- (void) setBuildPubDates:(NSDictionary *)newBuildPubDates;
- (void) setBuildSucceededStates:(NSDictionary *)newbuildSucceededStates;
- (void) setBuildReportLinks:(NSDictionary *)newBuildLinks;

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
- (void) loadStateFromPersistenceStore;
- (BOOL) serverStateIsConsistent;
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
    [serverGroupRemovableStates release];
    [serverGroupNames release];
    [serverDashboardLinks release];
    [serverGroupSortOrder release];
    [serverUsernames release];
    [serverPasswords release];
    [serverGroupNameSelector release];
    [projectSelector release];
    [projectReporter release];
    [projectNames release];
    [buildLabels release];
    [buildDescriptions release];
    [buildPubDates release];
    [buildReportLinks release];
    [projectForceBuildLinks release];
    [buildSucceededStates release];
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
    [self loadStateFromPersistenceStore];
    if (![self serverStateIsConsistent]) {
        NSString * alertMsg =
            NSLocalizedString(@"inconsistentstate.alert.message", @"");
        NSString * title =
        NSLocalizedString(@"inconsistentstate.alert.title", @"");
        InconsistentStateAlertViewDelegate * alertDelegate =
            [[InconsistentStateAlertViewDelegate alloc]
            initWithAppController:self andPersistentStore:persistentStore];
        UIAlertView * alertView =
            [[UIAlertView alloc] initWithTitle:title message:alertMsg
            delegate:alertDelegate
            cancelButtonTitle:
            NSLocalizedString(@"inconsistentstate.alert.restore", @"")
            otherButtonTitles:
            NSLocalizedString(@"inconsistentstate.alert.ignore", @""), nil];
        [alertView show];
        [alertView release];
    } else
        [self refreshDataAndDisplayInitialView];
}

- (void) refreshDataAndDisplayInitialView
{
    [self refreshAllServerData];
    
    [serverGroupNameSelector
     selectServerGroupNamesFrom:[self sortedServerGroupNames] animated:NO];
    
    [self setActiveServerGroupName:
     [persistentStore getActiveServerGroupName]];
    [self setActiveProjectId:[persistentStore getActiveProjectId]];
    
    if (servers.count == 0)
        [serverGroupCreator createServerGroup];
    else if (activeServerGroupName) {
        NSArray * activeProjectIds =
        [self projectIdsForServerGroupName:activeServerGroupName];
        [projectSelector selectProjectFrom:activeProjectIds animated:NO];
        
        NSArray * projectsForServerGroup =
        [self projectIdsForServerGroupName:activeServerGroupName];
        if (activeProjectId &&
            [projectsForServerGroup containsObject:activeProjectId])
            [projectReporter reportDetailsForProject:activeProjectId
                                            animated:NO];
    }
}

- (void) persistState
{
    [persistentStore saveServers:servers];
    [persistentStore saveServerGroupPatterns:serverGroupPatterns];
    [persistentStore saveServerGroupNames:serverGroupNames];
    [persistentStore saveServerGroupRemovableStates:serverGroupRemovableStates];
    [persistentStore saveServerDashboardLinks:serverDashboardLinks];
    [persistentStore saveServerGroupSortOrder:serverGroupSortOrder];
    [persistentStore saveServerUsernames:serverUsernames];
    [self savePasswordsToKeychain];
    [persistentStore saveProjectNames:projectNames];
    [persistentStore saveBuildLabels:buildLabels];
    [persistentStore saveBuildDescriptions:buildDescriptions];
    [persistentStore saveBuildPubDates:buildPubDates];
    [persistentStore saveBuildReportLinks:buildReportLinks];
    [persistentStore saveProjectForceBuildLinks:projectForceBuildLinks];
    [persistentStore saveBuildSucceededStates:
     buildSucceededStates];
    [persistentStore saveProjectTrackedStates:projectTrackedStates];
    [persistentStore saveActiveServerGroupName:activeServerGroupName];
    [persistentStore saveActiveProjectId:activeProjectId];
}

#pragma mark BuildServiceDelegate implementation

- (void) report:(ServerReport *)report receivedFrom:(NSString *)server
{
    [serverDataRefresherDelegate
     didRefreshDataForServer:server
                 displayName:[serverGroupNames objectForKey:server]];
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
                      displayName:[serverGroupNames objectForKey:serverUrl]
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

- (void) userDidSelectServerGroupName:(NSString *)serverGroupkey
{
    NSLog(@"User selected server group name: %@.", serverGroupkey);
    [self setActiveServerGroupName:serverGroupkey];
    [projectSelector
     selectProjectFrom:[self projectIdsForServerGroupName:serverGroupkey]
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
        if (![[buildSucceededStates objectForKey:projectId] boolValue] &&
            [[projectTrackedStates objectForKey:projectId] boolValue])
            numBrokenBuilds++;
    
    return numBrokenBuilds;
}

- (BOOL) canServerGroupBeDeleted:(NSString *)serverGroupName
{
    return
        [[serverGroupRemovableStates objectForKey:serverGroupName] boolValue];
}

- (void) deleteServerGroupWithName:(NSString *)serverGroupName
{
    NSAssert1([self canServerGroupBeDeleted:serverGroupName],
        @"Deleting server group with name '%@', but that server group can not "
        "be deleted.", serverGroupName);

    NSArray * projectIds = [self projectIdsForServer:serverGroupName];
    for (NSString * projectId in projectIds)
        [projectNames removeObjectForKey:projectId];

    [servers removeObjectForKey:serverGroupName];
    [serverGroupNames removeObjectForKey:serverGroupName];
    [serverGroupPatterns removeObjectForKey:serverGroupName];
    [serverGroupRemovableStates removeObjectForKey:serverGroupName];
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

- (void) userDidSetServerGroupSortOrder:(NSArray *)newServerGroupNames
{
    [self setServerGroupSortOrder:newServerGroupNames];
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

    NSMutableArray * reportProjectNames = [NSMutableArray array];
    for (ProjectReport * projectReport in report.projectReports)
        [reportProjectNames addObject:projectReport.name];
    [servers setObject:reportProjectNames forKey:report.link];

    [serverGroupPatterns
        setObject:[NSString stringWithFormat:@"^%@$", report.link]
           forKey:report.link];
    [serverGroupRemovableStates setObject:[NSNumber numberWithBool:YES]
                                   forKey:report.link];
    
    [serverGroupNames setObject:serverDisplayName forKey:report.link];
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
    [serverGroupNames setObject:serverGroupDisplayName forKey:serverGroupName];
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
    return [serverGroupNames objectForKey:serverGroupName];
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
    return [projectNames objectForKey:project];
}

- (NSString *) labelForProject:(NSString *)project
{
    return [buildLabels objectForKey:project];
}

- (NSString *) descriptionForProject:(NSString *)project
{
    return [buildDescriptions objectForKey:project];
}

- (NSDate *) pubDateForProject:(NSString *)project
{
    return [buildPubDates objectForKey:project];
}

- (NSString *) linkForProject:(NSString *)project
{
    return [buildReportLinks objectForKey:project];
}

- (NSString *) forceBuildLinkForProject:(NSString *)project
{
    return [projectForceBuildLinks objectForKey:project];
}

- (BOOL) buildSucceededStateForProject:(NSString *)project
{
    return [[buildSucceededStates objectForKey:project] boolValue];
}

- (NSString *) displayNameForCurrentProjectGroup
{
    return [serverGroupNames objectForKey:activeServerGroupName];
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
                     displayName:[serverGroupNames objectForKey:server]];
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

- (void) setServerGroupRemovableStates:
    (NSDictionary *)newServerGroupRemovableStates
{
    NSMutableDictionary * tempServerGroupRemovableStates =
        [newServerGroupRemovableStates mutableCopy];
    [serverGroupRemovableStates release];
    serverGroupRemovableStates = tempServerGroupRemovableStates;
}

- (void) setServerGroupPatterns:(NSDictionary *)newServerGroupPatterns
{
    NSMutableDictionary * tempGroupNamePatterns =
        [newServerGroupPatterns mutableCopy];
    [serverGroupPatterns release];
    serverGroupPatterns = tempGroupNamePatterns;
}

- (void) setServerGroupNames:(NSDictionary *)newServerGroupNames
{
    NSMutableDictionary * tempServerNames = [newServerGroupNames mutableCopy];
    [serverGroupNames release];
    serverGroupNames = tempServerNames;
}

- (void) setServerDashboardLinks:(NSDictionary *)newServerDashboardLinks
{
    NSMutableDictionary * tempDashboardLinks =
        [newServerDashboardLinks mutableCopy];
    [serverDashboardLinks release];
    serverDashboardLinks = tempDashboardLinks;
}

- (void) setServerGroupSortOrder:(NSArray *)newServerGroupSortOrder
{
    NSMutableArray * temp = [newServerGroupSortOrder mutableCopy];
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

- (void) setProjectNames:(NSDictionary *)newProjectNames;
{
    NSMutableDictionary * tempProjectDisplayNames =
        [newProjectNames mutableCopy];
    [projectNames release];
    projectNames = tempProjectDisplayNames;
}

- (void) setBuildLabels:(NSDictionary *)newBuildLabels
{
    NSMutableDictionary * tempProjectLabels = [newBuildLabels mutableCopy];
    [buildLabels release];
    buildLabels = tempProjectLabels;
}

- (void) setBuildDescriptions:(NSDictionary *)newBuildDescriptions
{
    NSMutableDictionary * tempProjectDescriptions =
        [newBuildDescriptions mutableCopy];
    [buildDescriptions release];
    buildDescriptions = tempProjectDescriptions;
}

- (void) setBuildPubDates:(NSDictionary *)newBuildPubDates
{
    NSMutableDictionary * tempProjectPubDates =
        [newBuildPubDates mutableCopy];
    [buildPubDates release];
    buildPubDates = tempProjectPubDates;
}

- (void) setBuildReportLinks:(NSDictionary *)newBuildReportLinks
{
    NSMutableDictionary * tempProjectLinks = [newBuildReportLinks mutableCopy];
    [buildReportLinks release];
    buildReportLinks = tempProjectLinks;
}

- (void) setProjectForceBuildLinks:(NSDictionary *)newProjectForceBuildLinks
{
    NSMutableDictionary * tempProjectForceBuildLinks =
        [newProjectForceBuildLinks mutableCopy];
    [projectForceBuildLinks release];
    projectForceBuildLinks = tempProjectForceBuildLinks;
}

- (void) setBuildSucceededStates:
    (NSDictionary *)newProjectBuildSucceededStates
{
    NSMutableDictionary * tempProjectBuildSucceededStates =
        [newProjectBuildSucceededStates mutableCopy];
    [buildSucceededStates release];
    buildSucceededStates = tempProjectBuildSucceededStates;
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
        
        [projectNames setObject:projReport.name forKey:projectKey];
        [buildLabels setObject:projReport.label forKey:projectKey];
        [buildDescriptions setObject:projReport.description
                                forKey:projectKey];
        [buildPubDates setObject:projReport.pubDate forKey:projectKey];
        [buildReportLinks setObject:projReport.link forKey:projectKey];
        [projectForceBuildLinks setObject:projReport.forceBuildLink
                                   forKey:projectKey];
        [buildSucceededStates setObject:
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
    
    [projectNames removeObjectsForKeys:missingProjectIds];
    [buildLabels removeObjectsForKeys:missingProjectIds];
    [buildDescriptions removeObjectsForKeys:missingProjectIds];
    [buildPubDates removeObjectsForKeys:missingProjectIds];
    [buildReportLinks removeObjectsForKeys:missingProjectIds];
    [projectForceBuildLinks removeObjectsForKeys:missingProjectIds];
    [buildSucceededStates removeObjectsForKeys:missingProjectIds];
    
    [missingProjectIds release];
}

- (NSArray *) sortedServerGroupNames
{
    NSMutableArray * tempServerGroupNames =
        [[serverGroupSortOrder mutableCopy] autorelease];
    [tempServerGroupNames
        insertObject:NSLocalizedString(SERVER_GROUP_NAME_ALL, @"")
             atIndex:0];

    return tempServerGroupNames;
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

- (void) loadStateFromPersistenceStore
{
    [self setServers:[persistentStore getServers]];
    [self setServerDashboardLinks:[persistentStore getServerDashboardLinks]];
    
    [self setServerGroupPatterns:[persistentStore getServerGroupPatterns]];
    [self setServerGroupNames:[persistentStore getServerGroupNames]];
    [self setServerGroupRemovableStates:
        [persistentStore getServerGroupRemovableStates]];
    [self setServerGroupSortOrder:[persistentStore getServerGroupSortOrder]];
    
    [self setServerUsernames:[persistentStore getServerUsernames]];
    [self loadPasswordsFromKeychain];
    
    [self setProjectNames:[persistentStore getProjectNames]];
    [self setBuildLabels:[persistentStore getBuildLabels]];
    [self setBuildDescriptions:[persistentStore getBuildDescriptions]];
    [self setBuildPubDates:[persistentStore getBuildPubDates]];
    [self setBuildReportLinks:[persistentStore getBuildReportLinks]];
    [self setProjectForceBuildLinks:
     [persistentStore getProjectForceBuildLinks]];
    
    [self setBuildSucceededStates:
     [persistentStore getBuildSucceededStates]];
    
    [self setProjectTrackedStates:[persistentStore getProjectTrackedStates]];
    
    NSString * fullPath =
    [PlistUtils fullBundlePathForPlist:@"ServerReportBuilders"];
    [self setServerReportBuilders:
     [PlistUtils readDictionaryFromPlist:fullPath]];
}

- (BOOL) serverStateIsConsistent
{
    return [serverGroupNames count] == [serverGroupPatterns count];
}

#pragma mark static utility functions

+ (NSString *) keyForProject:(NSString *)project andServer:(NSString *)server
{
    return [NSString stringWithFormat:@"%@|%@", server, project];
}

@end
