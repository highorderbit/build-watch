//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectsViewController : UIViewController <UITableViewDelegate>
{
    UITableView * tableView;
}

@property (nonatomic, retain) IBOutlet UITableView * tableView;

@end
