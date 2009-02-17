//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectSelectorDelegate.h"
#import "ProjectTableViewCell.h"
#import "UIColor+BuildWatchColors.h"
#import "ProjectPropertyProvider.h"

@interface ProjectsViewController : UIViewController <UITableViewDelegate>
{
    UITableView * tableView;
    NSArray * projects;
    NSArray * visibleProjects;
    NSObject<ProjectSelectorDelegate> * delegate;
    NSObject<ProjectPropertyProvider> * propertyProvider;
}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, copy) NSArray * projects;
@property (nonatomic, retain)
    NSObject<ProjectSelectorDelegate> * delegate;
@property (nonatomic, retain)
    NSObject<ProjectPropertyProvider> * propertyProvider;

@end
