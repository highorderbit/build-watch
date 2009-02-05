//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "MockBuildWatchPersistentStore.h"

@interface MockBuildWatchPersistentStore (Private)
+ (NSDictionary *) mockServerList;
+ (NSDictionary *) mockServerNameList;
+ (NSDictionary *) mockProjectDisplayNameList;
@end

@implementation MockBuildWatchPersistentStore

- (void) dealloc
{
    [servers release];
    [serverNames release];
    [projectDisplayNames release];
    [super dealloc];
}

- (id) init
{
    if (self = [super init]) {
        servers = [[MockBuildWatchPersistentStore mockServerList] retain];
        serverNames =
            [[MockBuildWatchPersistentStore  mockServerNameList] retain];
        projectDisplayNames =
            [[MockBuildWatchPersistentStore mockProjectDisplayNameList] retain];
    }
    
    return self;
}

# pragma mark BuildWatchPersistentStore

- (void) saveServers:(NSDictionary *)newServers
{
    [servers release];
    servers = [newServers copy];
}

- (NSDictionary *)getServers
{
    return servers;
}

- (void) saveServerNames:(NSDictionary *)newServerNames
{
    [serverNames release];
    serverNames = [newServerNames copy];
}

- (NSDictionary *) getServerNames
{
    return serverNames;
}

- (void) saveProjDisplayNames:(NSDictionary *)newProjDisplayNames
{
    [projectDisplayNames release];
    projectDisplayNames = [newProjDisplayNames copy];
}

- (NSDictionary *) getProjDisplayNames
{
    return projectDisplayNames;
}

#pragma mark Private methods

+ (NSDictionary *) mockServerList
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [NSArray arrayWithObjects:@"Build Watch",
                                  @"Website",
                                  @"Git Website",
                                  nil],
        @"http://builder/my-server/",
        [NSArray arrayWithObjects:@"Mail",
                                  @"Address Book",
                                  @"Safari",
                                  nil],
        @"http://apple.com/builder/",
        [NSArray arrayWithObjects:@"Windows 7",
                                  @"Visual Studio Team System 2007",
                                  @"Microsoft Office System 2009",
                                  nil],
        @"http://microsoft.com/TeamSystem/default.aspx",
        [NSArray arrayWithObjects:@"OpenOffice",
                                  @"KDE",
                                  @"GNOME",
                                  nil],
        @"http://openoffice.org/builds/",
        nil, nil];
}

+ (NSDictionary *) mockServerNameList
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"My Builds", @"http://builder/my-server/",
            @"Apple Builds", @"http://apple.com/builder/",
            @"Microsoft Builds",
            @"http://microsoft.com/TeamSystem/default.aspx",
            @"OpenOfice Builds", @"http://openoffice.org/builds/", nil];
}

+ (NSDictionary *) mockProjectDisplayNameList
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"http://builder/my-server/|Build Watch", @"Build Watch",
            @"http://builder/my-server/|Website", @"Website",
            @"http://builder/my-server/|Git Website", @"Git Website",
            @"http://apple.com/builder/|Mail", @"Mail",
            @"http://apple.com/builder/|Address Book", @"Address Book",
            @"http://apple.com/builder/|Safari", @"Safari",
            @"http://microsoft.com/TeamSystem/default.aspx|Windows 7",
            @"Windows 7",
            @"http://microsoft.com/TeamSystem/default.aspx|Visual Studio Team System 2007",
            @"Visual Studio Team System 2007",
            @"http://microsoft.com/TeamSystem/default.aspx|Microsoft Office System 2009",
            @"Microsoft Office System 2009",
            @"http://openoffice.org/builds/|OpenOffice", @"OpenOffice",
            @"http://openoffice.org/builds/|KDE", @"KDE",
            @"http://openoffice.org/builds/|GNOME", @"GNOME",
            nil];
}

@end
