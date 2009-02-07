//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerGroupCreator.h"
#import "ServerGroupCreatorDelegate.h"
#import "AddServerViewControllerDelegate.h"
#import "EditServerDetailsViewControllerDelegate.h"
#import "BuildServiceDelegate.h"
#import "BuildService.h"

@class AddServerViewController;
@class EditServerDetailsViewController;

@interface UIServerGroupCreator : NSObject
                                   < ServerGroupCreator,
                                     AddServerViewControllerDelegate,
                                     EditServerDetailsViewControllerDelegate,
                                     BuildServiceDelegate >
{
    UINavigationController * rootNavigationController;
    UINavigationController * addServerNavigationController;
    AddServerViewController * addServerViewController;
    EditServerDetailsViewController * editServerDetailsViewController;

    NSObject<ServerGroupCreatorDelegate> * delegate;
    NSObject<BuildService> * buildService;
}

@property (nonatomic, retain) IBOutlet UINavigationController *
    rootNavigationController;
@property (nonatomic, retain) UINavigationController *
    addServerNavigationController;
@property (nonatomic, retain) AddServerViewController *
    addServerViewController;
@property (nonatomic, retain) EditServerDetailsViewController *
    editServerDetailsViewController;

@property (nonatomic, retain) IBOutlet NSObject<ServerGroupCreatorDelegate> *
    delegate;

/**
 * TODO: Consider pointing to a shared build service instance. Doing so
 * would require a change to the BuildService protocol to support sending
 * requests back to different initiators (currently they're only sent to
 * the single delegate).
 */
@property (nonatomic, retain) NSObject<BuildService> * buildService;

@end
