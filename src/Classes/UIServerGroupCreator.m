//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "UIServerGroupCreator.h"
#import "AddServerViewController.h"
#import "EditServerDetailsViewController.h"
#import "SelectServerTypeViewController.h"
#import "RssHelpViewController.h"
#import "NetworkBuildService.h"
#import "ServerReport.h"

@interface UIServerGroupCreator (Private)
- (BOOL) isCreatingNewServer;
- (void) endEditingSession;
@end


@implementation UIServerGroupCreator

@synthesize rootViewController;
@synthesize rootNavigationController;
@synthesize addServerNavigationController;
@synthesize addServerViewController;
@synthesize editServerDetailsViewController;

@synthesize serverGroupCreatorDelegate;
@synthesize serverGroupEditorDelegate;

@synthesize selectServerTypeViewController;

@synthesize rssHelpViewController;

@synthesize serverGroupPropertyProvider;

@synthesize buildService;
@synthesize buildServiceDelegate;

@synthesize serverReport;

- (void) dealloc
{
    [rootViewController release];
    [rootNavigationController release];
    [addServerNavigationController release];
    [addServerViewController release];
    [editServerDetailsViewController release];
    [serverGroupCreatorDelegate release];
    [serverGroupEditorDelegate release];
    [selectServerTypeViewController release];
    [rssHelpViewController release];
    [serverGroupPropertyProvider release];
    [buildService release];
    [buildServiceDelegate release];
    [serverReport release];
    [super dealloc];
}

#pragma mark ServerGroupCreator protocol implementation

- (void) createServerGroup
{
    self.addServerViewController.serverUrl = @"";

    [self.addServerNavigationController popToRootViewControllerAnimated:NO];
    [self.rootViewController
        presentModalViewController:self.addServerNavigationController
                          animated:YES];
}

#pragma mark ServerGroupEditor protocol implementation

- (void) editServerGroup:(NSString *)serverGroupName
{
    EditServerDetailsViewController * controller =
        self.editServerDetailsViewController;

    controller.serverGroupName = serverGroupName;
    controller.serverGroupPropertyProvider = self.serverGroupPropertyProvider;

    [self.rootNavigationController
        pushViewController:controller animated:YES];
}

#pragma mark AddServerViewControllerDelegate protocol implementation

- (void) addServerWithUrl:(NSString *)url
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [self.buildService refreshDataForServer:url];
}

- (void) userDidCancelAddingServerWithUrl:(NSString *)url
{
    NSLog(@"Attempting to cancel connection to: '%@'.", url);

    [buildService cancelRefreshForServer:url];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.rootViewController dismissModalViewControllerAnimated:YES];

    [self endEditingSession];
}

- (BOOL) isServerGroupUrlValid:(NSString *)url
{
    return [serverGroupCreatorDelegate isServerGroupUrlValid:url];
}

- (void) userRequestsHelp
{
    [self.addServerNavigationController
        pushViewController:self.rssHelpViewController animated:YES];
}

- (void) userDidSelectServerType
{
    [self.addServerNavigationController
        pushViewController:self.selectServerTypeViewController
                  animated:YES];
}

#pragma mark EditServerDetailsViewControllerDelegate protocol implementation

- (void) userDidEditServerGroupName:(NSString *)serverGroupName
             serverGroupDisplayName:(NSString *)serverGroupDisplayName;
{
    if ([self isCreatingNewServer]) {
        serverReport.name = serverGroupDisplayName;
        [serverGroupCreatorDelegate
         serverGroupCreatedWithDisplayName:serverGroupDisplayName
                     andInitialBuildReport:serverReport];

        [rootViewController dismissModalViewControllerAnimated:YES];
    } else {
        [serverGroupEditorDelegate
            changeDisplayName:serverGroupDisplayName
           forServerGroupName:serverGroupName];

        [rootNavigationController popToRootViewControllerAnimated:YES];
    }

    [self endEditingSession];
}

- (void) userDidCancelEditingServerGroupName:(NSString *)serverGroupName
{
    if ([self isCreatingNewServer])
        [rootViewController dismissModalViewControllerAnimated:YES];
    else
        [rootNavigationController popViewControllerAnimated:YES];

    [self endEditingSession];
}

#pragma mark BuildServiceDelegate protocol implementation

- (void) report:(ServerReport *)report receivedFrom:(NSString *)theServerUrl
{
    NSLog(@"Received build report: '%@' from server: '%@'.",
        report, theServerUrl);

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    EditServerDetailsViewController * controller =
        self.editServerDetailsViewController;
    controller.serverGroupPropertyProvider = self;

    self.serverReport = report;

    [self.addServerNavigationController
        pushViewController:controller animated:YES];
}

- (void) attemptToGetReportFromServer:(NSString *)theServerUrl
                     didFailWithError:(NSError *)error
{
    NSLog(@"Failed to get report from server: '%@', error: '%@'.", theServerUrl,
        error);

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    UIAlertView * alertView =
        [[[UIAlertView alloc]
          initWithTitle:NSLocalizedString(@"addserver.error.alert.title", @"")
                message:error.localizedDescription
               delegate:self
      cancelButtonTitle:NSLocalizedString(@"addserver.error.alert.ok", @"")
      otherButtonTitles:nil]
         autorelease];

    [alertView show];

    [addServerViewController viewWillAppear:NO];
}

#pragma mark SelectServerTypeViewControllerDelegate protocol implementation

- (void) userDidSelectServerTypeName:(NSString *)serverTypeName
{
    addServerViewController.serverType = serverTypeName;
}

#pragma mark ServerGroupPropertyProvider protocol implementation

- (NSString *) displayNameForServerGroupName:(NSString *)serverGroupName
{
    return serverReport ? serverReport.name :
        [serverGroupPropertyProvider
         displayNameForServerGroupName:serverGroupName];
}

- (NSString *) linkForServerGroupName:(NSString *)serverGroupName
{
    return serverReport ? serverReport.key :
        [serverGroupPropertyProvider linkForServerGroupName:serverGroupName];
}

- (NSString *) dashboardLinkForServerGroupName:(NSString *)serverGroupName;
{
    return serverReport ? serverReport.dashboardLink :
        [serverGroupPropertyProvider
         dashboardLinkForServerGroupName:serverGroupName];
}

- (NSUInteger) numberOfProjectsForServerGroupName:(NSString *)serverGroupName;
{
    return serverReport ? serverReport.projectReports.count :
        [serverGroupPropertyProvider
         numberOfProjectsForServerGroupName:serverGroupName];
}

#pragma mark Helper functions

- (NSObject<ServerReportBuilder> *) builderForServer:(NSString *)server
{
    return [buildServiceDelegate builderForServer:server];
}

- (BOOL) isCreatingNewServer
{
    return serverReport != nil;
}

- (void) endEditingSession
{
    self.serverReport = nil;
}

#pragma mark Accessors

- (UINavigationController *) addServerNavigationController
{
    if (addServerNavigationController == nil) {
        addServerNavigationController = [[UINavigationController alloc]
            initWithRootViewController:self.addServerViewController];
    }

    return addServerNavigationController;
}

- (AddServerViewController *) addServerViewController
{
    if (addServerViewController == nil) {
        addServerViewController = [[AddServerViewController alloc]
            initWithNibName:@"AddServerView" bundle:nil];
        addServerViewController.delegate = self;
    }

    return addServerViewController;
}

- (EditServerDetailsViewController *) editServerDetailsViewController
{
    if (editServerDetailsViewController == nil) {
        editServerDetailsViewController =
            [[EditServerDetailsViewController alloc]
             initWithNibName:@"EditServerDetailsView" bundle:nil];
        editServerDetailsViewController.delegate = self;
    }

    return editServerDetailsViewController;
}

- (SelectServerTypeViewController *) selectServerTypeViewController
{
    if (selectServerTypeViewController == nil) {
        selectServerTypeViewController =
            [[SelectServerTypeViewController alloc]
             initWithNibName:@"SelectServerTypeView" bundle:nil];
        selectServerTypeViewController.delegate = self;
    }

    return selectServerTypeViewController;
}

- (RssHelpViewController *) rssHelpViewController
{
    if (rssHelpViewController == nil)
        rssHelpViewController =
            [[RssHelpViewController alloc]
             initWithNibName:@"RssHelpView" bundle:nil];

    return rssHelpViewController;
}

- (NSObject<BuildService> *)buildService
{
    if (buildService == nil) {
        // Instantiate concrete type in order to set delegate member.
        NSObject<BuildService> * service =
            [[NetworkBuildService alloc] initWithDelegate:self];
        buildService = service;
    }

    return buildService;
}

@end
