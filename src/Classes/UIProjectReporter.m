//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "UIProjectReporter.h"
#import "ProjectReportViewController.h"


@implementation UIProjectReporter

@synthesize delegate;
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

- (void) reportDetailsForProject:(NSString *)projectId
{
    self.projectReportViewController.projectId = projectId;
    [self.navigationController
        pushViewController:self.projectReportViewController animated:YES];
}

#pragma mark Accessors

- (ProjectReportViewController *)projectReportViewController
{
    if (projectReportViewController == nil) {
        projectReportViewController = [[ProjectReportViewController alloc]
            initWithNibName:@"ProjectReportView" bundle:nil];
        projectReportViewController.delegate = delegate;
    }
    return projectReportViewController;
}

@end
