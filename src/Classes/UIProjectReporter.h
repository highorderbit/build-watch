//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProjectReporter.h"
#import "ProjectReporterDelegate.h"

@class ProjectReportViewController;

@interface UIProjectReporter : NSObject
                               < ProjectReporter >
{
    NSObject<ProjectReporterDelegate> * delegate;
    UINavigationController * navigationController;
    ProjectReportViewController * projectReportViewController;
}

@property (nonatomic, retain) IBOutlet NSObject<ProjectReporterDelegate> *
    delegate;
@property (nonatomic, retain) IBOutlet UINavigationController *
    navigationController;
@property (nonatomic, retain) ProjectReportViewController *
    projectReportViewController;

@end
