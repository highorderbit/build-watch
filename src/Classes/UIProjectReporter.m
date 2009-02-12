//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "UIProjectReporter.h"
//#import "CcrbBuildForcer.h"
#import "ProjectReportViewController.h"

@implementation UIProjectReporter

@synthesize delegate;
//@synthesize buildForcer;
@synthesize navigationController;
@synthesize projectReportViewController;

- (void) dealloc
{
    [delegate release];
    //[buildForcer release];
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

- (ProjectReportViewController *) projectReportViewController
{
    if (projectReportViewController == nil) {
        projectReportViewController = [[ProjectReportViewController alloc]
            initWithNibName:@"ProjectReportView" bundle:nil];
        projectReportViewController.delegate = delegate;
        //projectReportViewController.buildForcer = self.buildForcer;
        //self.buildForcer.delegate = projectReportViewController;
    }
    return projectReportViewController;
}

/*
- (CcrbBuildForcer *) buildForcer
{
    if (buildForcer == nil)
        buildForcer = [[CcrbBuildForcer alloc] init];

    return buildForcer;
}
*/

@end
