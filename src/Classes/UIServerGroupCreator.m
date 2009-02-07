//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "UIServerGroupCreator.h"
#import "AddServerViewController.h"
#import "EditServerDetailsViewController.h"
#import "MockBuildService.h"

@implementation UIServerGroupCreator

@synthesize rootNavigationController;
@synthesize addServerNavigationController;
@synthesize addServerViewController;
@synthesize editServerDetailsViewController;
@synthesize delegate;
@synthesize buildService;

- (void) dealloc
{
    [rootNavigationController release];
    [addServerNavigationController release];
    [addServerViewController release];
    [editServerDetailsViewController release];
    [delegate release];
    [buildService release];
    [super dealloc];
}

#pragma mark ServerGroupCreator protocol implementation

- (void) createServerGroup
{
    [self.addServerNavigationController popToRootViewControllerAnimated:NO];
    [self.rootNavigationController
        presentModalViewController:self.addServerNavigationController
                          animated:YES];
}

#pragma mark AddServerViewControllerDelegate protocol implementation

- (void) addServerWithUrl:(NSString *)url
{
    [self.buildService refreshDataForServer:url];
}

- (void) userDidCancel
{
    [rootNavigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark EditServerDetailsViewControllerDelegate protocol implementation

- (void) userDidAddServerNamed:(NSString *)serverName
        withInitialBuildReport:(ServerReport *)serverReport
{
    [rootNavigationController dismissModalViewControllerAnimated:YES];
    [delegate serverGroupCreatedWithName:serverName
                   andInitialBuildReport:serverReport];
}

#pragma mark BuildServiceDelegate protocol implementation

- (void) report:(ServerReport *)report receivedFrom:(NSString *)server
{
    // TODO: add error handling code

    NSLog(@"Received build report: '%@' from server: '%@'.", report, server);

    EditServerDetailsViewController * controller =
        self.editServerDetailsViewController;
    controller.serverReport = report;

    [self.addServerNavigationController
        pushViewController:controller animated:YES];
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
        MockBuildService * service = [[MockBuildService alloc] init];
        service.delegate = self;
        buildService = service;
    }

    return buildService;
}

@end
