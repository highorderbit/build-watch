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
    NSObject<BuildServiceDelegate> * buildServiceDelegate;

    NSString * serverUrl;
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
@property (nonatomic, retain) NSObject<BuildService> * buildService;
@property (nonatomic, retain) IBOutlet NSObject<BuildServiceDelegate> *
    buildServiceDelegate;
@property (nonatomic, copy) NSString * serverUrl;

@end
