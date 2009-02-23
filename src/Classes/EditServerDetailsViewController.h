//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerGroupPropertyProvider.h"
#import "EditServerDetailsViewControllerDelegate.h"

@interface EditServerDetailsViewController : UIViewController
                                             < UITableViewDataSource,
                                               UITableViewDelegate,
                                               UITextFieldDelegate >
{
    UITableView * tableView;
    UITableViewCell * editServerNameCell;

    NSObject<EditServerDetailsViewControllerDelegate> * delegate;

    NSObject<ServerGroupPropertyProvider> * serverGroupPropertyProvider;

    NSString * serverGroupName;  // what the user provides
    NSString * serverGroupDisplayName;  // what the user provides
}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, readonly) UITableViewCell * editServerNameCell;
@property (nonatomic, retain)
    NSObject<EditServerDetailsViewControllerDelegate> * delegate;
@property (nonatomic, retain) NSObject<ServerGroupPropertyProvider> *
    serverGroupPropertyProvider;
@property (nonatomic, copy) NSString * serverGroupName;
@property (nonatomic, copy) NSString * serverGroupDisplayName;

@end
