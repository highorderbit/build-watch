//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddServerViewControllerDelegate.h"

@interface AddServerViewController : UIViewController
                                     < UITableViewDataSource,
                                       UITableViewDelegate,
                                       UITextFieldDelegate >
{
    UITableView * tableView;
    UITableViewCell * editServerUrlCell;

    NSObject<AddServerViewControllerDelegate> * delegate;

    NSString * serverUrl;
}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, readonly) UITableViewCell * editServerUrlCell;
@property (nonatomic, retain) NSObject<AddServerViewControllerDelegate> *
    delegate;
@property (nonatomic, copy) NSString * serverUrl;

@end
