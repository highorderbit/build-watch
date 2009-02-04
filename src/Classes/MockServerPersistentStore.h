//
//  MockServerPersistentStore.h
//  build-watch
//
//  Created by John A. Debay on 2/4/09.
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerPersistentStore.h"

@interface MockServerPersistentStore : NSObject
                                       < ServerPersistentStore >
{
    NSDictionary * servers;
}

- (void)save:(NSArray *)servers;
- (NSDictionary *)getAllServers;

@end
