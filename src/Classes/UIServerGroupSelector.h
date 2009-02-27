//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerGroupSelector.h"
#import "ServerGroupSelectorDelegate.h"

@class ServerViewController;

@interface UIServerGroupSelector : NSObject
                                       < ServerGroupSelector >
{
    NSObject<ServerGroupSelectorDelegate> * delegate;
    UINavigationController * navigationController;
    ServerViewController * serverViewController;
}

@property (nonatomic, retain) IBOutlet
    NSObject<ServerGroupSelectorDelegate> * delegate;
@property (nonatomic, retain) IBOutlet
    UINavigationController * navigationController;
@property (nonatomic, retain, readonly)
    ServerViewController * serverViewController;

#pragma mark ServerSelector protocol methods

- (void) selectServerGroupsFrom:(NSArray *)someServerGroupKeys
                       animated:(BOOL)animated;

@end
