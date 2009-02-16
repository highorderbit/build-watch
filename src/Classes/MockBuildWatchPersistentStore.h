//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BuildWatchPersistentStore.h"

@interface MockBuildWatchPersistentStore : NSObject
                                       < BuildWatchPersistentStore >
{
    NSDictionary * servers;
    NSDictionary * serverGroupPatterns;
    NSDictionary * serverNames;
    NSDictionary * projectDisplayNames;
    NSDictionary * projectTrackedStates;
}

@end
