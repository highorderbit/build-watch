//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerSelector.h"
#import "ServerSelectorDelegate.h"

@class ServerViewController;

@interface UIServerSelector : NSObject
                              < ServerSelector >
{
    NSObject<ServerSelectorDelegate> * delegate;
    UINavigationController * navigationController;
    ServerViewController * serverViewController;
}


@property (nonatomic, retain) IBOutlet NSObject<ServerSelectorDelegate> *
    delegate;
@property (nonatomic, retain) IBOutlet UINavigationController *
    navigationController;
@property (nonatomic, retain, readonly) ServerViewController *
    serverViewController;

#pragma mark ServerSelector protocol methods

- (void) selectServerFrom:(NSArray *)someServers;

@end
