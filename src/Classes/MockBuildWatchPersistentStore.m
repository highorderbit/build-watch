//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "MockBuildWatchPersistentStore.h"

@interface MockBuildWatchPersistentStore (Private)
+ (NSDictionary *) mockServerList;
+ (NSDictionary *) mockServerGroupPatternsList;
+ (NSDictionary *) mockServerNameList;
+ (NSDictionary *) mockProjectDisplayNamesList;
+ (NSDictionary *) mockProjectTrackedStates;
@end

@implementation MockBuildWatchPersistentStore

- (void) dealloc
{
    [servers release];
    [serverGroupPatterns release];
    [serverNames release];
    [projectDisplayNames release];
    [projectTrackedStates release];
    [super dealloc];
}

- (id) init
{
    if (self = [super init]) {
        servers = [[[self class] mockServerList] retain];
        serverGroupPatterns =
            [[[self class] mockServerGroupPatternsList] retain];
        serverNames = [[[self class]  mockServerNameList] retain];
        projectDisplayNames =
            [[[self class] mockProjectDisplayNamesList] retain];
        projectTrackedStates = [[[self class] mockProjectTrackedStates] retain];
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

- (void) saveServerGroupPatterns:(NSDictionary *)newServerGroupPatterns
{
    [serverGroupPatterns release];
    serverGroupPatterns = [newServerGroupPatterns copy];
}

- (NSDictionary *)getServerGroupPatterns
{
    return serverGroupPatterns;
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

- (void) saveProjectDisplayNames:(NSDictionary *)newProjDisplayNames
{
    [projectDisplayNames release];
    projectDisplayNames = [newProjDisplayNames copy];
}

- (NSDictionary *) getProjectDisplayNames
{
    return projectDisplayNames;
}

- (void) saveProjectLabels:(NSDictionary *)projectLabels
{}

- (NSDictionary *) getProjectLabels
{
    return nil;
}

- (void) saveProjectDescriptions:(NSDictionary *)projectDescriptions
{}

- (NSDictionary *) getProjectDescriptions
{
    return nil;
}

- (void) saveProjectPubDates:(NSDictionary *)projectPubDates
{}

- (NSDictionary *) getProjectPubDates
{
    return nil;
}

- (void) saveProjectLinks:(NSDictionary *)projectLinks
{}

- (NSDictionary *) getProjectLinks
{
    return nil;
}

- (void) saveProjectForceBuildLinks:(NSDictionary *)projectForceBuildLinks
{}

- (NSDictionary *) getProjectForceBuildLinks
{
    return nil;
}

- (void) saveProjectBuildSucceededStates:
    (NSDictionary *)projectBuildSucceededStates
{}

- (NSDictionary *) getProjectBuildSucceededStates
{
    return nil;
}

- (void) saveProjectTrackedStates:(NSDictionary *)newProjectTrackedStates
{
    [projectTrackedStates release];
    projectTrackedStates = [newProjectTrackedStates copy];
}

- (NSDictionary *) getProjectTrackedStates
{
    return projectTrackedStates;
}

- (NSDictionary *) getServerReportBuilders
{
    return nil;
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
        nil];
}

+ (NSDictionary *) mockServerGroupPatternsList
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"^http://builder/my-server/$", @"http://builder/my-server/",
            @"^http://apple.com/builder/$", @"http://apple.com/builder/",
            @"^http://microsoft.com/TeamSystem/default.aspx$",
            @"http://microsoft.com/TeamSystem/default.aspx",
            @"^http://openoffice.org/builds/$",
            @"http://openoffice.org/builds/",
            @".*", @"All", nil];
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

+ (NSDictionary *) mockProjectDisplayNamesList
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"Build Watch", @"http://builder/my-server/|Build Watch",
            @"Website", @"http://builder/my-server/|Website",
            @"Git Website", @"http://builder/my-server/|Git Website",
            @"Mail", @"http://apple.com/builder/|Mail",
            @"Address Book", @"http://apple.com/builder/|Address Book",
            @"Safari", @"http://apple.com/builder/|Safari",
            @"Windows 7",
            @"http://microsoft.com/TeamSystem/default.aspx|Windows 7",
            @"Visual Studio Team System 2007", 
            @"http://microsoft.com/TeamSystem/default.aspx|Visual Studio Team System 2007",
            @"Microsoft Office System 2009",
            @"http://microsoft.com/TeamSystem/default.aspx|Microsoft Office System 2009",
            @"OpenOffice", @"http://openoffice.org/builds/|OpenOffice",
            @"KDE", @"http://openoffice.org/builds/|KDE", 
            @"GNOME", @"http://openoffice.org/builds/|GNOME",
            nil];
}

+ (NSDictionary *) mockProjectTrackedStates
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:YES],
            @"http://builder/my-server/|Build Watch",
            [NSNumber numberWithBool:YES],
            @"http://builder/my-server/|Website",
            [NSNumber numberWithBool:YES],
            @"http://builder/my-server/|Git Website",
            [NSNumber numberWithBool:YES],
            @"http://apple.com/builder/|Mail",
            [NSNumber numberWithBool:YES],
            @"http://apple.com/builder/|Address Book",
            [NSNumber numberWithBool:YES], @"http://apple.com/builder/|Safari",
            [NSNumber numberWithBool:YES],
            @"http://microsoft.com/TeamSystem/default.aspx|Windows 7",
            [NSNumber numberWithBool:YES], 
            @"http://microsoft.com/TeamSystem/default.aspx|Visual Studio Team System 2007",
            [NSNumber numberWithBool:NO],
            @"http://microsoft.com/TeamSystem/default.aspx|Microsoft Office System 2009",
            [NSNumber numberWithBool:YES],
            @"http://openoffice.org/builds/|OpenOffice",
            [NSNumber numberWithBool:YES], @"http://openoffice.org/builds/|KDE", 
            [NSNumber numberWithBool:YES],
            @"http://openoffice.org/builds/|GNOME", nil];
}

@end
