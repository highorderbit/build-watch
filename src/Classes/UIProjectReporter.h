//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProjectReporter.h"
#import "ProjectPropertyProvider.h"

@class ProjectReportViewController;

@interface UIProjectReporter : NSObject
                               < ProjectReporter >
{
    NSObject<ProjectPropertyProvider> * delegate;

    UINavigationController * navigationController;
    ProjectReportViewController * projectReportViewController;
}

@property (nonatomic, retain) IBOutlet NSObject<ProjectPropertyProvider> *
    delegate;
@property (nonatomic, retain) IBOutlet UINavigationController *
    navigationController;
@property (nonatomic, retain) ProjectReportViewController *
    projectReportViewController;

@end
