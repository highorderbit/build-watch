//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "PListBuildWatchPersistentStore.h"

@interface PlistBuildWatchPersistentStore (Private)

+ (NSDictionary *) getDictionaryFromPlist:(NSString *)plist;

+ (void) saveDictionary:dictionary toPlist:(NSString *)plist;

@end

@implementation PlistBuildWatchPersistentStore

#pragma mark BuildWatchPersistentStore protocal implementation

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

+ (NSDictionary *) getDictionaryFromPlist:(NSString *)plist
{
    NSString * fullPath = [PlistUtils fullDocumentPathForPlist:plist];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:fullPath];
    if (!fileExists) {
        NSError * error = nil;
        NSString * bundlePath = [PlistUtils fullBundlePathForPlist:plist];
        BOOL fileCopied =
            [fileManager copyItemAtPath:bundlePath
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

@end
