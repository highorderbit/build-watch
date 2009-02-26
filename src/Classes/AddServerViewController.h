//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
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
    NSString * serverType;

    BOOL waiting;
}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, readonly) UITableViewCell * editServerUrlCell;
@property (nonatomic, retain) NSObject<AddServerViewControllerDelegate> *
    delegate;
@property (nonatomic, copy) NSString * serverUrl;
@property (nonatomic, copy) NSString * serverType;

@end
