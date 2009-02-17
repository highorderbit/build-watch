//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProjectSelector.h"
#import "ProjectSelectorDelegate.h"
#import "ProjectPropertyProvider.h"

@class ProjectsViewController;

@interface UIProjectSelector : NSObject
                               < ProjectSelector >
{
    NSObject<ProjectSelectorDelegate> * delegate;
    NSObject<ProjectPropertyProvider> * propertyProvider;
    UINavigationController * navigationController;
    ProjectsViewController * projectsViewController;
}

@property (nonatomic, retain) IBOutlet NSObject<ProjectSelectorDelegate> *
    delegate;
@property (nonatomic, retain) IBOutlet NSObject<ProjectPropertyProvider> *
    propertyProvider;
@property (nonatomic, retain) IBOutlet UINavigationController *
    navigationController;
@property (nonatomic, retain, readonly) ProjectsViewController *
    projectsViewController;

@end
