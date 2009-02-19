//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerGroupNameSelector.h"
#import "ServerGroupNameSelectorDelegate.h"

@class ServerViewController;

@interface UIServerGroupNameSelector : NSObject
                                       < ServerGroupNameSelector >
{
    NSObject<ServerGroupNameSelectorDelegate> * delegate;
    UINavigationController * navigationController;
    ServerViewController * serverViewController;
}

@property (nonatomic, retain) IBOutlet
    NSObject<ServerGroupNameSelectorDelegate> * delegate;
@property (nonatomic, retain) IBOutlet
    UINavigationController * navigationController;
@property (nonatomic, retain, readonly)
    ServerViewController * serverViewController;

#pragma mark ServerSelector protocol methods

- (void) selectServerGroupNamesFrom:(NSArray *)someServerGroupNames
                           animated:(BOOL)animated;

@end
