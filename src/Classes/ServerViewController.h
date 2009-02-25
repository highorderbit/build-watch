//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerGroupNameSelector.h"
#import "ServerGroupNameSelectorDelegate.h"

@interface ServerViewController : UIViewController
                                  < UITableViewDelegate >
{
    UITableView * tableView;
    UIBarButtonItem * addBarButtonItem;

    NSMutableArray * serverGroupNames;
    NSMutableArray * visibleServerGroupNames;
    NSObject<ServerGroupNameSelectorDelegate> * delegate;
}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain)
    NSObject<ServerGroupNameSelectorDelegate> * delegate;

- (void) setServerGroupNames:(NSArray *)someServerGroupNames;

@end
