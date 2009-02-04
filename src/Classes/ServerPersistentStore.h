//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ServerPersistentStore

/**
 * Replaces existing set of servers with provided array of servers.
 */
- (void)save:(NSArray *)servers;

/**
 * Returns all servers stored in the underlying persistent store.
 */
- (NSDictionary *)getAllServers;

@end
