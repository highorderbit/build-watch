//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerGroupSelector.h"
#import "ServerGroupSelectorDelegate.h"

@interface ServerViewController : UIViewController
                                  < UITableViewDelegate >
{
    UITableView * tableView;
    UIBarButtonItem * addBarButtonItem;

    NSMutableArray * serverGroupNames;
    NSObject<ServerGroupSelectorDelegate> * delegate;
}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain)
    NSObject<ServerGroupSelectorDelegate> * delegate;

- (void) setServerGroupNames:(NSArray *)someServerGroupNames;

@end
