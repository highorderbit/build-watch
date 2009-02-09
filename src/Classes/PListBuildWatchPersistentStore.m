//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "PListBuildWatchPersistentStore.h"

@implementation PListBuildWatchPersistentStore

#pragma mark BuildWatchPersistentStore protocal implementation

- (void) saveServers:(NSDictionary *)servers
{
    [PListUtils writeDictionary:servers toPList:@"Servers"];
}

- (NSDictionary *) getServers
{
    return [PListUtils readDictionaryFromPList:@"Servers"];
}

- (void) saveServerGroupPatterns:(NSDictionary *)serverGroupPatterns
{
    [PListUtils writeDictionary:serverGroupPatterns
                          toPList:@"ServerGroupPatterns"];
}

- (NSDictionary *) getServerGroupPatterns
{
    return [PListUtils readDictionaryFromPList:@"ServerGroupPatterns"];
}

- (void) saveServerNames:(NSDictionary *)serverNames
{
    [PListUtils writeDictionary:serverNames toPList:@"ServerNames"];
}

- (NSDictionary *) getServerNames
{
    return [PListUtils readDictionaryFromPList:@"ServerNames"];
}

- (void) saveProjectDisplayNames:(NSDictionary *)projectDisplayNames
{
    [PListUtils writeDictionary:projectDisplayNames
                          toPList:@"ProjectDisplayNames"];
}

- (NSDictionary *) getProjectDisplayNames
{
    return [PListUtils readDictionaryFromPList:@"ProjectDisplayNames"];
}

- (void) saveProjectLinks:(NSDictionary *)projectLinks
{
    [PListUtils writeDictionary:projectLinks toPList:@"ProjectLinks"];
}

- (NSDictionary *) getProjectLinks
{
    return [PListUtils readDictionaryFromPList:@"ProjectLinks"];
}

- (void) saveProjectTrackedStates:(NSDictionary *)projectTrackedStates
{
    [PListUtils writeDictionary:projectTrackedStates
                          toPList:@"ProjectTrackedStates"];
}

- (NSDictionary *) getProjectTrackedStates
{
    return [PListUtils readDictionaryFromPList:@"ProjectTrackedStates"];
}

@end
