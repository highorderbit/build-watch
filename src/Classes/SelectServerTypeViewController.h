//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectServerTypeViewControllerDelegate.h"

@interface SelectServerTypeViewController : UIViewController
{
    UITableView * tableView;

    NSArray * serverTypes;
    NSInteger selectedServerType;

    NSObject<SelectServerTypeViewControllerDelegate> * delegate;
}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property NSInteger selectedServerType;
@property (nonatomic, retain) NSObject<SelectServerTypeViewControllerDelegate> *
    delegate;

@end
