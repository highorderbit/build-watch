//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerSelector.h"
#import "ServerSelectorDelegate.h"

@interface ServerViewController : UIViewController
                                  < UITableViewDelegate >
{
    UITableView * tableView;

    NSArray * servers;
    NSObject<ServerSelectorDelegate> * delegate;
}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain) NSArray * servers;
@property (nonatomic, retain) NSObject<ServerSelectorDelegate> * delegate;

@end
