//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddServerViewControllerDelegate.h"

@interface AddServerViewController : UIViewController
{
    UITableView * tableView;
    UITextField * serverUrlTextView;
    NSObject<AddServerViewControllerDelegate> * delegate;
}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain) IBOutlet UITextField * serverUrlTextView;
@property (nonatomic, retain) NSObject<AddServerViewControllerDelegate> *
    delegate;

@end
