//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditServerDetailsViewControllerDelegate.h"

@class ServerReport;

@interface EditServerDetailsViewController : UIViewController
                                             < UITableViewDataSource,
                                               UITableViewDelegate,
                                               UITextFieldDelegate >
{
    UITableView * tableView;
    UITableViewCell * editServerNameCell;

    NSObject<EditServerDetailsViewControllerDelegate> * delegate;

    ServerReport * serverReport;
    NSString * serverName;  // what the user provides
}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, readonly) UITableViewCell * editServerNameCell;
@property (nonatomic, retain)
    NSObject<EditServerDetailsViewControllerDelegate> * delegate;
@property (nonatomic, retain) ServerReport * serverReport;
@property (nonatomic, retain) NSString * serverName;

@end
