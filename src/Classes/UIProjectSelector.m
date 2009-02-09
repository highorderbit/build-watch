//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "UIProjectSelector.h"
#import "ProjectsViewController.h";

@implementation UIProjectSelector

@synthesize delegate;
@synthesize navigationController;
@synthesize projectsViewController;

- (void)dealloc
{
    [delegate release];
    [navigationController release];
    [projectsViewController release];
    [super dealloc];
}

#pragma mark ProjectSelector implementation

- (void) selectProjectFrom:(NSArray *)projects
{
    self.projectsViewController.projects = projects;
    UIViewController * topController =
        [self.navigationController topViewController] ;
    if (topController != self.projectsViewController)
        [self.navigationController
         pushViewController:self.projectsViewController
                   animated:YES];
}

#pragma mark Accessors

- (ProjectsViewController *)projectsViewController
{
    if (projectsViewController == nil) {
        projectsViewController = [[ProjectsViewController alloc]
            initWithNibName:@"ProjectsView" bundle:nil];
        projectsViewController.delegate = delegate;
    }
    return projectsViewController;
}

@end
