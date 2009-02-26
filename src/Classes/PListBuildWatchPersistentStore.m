//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "PListBuildWatchPersistentStore.h"

@interface PlistBuildWatchPersistentStore (Private)

+ (NSDictionary *) getDictionaryFromPlist:(NSString *)plist;
+ (void) saveDictionary:dictionary toPlist:(NSString *)plist;
+ (NSArray *) getArrayFromPlist:(NSString *)plist;
+ (void) saveArray:(NSArray *)array toPlist:(NSString *)plist;
+ (void) removePlistAndCopyDefaultFromBundle:(NSString *)plist;

@end

@implementation PlistBuildWatchPersistentStore

#pragma mark BuildWatchPersistentStore implementation

- (void) saveServers:(NSDictionary *)servers
{
    [[self class] saveDictionary:servers toPlist:@"Servers"];
}

- (NSDictionary *) getServers
{
    return [[self class] getDictionaryFromPlist:@"Servers"];
}

- (void) saveServerGroupPatterns:(NSDictionary *)serverGroupPatterns
{
    [[self class] saveDictionary:serverGroupPatterns
                         toPlist:@"ServerGroupPatterns"];
}

- (NSDictionary *) getServerGroupPatterns
{
    return [[self class] getDictionaryFromPlist:@"ServerGroupPatterns"];
}

- (void) saveServerNames:(NSDictionary *)serverNames
{
    [[self class] saveDictionary:serverNames toPlist:@"ServerNames"];
}

- (NSDictionary *) getServerNames
{
    return [[self class] getDictionaryFromPlist:@"ServerNames"];
}

- (void) saveServerDashboardLinks:(NSDictionary *)dashboardLinks
{
    [[self class] saveDictionary:dashboardLinks
                         toPlist:@"ServerDashboardLinks"];
}

- (NSDictionary *) getServerDashboardLinks
{
    return [[self class] getDictionaryFromPlist:@"ServerDashboardLinks"];
}

- (void) saveServerGroupSortOrder:(NSArray *)serverGroupNames
{
    [[self class] saveArray:serverGroupNames toPlist:@"ServerGroupSortOrder"];
}

- (NSArray *) getServerGroupSortOrder
{
    return [[self class] getArrayFromPlist:@"ServerGroupSortOrder"];
}

- (void) saveServerUsernames:(NSDictionary *)serverNames
{
    [[self class] saveDictionary:serverNames toPlist:@"ServerUsernames"];
}

- (NSDictionary *) getServerUsernames
{
    return [[self class] getDictionaryFromPlist:@"ServerUsernames"];
}

- (void) saveProjectDisplayNames:(NSDictionary *)projectDisplayNames
{
    [[self class] saveDictionary:projectDisplayNames
                         toPlist:@"ProjectDisplayNames"];
}

- (NSDictionary *) getProjectDisplayNames
{
    return [[self class] getDictionaryFromPlist:@"ProjectDisplayNames"];
}

- (void) saveProjectLabels:(NSDictionary *)projectLabels
{
    [[self class] saveDictionary:projectLabels toPlist:@"ProjectLabels"];
}

- (NSDictionary *) getProjectLabels
{
    return [[self class] getDictionaryFromPlist:@"ProjectLabels"];
}

- (void) saveProjectDescriptions:(NSDictionary *)projectDescriptions
{
    [[self class] saveDictionary:projectDescriptions
                         toPlist:@"ProjectDescriptions"];
}

- (NSDictionary *) getProjectDescriptions
{
    return [[self class] getDictionaryFromPlist:@"ProjectDescriptions"];
}

- (void) saveProjectPubDates:(NSDictionary *)projectPubDates
{
    [[self class] saveDictionary:projectPubDates toPlist:@"ProjectPubDates"];
}

- (NSDictionary *) getProjectPubDates
{
    return [[self class] getDictionaryFromPlist:@"ProjectPubDates"];
}

- (void) saveProjectLinks:(NSDictionary *)projectLinks
{
    [[self class] saveDictionary:projectLinks toPlist:@"ProjectLinks"];
}

- (NSDictionary *) getProjectLinks
{
    return [[self class] getDictionaryFromPlist:@"ProjectLinks"];
}

- (void) saveProjectForceBuildLinks:(NSDictionary *)projectForceBuildLinks
{
    [[self class] saveDictionary:projectForceBuildLinks
                         toPlist:@"ProjectForceBuildLinks"];
}

- (NSDictionary *) getProjectForceBuildLinks
{
    return [[self class] getDictionaryFromPlist:@"ProjectForceBuildLinks"];
}

- (void) saveProjectBuildSucceededStates:
    (NSDictionary *)projectBuildSucceededStates
{
    [[self class] saveDictionary:projectBuildSucceededStates
                         toPlist:@"ProjectBuildSucceededStates"];
}

- (NSDictionary *) getProjectBuildSucceededStates
{
    return [[self class] getDictionaryFromPlist:@"ProjectBuildSucceededStates"];
}

- (void) saveProjectTrackedStates:(NSDictionary *)projectTrackedStates
{
    [[self class] saveDictionary:projectTrackedStates
                         toPlist:@"ProjectTrackedStates"];
}

- (NSDictionary *) getProjectTrackedStates
{
    return [[self class] getDictionaryFromPlist:@"ProjectTrackedStates"];
}

- (void) saveActiveServerGroupName:(NSString *)activeServerGroupName
{
    NSMutableDictionary * navigationState =
        [[[self class] getDictionaryFromPlist:@"NavigationState"] mutableCopy];
    if (activeServerGroupName)
        [navigationState setObject:activeServerGroupName
                            forKey:@"activeServerGroupName"];
    else
        [navigationState removeObjectForKey:@"activeServerGroupName"];
    [[self class] saveDictionary:navigationState toPlist:@"NavigationState"];
}

- (NSString *) getActiveServerGroupName
{
    NSDictionary * navigationState =
        [[self class] getDictionaryFromPlist:@"NavigationState"];
    
    return [navigationState objectForKey:@"activeServerGroupName"];
}

- (void) saveActiveProjectId:(NSString *)activeProjectId
{    
    NSMutableDictionary * navigationState =
        [[[self class] getDictionaryFromPlist:@"NavigationState"] mutableCopy];
    if (activeProjectId)
        [navigationState setObject:activeProjectId forKey:@"activeProjectId"];
    else
        [navigationState removeObjectForKey:@"activeProjectId"];
    [[self class] saveDictionary:navigationState toPlist:@"NavigationState"];    
}

- (NSString *) getActiveProjectId
{
    NSDictionary * navigationState =
        [[self class] getDictionaryFromPlist:@"NavigationState"];
    
    return [navigationState objectForKey:@"activeProjectId"];
}

- (void) restoreToDefaultState
{
    [[self class] removePlistAndCopyDefaultFromBundle:@"Servers"];
    [[self class] removePlistAndCopyDefaultFromBundle:@"ServerGroupPatterns"];
    [[self class] removePlistAndCopyDefaultFromBundle:@"ServerNames"];
    [[self class] removePlistAndCopyDefaultFromBundle:@"ServerDashboardLinks"];
    [[self class] removePlistAndCopyDefaultFromBundle:@"ServerGroupSortOrder"];
    [[self class] removePlistAndCopyDefaultFromBundle:@"ServerUsernames"];
    [[self class] removePlistAndCopyDefaultFromBundle:@"ProjectDisplayNames"];
    [[self class] removePlistAndCopyDefaultFromBundle:@"ProjectLabels"];
    [[self class] removePlistAndCopyDefaultFromBundle:@"ProjectDescriptions"];
    [[self class] removePlistAndCopyDefaultFromBundle:@"ProjectPubDates"];
    [[self class] removePlistAndCopyDefaultFromBundle:@"ProjectLinks"];
    [[self class] 
        removePlistAndCopyDefaultFromBundle:@"ProjectForceBuildLinks"];
    [[self class]
        removePlistAndCopyDefaultFromBundle:@"ProjectBuildSucceededStates"];
    [[self class] removePlistAndCopyDefaultFromBundle:@"ProjectTrackedStates"];
    [[self class] removePlistAndCopyDefaultFromBundle:@"NavigationState"];
}

#pragma mark Private static helpers

+ (NSDictionary *) getDictionaryFromPlist:(NSString *)plist
{
    NSString * fullPath = [PlistUtils fullDocumentPathForPlist:plist];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:fullPath];
    if (!fileExists) {        
        NSError * error = nil;
        NSString * bundlePath = [PlistUtils fullBundlePathForPlist:plist];
        BOOL fileCopied = [fileManager copyItemAtPath:bundlePath
                                               toPath:fullPath
                                                error:&error];
        if (!fileCopied)
            NSLog([error description]);
    }
    
    return [PlistUtils readDictionaryFromPlist:fullPath];
}

+ (void) saveDictionary:dictionary toPlist:(NSString *)plist
{
    NSString * fullPath = [PlistUtils fullDocumentPathForPlist:plist];
    [PlistUtils writeDictionary:dictionary toPlist:fullPath];
}

+ (NSArray *) getArrayFromPlist:(NSString *)plist
{
    NSString * fullPath = [PlistUtils fullDocumentPathForPlist:plist];

    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:fullPath];
    if (!fileExists) {
        NSError * error = nil;
        NSString * bundlePath = [PlistUtils fullBundlePathForPlist:plist];
        BOOL fileCopied = [fileManager copyItemAtPath:bundlePath
                                               toPath:fullPath
                                                error:&error];
        if (!fileCopied)
            NSLog([error description]);
    }

    return [PlistUtils readArrayFromPlist:fullPath];
}

+ (void) saveArray:(NSArray *)array toPlist:(NSString *)plist
{
    NSString * fullPath = [PlistUtils fullDocumentPathForPlist:plist];
    [PlistUtils writeArray:array toPlist:fullPath];
}

+ (void) removePlistAndCopyDefaultFromBundle:(NSString *)plist
{
    NSString * fullPath = [PlistUtils fullDocumentPathForPlist:plist];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:fullPath];
    if (fileExists) {
        NSError * error = nil;
        BOOL fileRemoved = [fileManager removeItemAtPath:fullPath error:&error];
        
        if (!fileRemoved)
            NSLog([error description]);
        else {
            NSString * bundlePath = [PlistUtils fullBundlePathForPlist:plist];
            BOOL fileCopied =
            [fileManager copyItemAtPath:bundlePath toPath:fullPath
                                  error:&error];
            if (!fileCopied)
                NSLog([error description]);
        }
    }    
}

@end
