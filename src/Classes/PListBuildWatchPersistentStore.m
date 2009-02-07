//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "PListBuildWatchPersistentStore.h"

@interface PListBuildWatchPersistentStore (Private)
+ (NSDictionary *) readDictionaryFromPList:(NSString *) pList;
+ (void) writeDictionary:(NSDictionary *)dictionary toPList:(NSString *)pList;
@end

@implementation PListBuildWatchPersistentStore

#pragma mark BuildWatchPersistentStore protocal implementation

- (void) saveServers:(NSDictionary *)servers
{
    [[self class] writeDictionary:servers toPList:@"Servers"];
}

- (NSDictionary *) getServers
{
    return [[self class] readDictionaryFromPList:@"Servers"];
}

- (void) saveServerGroupPatterns:(NSDictionary *)serverGroupPatterns
{
    [[self class] writeDictionary:serverGroupPatterns
                          toPList:@"ServerGroupPatterns"];
}

- (NSDictionary *) getServerGroupPatterns
{
    return [[self class] readDictionaryFromPList:@"ServerGroupPatterns"];
}

- (void) saveServerNames:(NSDictionary *)serverNames
{
    [[self class] writeDictionary:serverNames toPList:@"ServerNames"];
}

- (NSDictionary *) getServerNames
{
    return [[self class] readDictionaryFromPList:@"ServerNames"];
}

- (void) saveProjectDisplayNames:(NSDictionary *)projectDisplayNames
{
    [[self class] writeDictionary:projectDisplayNames
                          toPList:@"ProjectDisplayNames"];
}

- (NSDictionary *) getProjectDisplayNames
{
    return [[self class] readDictionaryFromPList:@"ProjectDisplayNames"];
}

- (void) saveProjectTrackedStates:(NSDictionary *)projectTrackedStates
{
    [[self class] writeDictionary:projectTrackedStates
                          toPList:@"ProjectTrackedStates"];
}

- (NSDictionary *) getProjectTrackedStates
{
    return [[self class] readDictionaryFromPList:@"ProjectTrackedStates"];
}

# pragma mark Private static helper functions

+ (NSDictionary *) readDictionaryFromPList:(NSString *) pList
{
    NSString * errorDesc = nil;
        NSPropertyListFormat format;
    NSString * plistPath =
        [[NSBundle mainBundle] pathForResource:pList ofType:@"plist"];
    NSData * plistXML =
        [[NSFileManager defaultManager] contentsAtPath:plistPath];
    
    NSDictionary * temp = 
        (NSDictionary *)[
            NSPropertyListSerialization
                propertyListFromData:plistXML
                    mutabilityOption:NSPropertyListMutableContainersAndLeaves
                              format:&format
                    errorDescription:&errorDesc];
    
    if (!temp) {
        NSLog(errorDesc);
        [errorDesc release];
    }
    
    return temp;
}

+ (void) writeDictionary:(NSDictionary *)dictionary toPList:(NSString *)pList
{
    NSString *errorDesc;
    NSString *bundlePath =
        [[NSBundle mainBundle] pathForResource:pList ofType:@"plist"];
    NSData *plistData =
        [NSPropertyListSerialization
            dataFromPropertyList:dictionary
                          format:NSPropertyListXMLFormat_v1_0
                errorDescription:&errorDesc];
    
    if (plistData)
        [plistData writeToFile:bundlePath atomically:YES];
    else {
        NSLog(errorDesc);
        [errorDesc release];
    }
}

@end
