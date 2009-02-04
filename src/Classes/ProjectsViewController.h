//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectSelectorDelegate.h"

@interface ProjectsViewController : UIViewController <UITableViewDelegate>
{
    UITableView * tableView;
    NSArray * projects;
    NSObject<ProjectSelectorDelegate> * delegate;
}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain) NSArray * projects;
@property (nonatomic, retain) NSObject<ProjectSelectorDelegate> * delegate;

@end
