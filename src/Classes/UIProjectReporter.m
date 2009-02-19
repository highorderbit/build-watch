//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "UIProjectReporter.h"
#import "ProjectReportViewController.h"

@implementation UIProjectReporter

@synthesize delegate;
//@synthesize buildForcer;
@synthesize navigationController;
@synthesize projectReportViewController;

- (void) dealloc
{
    [delegate release];
    [navigationController release];
    [projectReportViewController release];
    [super dealloc];
}

#pragma mark ProjectReporter protocol methods

- (void) reportDetailsForProject:(NSString *)projectId animated:(BOOL)animated
{
    self.projectReportViewController.projectId = projectId;
    UIViewController * topController =
        [self.navigationController topViewController];
    if (topController != self.projectReportViewController)
        [self.navigationController
            pushViewController:self.projectReportViewController
            animated:animated];
    else
        [self.projectReportViewController viewWillAppear:NO];
}

#pragma mark Accessors

- (ProjectReportViewController *) projectReportViewController
{
    if (projectReportViewController == nil) {
        projectReportViewController = [[ProjectReportViewController alloc]
            initWithNibName:@"ProjectReportView" bundle:nil];
        projectReportViewController.delegate = delegate;
    }
    return projectReportViewController;
}

@end