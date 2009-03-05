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

@interface BuildWatchAppController (Private)

- (void) setActiveServerGroupName:(NSString *) activeServer;
- (void) setActiveProjectId:(NSString *) activeProjectId;

- (void) setServerKeys:(NSArray *)newServerKeys;
- (void) setServerDashboardLinks:(NSDictionary *)newDashboardLinks;
- (void) setServerUsernames:(NSDictionary *)newServerUsernames;
- (void) setServerPasswords:(NSDictionary *)newServerPasswords;

- (void) setServerGroupNames:(NSDictionary *)newServerGroupNames;
- (void) setServerGroupPatterns:(NSDictionary *)newServerGroupPatterns;
- (void) setServerGroupRemovableStates:
    (NSDictionary *)newServerGroupRemovableStates;
- (void) setServerGroupSortOrder:(NSArray *)serverGroupNames;

- (void) setProjectKeys:(NSArray *)newProjectKeys;
- (void) setProjectNames:(NSDictionary *)newProjectNames;
- (void) setProjectServerKeys:(NSDictionary *)newProjectServerKeys;
- (void) setProjectForceBuildLinks:(NSDictionary *)newProjectForceBuildLinks;
- (void) setProjectTrackedStates:(NSDictionary *)newProjectTrackedStates;

- (void) setBuildLabels:(NSDictionary *)newBuildLabels;
- (void) setBuildDescriptions:(NSDictionary *)newBuildDescriptions;
- (void) setBuildPubDates:(NSDictionary *)newBuildPubDates;
- (void) setBuildSucceededStates:(NSDictionary *)newbuildSucceededStates;
- (void) setBuildReportLinks:(NSDictionary *)newBuildLinks;

- (void) setServerReportBuilders:(NSDictionary *)newServerReportBuilders;
- (void) updatePropertiesForProjectReports:(NSArray *)projectReports
                                withServer:(NSString *)server;
- (void) removeMissingProjectWithKeys:(NSArray *)newProjects
                                          andServer:(NSString *)server;
- (void) removeProjectWithKeys:(NSArray *) removedProjectKeys;
- (NSArray *) serversMatchingGroupKey:(NSString *)groupName;
- (NSArray *) projectKeysForServer:(NSString *)server;
- (NSArray *) projectKeysForServerGroupKey:(NSString *)serverGroupName;
- (NSArray *) sortedServerGroups;
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
    [serverKeys release];
    [serverDashboardLinks release];
    [serverUsernames release];
    [serverPasswords release];
    
    [serverGroupPatterns release];
    [serverGroupRemovableStates release];
    [serverGroupNames release];
    [serverGroupSortOrder release];
    
    [projectKeys release];
    [projectNames release];
    [projectServerKeys release];
    [projectForceBuildLinks release];
    [projectTrackedStates release];
    
    [buildLabels release];
    [buildDescriptions release];
    [buildPubDates release];
    [buildReportLinks release];
    [buildSucceededStates release];
    
    [serverGroupNameSelector release];
    [projectSelector release];
    [projectReporter release];
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
     selectServerGroupsFrom:[self sortedServerGroups] animated:NO];
    
    [self setActiveServerGroupName:
     [persistentStore getActiveServerGroupName]];
    [self setActiveProjectId:[persistentStore getActiveProjectId]];
    
    if (serverKeys.count == 0)
        [serverGroupCreator createServerGroup];
    else if (activeServerGroupName) {
        NSArray * activeProjectIds =
        [self projectKeysForServerGroupKey:activeServerGroupName];
        [projectSelector selectProjectFrom:activeProjectIds animated:NO];
        
        NSArray * projectsForServerGroup =
        [self projectKeysForServerGroupKey:activeServerGroupName];
        if (activeProjectId &&
            [projectsForServerGroup containsObject:activeProjectId])
            [projectReporter reportDetailsForProject:activeProjectId
                                            animated:NO];
    }
}

- (void) persistState
{
    [persistentStore saveServerKeys:serverKeys];
    [persistentStore saveServerDashboardLinks:serverDashboardLinks];
    [persistentStore saveServerUsernames:serverUsernames];
    [self savePasswordsToKeychain];
    
    [persistentStore saveServerGroupPatterns:serverGroupPatterns];
    [persistentStore saveServerGroupNames:serverGroupNames];
    [persistentStore saveServerGroupRemovableStates:serverGroupRemovableStates];
    [persistentStore saveServerGroupSortOrder:serverGroupSortOrder];

    [persistentStore saveProjectKeys:projectKeys];
    [persistentStore saveProjectServerKeys:projectServerKeys];
    [persistentStore saveProjectNames:projectNames];
    [persistentStore saveProjectForceBuildLinks:projectForceBuildLinks];
    [persistentStore saveProjectTrackedStates:projectTrackedStates];
    
    [persistentStore saveBuildLabels:buildLabels];
    [persistentStore saveBuildDescriptions:buildDescriptions];
    [persistentStore saveBuildPubDates:buildPubDates];
    [persistentStore saveBuildReportLinks:buildReportLinks];
    [persistentStore saveBuildSucceededStates:buildSucceededStates];
    
    [persistentStore saveActiveServerGroupName:activeServerGroupName];
    [persistentStore saveActiveProjectId:activeProjectId];
}

#pragma mark BuildServiceDelegate implementation

- (void) report:(ServerReport *)report receivedFrom:(NSString *)serverKey
{
    [serverDataRefresherDelegate didRefreshDataForServer:serverKey];
    
    if ([serverKeys containsObject:serverKey]) {
        [self updatePropertiesForProjectReports:[report projectReports]
                                     withServer:serverKey];

        NSMutableArray * newProjectKeys = [[NSMutableArray alloc] init];
        
        for (ProjectReport * projReport in [report projectReports]) {
            NSString * projectKey =
                [[self class] keyForProject:projReport.name
                                  andServer:serverKey];
            [newProjectKeys addObject:projectKey];
        }
        
        [self removeMissingProjectWithKeys:newProjectKeys
                                               andServer:serverKey];
    
        // Push updates to active view
        if ([newProjectKeys containsObject:activeProjectId])
            [projectReporter reportDetailsForProject:activeProjectId
                                            animated:NO];
        else if (activeServerGroupName) {
            NSString * serverGroupPattern =
                [serverGroupPatterns objectForKey:activeServerGroupName];
            BOOL serverMatchesActiveGroupNameRegEx =
                [serverKey isMatchedByRegex:serverGroupPattern];
            NSArray * projectIdsForActiveServerGroup =
                [self projectKeysForServerGroupKey:activeServerGroupName];
    
            if (serverMatchesActiveGroupNameRegEx)
                [projectSelector
                 selectProjectFrom:projectIdsForActiveServerGroup animated:NO];
        } else
            [serverGroupNameSelector
             selectServerGroupsFrom:[self sortedServerGroups]
             animated:NO];
        
        [newProjectKeys release];
    }
}

- (void) attemptToGetReportFromServer:(NSString *)serverUrl
                     didFailWithError:(NSError *)error
{
    NSLog(@"Failed to refresh server: '%@'. '%@'.", serverUrl, error);
    [serverDataRefresherDelegate
     failedToRefreshDataForServer:serverUrl error:error];
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

- (void) userDidSelectServerGroup:(NSString *)serverGroupkey
{
    NSLog(@"User selected server group name: %@.", serverGroupkey);
    [self setActiveServerGroupName:serverGroupkey];
    [projectSelector
     selectProjectFrom:[self projectKeysForServerGroupKey:serverGroupkey]
     animated:YES]; 
}

- (void) userDidDeselectServerGroup
{
    NSLog(@"User deselected server group name: %@.", activeServerGroupName);
    [self setActiveServerGroupName:nil]; 
}

// Get the url for single-server server groups
- (NSString *) webAddressForServerGroup:(NSString *)serverGroupKey
{
    NSArray * serversInGroup = [self serversMatchingGroupKey:serverGroupKey];
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

- (int) numBrokenForServerGroup:(NSString *)serverGroup
{
    int numBrokenBuilds = 0;
    
    NSArray * serverGroupProjectKeys =
        [self projectKeysForServerGroupKey:serverGroup];
    for (NSString * projectKey in serverGroupProjectKeys)
        if (![[buildSucceededStates objectForKey:projectKey] boolValue] &&
            [[projectTrackedStates objectForKey:projectKey] boolValue])
            numBrokenBuilds++;
    
    return numBrokenBuilds;
}

- (BOOL) canServerGroupBeDeleted:(NSString *)serverGroupName
{
    return
        [[serverGroupRemovableStates objectForKey:serverGroupName] boolValue];
}

- (void) deleteServerGroupWithKey:(NSString *)serverGroupKey
{
    NSAssert1([self canServerGroupBeDeleted:serverGroupKey],
        @"Deleting server group with name '%@', but that server group can not "
        "be deleted.", serverGroupKey);
        
    NSArray * matchingServerKeys =
        [self serversMatchingGroupKey:serverGroupKey];
    
    for (NSString * serverKey in matchingServerKeys) {
        [serverKeys removeObject:serverKey];
        [serverDashboardLinks removeObjectForKey:serverKey];
        [serverUsernames removeObjectForKey:serverKey];
        [serverPasswords removeObjectForKey:serverKey];
        
        NSArray * matchingProjectKeys = [self projectKeysForServer:serverKey];
        [self removeProjectWithKeys:matchingProjectKeys];
    }
    
    [serverGroupNames removeObjectForKey:serverGroupKey];
    [serverGroupPatterns removeObjectForKey:serverGroupKey];
    [serverGroupRemovableStates removeObjectForKey:serverGroupKey];
    [serverGroupSortOrder removeObject:serverGroupKey];
}

- (void) createServerGroup
{
    [serverGroupCreator createServerGroup];
}

- (void) editServerGroup:(NSString *)serverGroup
{
    NSLog(@"User wants to edit server group: '%@'.", serverGroup);
    [serverGroupEditor editServerGroup:serverGroup];
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
    [serverKeys addObject:report.key];

    [serverGroupPatterns
        setObject:[NSString stringWithFormat:@"^%@$", report.key]
           forKey:report.key];
    [serverGroupRemovableStates setObject:[NSNumber numberWithBool:YES]
                                   forKey:report.key];
    
    [serverGroupNames setObject:serverDisplayName forKey:report.key];
    [serverDashboardLinks setObject:report.dashboardLink forKey:report.key];
    [serverGroupSortOrder addObject:report.key];

    [serverDataRefresherDelegate refreshingDataForServer:report.key];
    [self report:report receivedFrom:report.key];

    [serverGroupNameSelector 
     selectServerGroupsFrom:[self sortedServerGroups] animated:YES];
}

- (BOOL) isServerGroupUrlValid:(NSString *)url
{
    return ![serverKeys containsObject:url];
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

- (NSString *) displayNameForServerGroup:(NSString *)serverGroupKey
{
    return [serverGroupNames objectForKey:serverGroupKey];
}

- (NSString *) linkForServerGroupName:(NSString *)serverGroupName
{
    return serverGroupName;
}

- (NSString *) dashboardLinkForServerGroup:(NSString *)serverGroupKey
{
    return [serverDashboardLinks objectForKey:serverGroupKey];
}

- (NSUInteger) numberOfProjectsForServerGroup:(NSString *)serverGroupKey
{
    return [[self projectKeysForServerGroupKey:serverGroupKey] count];
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
    for (NSString * server in serverKeys) {
        [serverDataRefresherDelegate refreshingDataForServer:server];
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

- (void) setServerKeys:(NSArray *)newServerKeys
{
    NSMutableArray * temp = [newServerKeys mutableCopy];
    [serverKeys release];
    serverKeys = temp;
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

- (void) setProjectKeys:(NSArray *)newProjectKeys
{
    NSMutableArray * temp = [newProjectKeys mutableCopy];
    [projectKeys release];
    projectKeys = temp;
}

- (void) setProjectNames:(NSDictionary *)newProjectNames;
{
    NSMutableDictionary * tempProjectDisplayNames =
        [newProjectNames mutableCopy];
    [projectNames release];
    projectNames = tempProjectDisplayNames;
}

- (void) setProjectServerKeys:(NSDictionary *)newProjectServerKeys;
{
    NSMutableDictionary * temp = [newProjectServerKeys mutableCopy];
    [projectServerKeys release];
    projectServerKeys = temp;
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

- (NSArray *) projectKeysForServer:(NSString *)serverKey
{
    NSMutableArray * serverProjectKeys = [NSMutableArray array];
    
    for (NSString * projectKey in projectKeys)
        if ([[projectServerKeys objectForKey:projectKey] isEqual:serverKey])
            [serverProjectKeys addObject:projectKey];
    
    return serverProjectKeys;
}

- (NSArray *) projectKeysForServerGroupKey:(NSString *)serverGroupName
{
    NSMutableArray * matchingProjectKeys =
        [[[NSMutableArray alloc] init] autorelease];
    NSString * regEx = [serverGroupPatterns objectForKey:serverGroupName];
    
    for (NSString * serverKey in serverKeys)
        if ([serverKey isMatchedByRegex:regEx]) {
            NSArray * keysForServer = [self projectKeysForServer:serverKey];
            [matchingProjectKeys addObjectsFromArray:keysForServer];
        }
    
    return matchingProjectKeys;
}

- (void) updatePropertiesForProjectReports:(NSArray *)projectReports
                                withServer:(NSString *)serverKey
{
    for (ProjectReport * projReport in projectReports) {
        NSString * projectKey =
            [[self class] keyForProject:projReport.name andServer:serverKey];
        
        if (![projectKeys containsObject:projectKey])
            [projectKeys addObject:projectKey];
        
        [projectNames setObject:projReport.name forKey:projectKey];
        [projectServerKeys setObject:serverKey forKey:projectKey];
        [projectForceBuildLinks setObject:projReport.forceBuildLink
                                   forKey:projectKey];
        
        [buildLabels setObject:projReport.buildLabel forKey:projectKey];
        [buildDescriptions setObject:projReport.buildDescription
                                forKey:projectKey];
        [buildPubDates setObject:projReport.buildPubDate forKey:projectKey];
        [buildReportLinks setObject:projReport.buildDashboardLink forKey:projectKey];
        
        [buildSucceededStates setObject:
         [NSNumber numberWithBool:projReport.buildSucceededState]
                                        forKey:projectKey];
        
        if (![projectTrackedStates objectForKey:projectKey])
            [projectTrackedStates setObject:[NSNumber numberWithBool:YES]
                                     forKey:projectKey];
    }
}

- (void) removeMissingProjectWithKeys:(NSArray *)newProjectKeys
                                          andServer:(NSString *)serverKey
{
    NSMutableArray * missingProjectKeys = [[NSMutableArray alloc] init];

    for (NSString * projectKey in projectKeys) {
        NSString * projectServer = [projectServerKeys objectForKey:projectKey];
        BOOL missing =
            [serverKey isEqual:projectServer] &&
            ![newProjectKeys containsObject:projectKey];
        if (missing)
            [missingProjectKeys addObject:projectKey];
    }
        
    [self removeProjectWithKeys:missingProjectKeys];
    
    [missingProjectKeys release];
}

- (void) removeProjectWithKeys:(NSArray *) removedProjectKeys
{
    [projectKeys removeObjectsInArray:removedProjectKeys];
    [projectNames removeObjectsForKeys:removedProjectKeys];
    [projectServerKeys removeObjectsForKeys:removedProjectKeys];
    [projectForceBuildLinks removeObjectsForKeys:removedProjectKeys];
    
    [buildLabels removeObjectsForKeys:removedProjectKeys];
    [buildDescriptions removeObjectsForKeys:removedProjectKeys];
    [buildPubDates removeObjectsForKeys:removedProjectKeys];
    [buildReportLinks removeObjectsForKeys:removedProjectKeys];
    [buildSucceededStates removeObjectsForKeys:removedProjectKeys];
}

- (NSArray *) sortedServerGroups
{
    return [[serverGroupSortOrder mutableCopy] autorelease];
}

- (NSArray *) serversMatchingGroupKey:(NSString *)serverGroupKey
{
    NSMutableArray * matchingServers = [NSMutableArray array];
    for(NSString * serverKey in serverKeys) {
        NSString * serverGroupPattern =
            [serverGroupPatterns objectForKey:serverGroupKey];
        
        if ([serverKey isMatchedByRegex:serverGroupPattern])
            [matchingServers addObject:serverKey];
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
    [self setServerKeys:[persistentStore getServerKeys]];
    [self setServerDashboardLinks:[persistentStore getServerDashboardLinks]];
    [self setServerUsernames:[persistentStore getServerUsernames]];
    [self loadPasswordsFromKeychain];
    
    [self setServerGroupPatterns:[persistentStore getServerGroupPatterns]];
    [self setServerGroupNames:[persistentStore getServerGroupNames]];
    [self setServerGroupRemovableStates:
        [persistentStore getServerGroupRemovableStates]];
    [self setServerGroupSortOrder:[persistentStore getServerGroupSortOrder]];
    
    [self setProjectKeys:[persistentStore getProjectKeys]];
    [self setProjectNames:[persistentStore getProjectNames]];
    [self setProjectServerKeys:[persistentStore getProjectServerKeys]];
    [self setProjectForceBuildLinks:
     [persistentStore getProjectForceBuildLinks]];
    [self setProjectTrackedStates:[persistentStore getProjectTrackedStates]];
    
    [self setBuildLabels:[persistentStore getBuildLabels]];
    [self setBuildDescriptions:[persistentStore getBuildDescriptions]];
    [self setBuildPubDates:[persistentStore getBuildPubDates]];
    [self setBuildReportLinks:[persistentStore getBuildReportLinks]];
    [self setBuildSucceededStates:[persistentStore getBuildSucceededStates]];
    
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
