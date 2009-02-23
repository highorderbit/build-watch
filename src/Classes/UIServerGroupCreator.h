//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerGroupCreator.h"
#import "ServerGroupCreatorDelegate.h"
#import "ServerGroupEditor.h"
#import "ServerGroupEditorDelegate.h"
#import "ServerGroupPropertyProvider.h"
#import "AddServerViewControllerDelegate.h"
#import "EditServerDetailsViewControllerDelegate.h"
#import "SelectServerTypeViewControllerDelegate.h"
#import "BuildServiceDelegate.h"
#import "BuildService.h"

@class ServerReport;
@class AddServerViewController;
@class EditServerDetailsViewController;
@class SelectServerTypeViewController;
@class RssHelpViewController;

@interface UIServerGroupCreator : NSObject
                                  < ServerGroupCreator,
                                    ServerGroupEditor,
                                    ServerGroupPropertyProvider,
                                    AddServerViewControllerDelegate,
                                    EditServerDetailsViewControllerDelegate,
                                    SelectServerTypeViewControllerDelegate,
                                    BuildServiceDelegate >
{
    UIViewController * rootView;
    UINavigationController * rootNavigationController;
    UINavigationController * addServerNavigationController;
    AddServerViewController * addServerViewController;
    EditServerDetailsViewController * editServerDetailsViewController;

    SelectServerTypeViewController * selectServerTypeViewController;

    RssHelpViewController * rssHelpViewController;

    NSObject<ServerGroupCreatorDelegate> * serverGroupCreatorDelegate;
    NSObject<ServerGroupEditorDelegate> * serverGroupEditorDelegate;

    NSObject<ServerGroupPropertyProvider> * serverGroupPropertyProvider;

    NSObject<BuildService> * buildService;
    NSObject<BuildServiceDelegate> * buildServiceDelegate;

    ServerReport * serverReport;
}

@property (nonatomic, retain) IBOutlet UIViewController * rootView;
@property (nonatomic, retain) IBOutlet UINavigationController *
    rootNavigationController;
@property (nonatomic, retain) UINavigationController *
    addServerNavigationController;
@property (nonatomic, retain) AddServerViewController *
    addServerViewController;
@property (nonatomic, retain) EditServerDetailsViewController *
    editServerDetailsViewController;

@property (nonatomic, retain) SelectServerTypeViewController *
    selectServerTypeViewController;

@property (nonatomic, retain) RssHelpViewController * rssHelpViewController;

@property (nonatomic, retain) IBOutlet NSObject<ServerGroupCreatorDelegate> *
    serverGroupCreatorDelegate;
@property (nonatomic, retain) IBOutlet NSObject<ServerGroupEditorDelegate> *
    serverGroupEditorDelegate;

@property (nonatomic, retain) IBOutlet NSObject<ServerGroupPropertyProvider> *
    serverGroupPropertyProvider;

@property (nonatomic, retain) NSObject<BuildService> * buildService;
@property (nonatomic, retain) IBOutlet NSObject<BuildServiceDelegate> *
    buildServiceDelegate;

@property (nonatomic, copy) ServerReport * serverReport;

@end
