//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BuildService.h"
#import "BuildServiceDelegate.h"
#import "BuildStatusUpdaterDelegate.h"

@interface NetworkBuildService : NSObject
                                 < BuildService,
                                   BuildStatusUpdaterDelegate >
{
    NSObject<BuildServiceDelegate> * delegate;

    NSMutableDictionary * updaters;
    NSMutableDictionary * asyncBuilders;
}

@property (nonatomic, retain) IBOutlet NSObject<BuildServiceDelegate> *
    delegate;

#pragma mark Initializers

- (id)init;
- (id)initWithDelegate:(NSObject<BuildServiceDelegate> *)delegate;

@end
