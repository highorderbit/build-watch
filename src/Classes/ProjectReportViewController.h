//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectReporterDelegate.h"

@interface ProjectReportViewController : UIViewController
                                         < UITableViewDelegate >
{
    UITableView * tableView;
    UIImageView * headerImage;
    UILabel * headerLabel;

    NSString * projectId;
    NSObject<ProjectReporterDelegate> * delegate;
}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain) IBOutlet UIImageView * headerImage;
@property (nonatomic, retain) IBOutlet UILabel * headerLabel;
@property (nonatomic, copy) NSString * projectId;
@property (nonatomic, retain) NSObject<ProjectReporterDelegate> * delegate;

@end
