//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerGroupPropertyProvider.h"
#import "EditServerDetailsViewControllerDelegate.h"

@class TextFieldTableViewCell;

@interface EditServerDetailsViewController : UIViewController
                                             < UITableViewDataSource,
                                               UITableViewDelegate,
                                               UITextFieldDelegate >
{
    UITableView * tableView;
    TextFieldTableViewCell * editServerNameCell;

    NSObject<EditServerDetailsViewControllerDelegate> * delegate;

    NSObject<ServerGroupPropertyProvider> * serverGroupPropertyProvider;

    NSString * serverGroupKey;
    NSString * serverGroupName;  // what the user provides
}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, readonly) TextFieldTableViewCell * editServerNameCell;
@property (nonatomic, retain)
    NSObject<EditServerDetailsViewControllerDelegate> * delegate;
@property (nonatomic, retain) NSObject<ServerGroupPropertyProvider> *
    serverGroupPropertyProvider;
@property (nonatomic, copy) NSString * serverGroupKey;
@property (nonatomic, copy) NSString * serverGroupName;

@end
