//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "MockServerPersistentStore.h"

@interface MockServerPersistentStore (Private)
- (NSDictionary *) mockServerList;
@end


@implementation MockServerPersistentStore

- (void)dealloc
{
    [servers release];
    [super dealloc];
}

- (id)init
{
    if (self = [super init]) {
        servers = [[self mockServerList] retain];
    }
    return self;
}

- (void)save:(NSArray *)newServers
{
    [servers release];
    servers = [newServers copy];
}

- (NSDictionary *)getAllServers
{
    return servers;
}

#pragma mark Private methods

- (NSDictionary *) mockServerList
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

@end
