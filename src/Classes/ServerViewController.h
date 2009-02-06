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

    NSArray * serverGroupNames;
    NSArray * visibleServerGroupNames;
    NSObject<ServerGroupNameSelectorDelegate> * delegate;

    UIBarButtonItem * addBarButtonItem;
}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain) NSArray * serverGroupNames;
@property (nonatomic, retain) NSArray * visibleServerGroupNames;
@property (nonatomic, retain)
    NSObject<ServerGroupNameSelectorDelegate> * delegate;

@end
