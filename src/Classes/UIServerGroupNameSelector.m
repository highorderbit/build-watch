//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "UIServerGroupNameSelector.h"
#import "ServerViewController.h"

@implementation UIServerGroupNameSelector

@synthesize delegate;
@synthesize navigationController;
@synthesize serverViewController;

- (void)dealloc
{
    [delegate release];
    [navigationController release];
    [serverViewController release];
    [super dealloc];
}

#pragma mark ServerSelector protocol methods

- (void) selectServerGroupNamesFrom:(NSArray *)someServerGroupNames
                           animated:(BOOL)animated
{
    [self.serverViewController setServerGroupNames:someServerGroupNames];
    UIViewController * topViewController =
        self.navigationController.topViewController;

    if (topViewController != serverViewController) {
        self.serverViewController.navigationItem.title =
            NSLocalizedString(@"servergroups.view.title", @"");
        [self.navigationController pushViewController:self.serverViewController
                                             animated:animated];
    }
}

#pragma mark Accessors

- (ServerViewController *) serverViewController
{
    if (serverViewController == nil) {
        serverViewController = [[ServerViewController alloc]
            initWithNibName:@"ServerView" bundle:nil];
        serverViewController.delegate = delegate;
    }
    return serverViewController;
}

@end
