//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "UIServerGroupCreator.h"
#import "AddServerViewController.h"
#import "EditServerDetailsViewController.h"
#import "NetworkBuildService.h"

@implementation UIServerGroupCreator

@synthesize rootNavigationController;
@synthesize addServerNavigationController;
@synthesize addServerViewController;
@synthesize editServerDetailsViewController;
@synthesize delegate;
@synthesize buildService;
@synthesize buildServiceDelegate;
@synthesize serverUrl;

- (void) dealloc
{
    [rootNavigationController release];
    [addServerNavigationController release];
    [addServerViewController release];
    [editServerDetailsViewController release];
    [delegate release];
    [buildService release];
    [buildServiceDelegate release];
    [serverUrl release];
    [super dealloc];
}

#pragma mark ServerGroupCreator protocol implementation

- (void) createServerGroup
{
    self.addServerViewController.serverUrl = @"";

    [self.addServerNavigationController popToRootViewControllerAnimated:NO];
    [self.rootNavigationController
        presentModalViewController:self.addServerNavigationController
                          animated:YES];
}

#pragma mark AddServerViewControllerDelegate protocol implementation

- (void) addServerWithUrl:(NSString *)url
{
    self.serverUrl = url;
    [self.buildService refreshDataForServer:url];
}

- (void) userDidCancel
{
    NSLog(@"Attempting to cancel connection to: '%@'.", serverUrl);

    [buildService cancelRefreshForServer:self.serverUrl];

    [self.rootNavigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark EditServerDetailsViewControllerDelegate protocol implementation

- (void) userDidAddServerNamed:(NSString *)serverName
        withInitialBuildReport:(ServerReport *)serverReport
{
    [delegate serverGroupCreatedWithName:serverName
                   andInitialBuildReport:serverReport];

    [rootNavigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark BuildServiceDelegate protocol implementation

- (void) report:(ServerReport *)report receivedFrom:(NSString *)theServerUrl
{
    NSLog(@"Received build report: '%@' from server: '%@'.",
        report, theServerUrl);

    EditServerDetailsViewController * controller =
        self.editServerDetailsViewController;
    controller.serverReport = report;

    self.serverUrl = nil;

    [self.addServerNavigationController
        pushViewController:controller animated:YES];
}

- (void) attemptToGetReportFromServer:(NSString *)theServerUrl
                     didFailWithError:(NSError *)error
{
    NSLog(@"Failed to get report from server: '%@', error: '%@'.", theServerUrl,
        error);

    UIAlertView * alertView =
        [[[UIAlertView alloc]
          initWithTitle:NSLocalizedString(@"addserver.error.alert.title", @"")
                message:error.localizedDescription
               delegate:self
      cancelButtonTitle:NSLocalizedString(@"addserver.error.alert.ok", @"")
      otherButtonTitles:nil]
         autorelease];

    [alertView show];

    self.serverUrl = nil;

    [addServerViewController viewWillAppear:NO];
}

#pragma mark Helper functions

- (NSObject<ServerReportBuilder> *) builderForServer:(NSString *)server
{
    return [buildServiceDelegate builderForServer:server];
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
