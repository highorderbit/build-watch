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

- (void) saveServerGroupNames:(NSDictionary *)serverGroupNames
{
    [[self class] saveDictionary:serverGroupNames toPlist:@"ServerGroupNames"];
}

- (NSDictionary *) getServerGroupNames
{
    return [[self class] getDictionaryFromPlist:@"ServerGroupNames"];
}

- (void) saveServerDashboardLinks:(NSDictionary *)serverDashboardLinks
{
    [[self class] saveDictionary:serverDashboardLinks
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

- (void) saveProjectNames:(NSDictionary *)projectNames
{
    [[self class] saveDictionary:projectNames toPlist:@"ProjectNames"];
}

- (NSDictionary *) getProjectNames
{
    return [[self class] getDictionaryFromPlist:@"ProjectNames"];
}

- (void) saveBuildLabels:(NSDictionary *)buildLabels
{
    [[self class] saveDictionary:buildLabels toPlist:@"BuildLabels"];
}

- (NSDictionary *) getBuildLabels
{
    return [[self class] getDictionaryFromPlist:@"BuildLabels"];
}

- (void) saveBuildDescriptions:(NSDictionary *)buildDescriptions
{
    [[self class] saveDictionary:buildDescriptions
                         toPlist:@"BuildDescriptions"];
}

- (NSDictionary *) getBuildDescriptions
{
    return [[self class] getDictionaryFromPlist:@"BuildDescriptions"];
}

- (void) saveBuildPubDates:(NSDictionary *)buildPubDates
{
    [[self class] saveDictionary:buildPubDates toPlist:@"BuildPubDates"];
}

- (NSDictionary *) getBuildPubDates
{
    return [[self class] getDictionaryFromPlist:@"BuildPubDates"];
}

- (void) saveBuildReportLinks:(NSDictionary *)buildReportLinks
{
    [[self class] saveDictionary:buildReportLinks toPlist:@"BuildReportLinks"];
}

- (NSDictionary *) getBuildReportLinks
{
    return [[self class] getDictionaryFromPlist:@"BuildReportLinks"];
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

- (void) saveBuildSucceededStates:(NSDictionary *)buildSucceededStates
{
    [[self class] saveDictionary:buildSucceededStates
                         toPlist:@"BuildSucceededStates"];
}

- (NSDictionary *) getBuildSucceededStates
{
    return [[self class] getDictionaryFromPlist:@"BuildSucceededStates"];
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
    [[self class] removePlistAndCopyDefaultFromBundle:@"ServerGroupNames"];
    [[self class] removePlistAndCopyDefaultFromBundle:@"ServerDashboardLinks"];
    [[self class] removePlistAndCopyDefaultFromBundle:@"ServerGroupSortOrder"];
    [[self class] removePlistAndCopyDefaultFromBundle:@"ServerUsernames"];
    [[self class] removePlistAndCopyDefaultFromBundle:@"ProjectNames"];
    [[self class] removePlistAndCopyDefaultFromBundle:@"BuildLabels"];
    [[self class] removePlistAndCopyDefaultFromBundle:@"BuildDescriptions"];
    [[self class] removePlistAndCopyDefaultFromBundle:@"BuildPubDates"];
    [[self class] removePlistAndCopyDefaultFromBundle:@"BuildReportLinks"];
    [[self class] 
        removePlistAndCopyDefaultFromBundle:@"ProjectForceBuildLinks"];
    [[self class]
        removePlistAndCopyDefaultFromBundle:@"BuildSucceededStates"];
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
