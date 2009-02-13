//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectReporterDelegate.h"
#import "BuildForcer.h"
#import "BuildForcerDelegate.h"

@class ForceBuildTableViewCell;

@interface ProjectReportViewController : UIViewController
                                         < UITableViewDelegate,
                                           UITableViewDataSource,
                                           BuildForcerDelegate >
{
    UIView * headerView;
    UIImageView * headerImage;
    UILabel * headerLabel;
    UITableView * tableView;
    ForceBuildTableViewCell * forceBuildTableViewCell;

    NSString * projectId;
    NSObject<ProjectReporterDelegate> * delegate;

    NSObject<BuildForcer> * buildForcer;
}

@property (nonatomic, retain) IBOutlet UIView * headerView;
@property (nonatomic, retain) IBOutlet UIImageView * headerImage;
@property (nonatomic, retain) IBOutlet UILabel * headerLabel;
@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain) ForceBuildTableViewCell * forceBuildTableViewCell;
@property (nonatomic, copy) NSString * projectId;
@property (nonatomic, retain) NSObject<ProjectReporterDelegate> * delegate;
@property (nonatomic, retain) IBOutlet NSObject<BuildForcer> * buildForcer;

@end
