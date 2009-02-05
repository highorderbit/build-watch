//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol BuildWatchPersistentStore

/**
 * Replaces existing set of servers with provided array of servers.
 */
- (void)saveServers:(NSDictionary *)servers;

/**
 * Returns all servers stored in the underlying persistent store.
 */
- (NSDictionary *)getServers;

- (void)saveServerNames:(NSDictionary *)serverNames;

- (NSDictionary *)getServerNames;

- (void)saveProjDisplayNames:(NSDictionary *)projDisplayNames;

- (NSDictionary *)getProjDisplayNames;

@end
