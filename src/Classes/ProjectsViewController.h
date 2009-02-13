//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectSelectorDelegate.h"
#import "ProjectTableViewCell.h"

@interface ProjectsViewController : UIViewController <UITableViewDelegate>
{
    UITableView * tableView;
    NSArray * projects;
    NSArray * visibleProjects;
    NSObject<ProjectSelectorDelegate> * delegate;
}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, copy) NSArray * projects;
@property (nonatomic, retain) NSObject<ProjectSelectorDelegate> * delegate;

@end
