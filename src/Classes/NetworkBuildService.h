//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
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
}

@property (nonatomic, retain) IBOutlet NSObject<BuildServiceDelegate> *
    delegate;

#pragma mark Initializers

- (id)init;
- (id)initWithDelegate:(NSObject<BuildServiceDelegate> *)delegate;

@end
