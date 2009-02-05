//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectReporterDelegate.h"

@interface ProjectReportViewController : UIViewController
                                         < UITableViewDelegate >
{
    UITableView * tableView;
    NSString * projectId;
    NSObject<ProjectReporterDelegate> * delegate;
}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain) NSString * projectId;
@property (nonatomic, retain) NSObject<ProjectReporterDelegate> * delegate;

@end
