//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditServerDetailsViewControllerDelegate.h"

@class ServerReport;

@interface EditServerDetailsViewController : UIViewController
{
    UITableView * tableView;
    UITextField * serverNameTextField;
    NSObject<EditServerDetailsViewControllerDelegate> * delegate;

    ServerReport * serverReport;
}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain) IBOutlet UITextField * serverNameTextField;
@property (nonatomic, retain)
    NSObject<EditServerDetailsViewControllerDelegate> * delegate;
@property (nonatomic, retain) ServerReport * serverReport;

@end
