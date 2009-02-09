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

- (void) saveServerGroupPatterns:(NSDictionary *)serverGroupPatterns;

- (NSDictionary *) getServerGroupPatterns;

- (void) saveServerNames:(NSDictionary *)serverNames;

- (NSDictionary *) getServerNames;

- (void) saveProjectDisplayNames:(NSDictionary *)projectDisplayNames;

- (NSDictionary *) getProjectDisplayNames;

- (void) saveProjectDescriptions:(NSDictionary *)projectDescriptions;

- (NSDictionary *) getProjectDescriptions;

- (void) saveProjectPubDates:(NSDictionary *)projectPubDates;

- (NSDictionary *) getProjectPubDates;

- (void) saveProjectLinks:(NSDictionary *)projectLinks;

- (NSDictionary *) getProjectLinks;

- (void) saveProjectBuildSucceededStates:
    (NSDictionary *)projectBuildSucceededStates;

- (NSDictionary *) getProjectBuildSucceededStates;

- (void) saveProjectTrackedStates:(NSDictionary *)projectTrackedStates;

- (NSDictionary *) getProjectTrackedStates;

@end
