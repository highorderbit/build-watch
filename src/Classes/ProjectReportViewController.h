//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectPropertyProvider.h"
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
    UILabel * headerProjectLabel;
    UILabel * headerStatusLabel;
    UITableView * tableView;
    ForceBuildTableViewCell * forceBuildTableViewCell;

    NSString * projectId;
    NSObject<ProjectPropertyProvider> * delegate;

    NSObject<BuildForcer> * buildForcer;
    BOOL forcingBuild;
}

@property (nonatomic, retain) IBOutlet UIView * headerView;
@property (nonatomic, retain) IBOutlet UIImageView * headerImage;
@property (nonatomic, retain) IBOutlet UILabel * headerProjectLabel;
@property (nonatomic, retain) IBOutlet UILabel * headerStatusLabel;
@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain) ForceBuildTableViewCell * forceBuildTableViewCell;
@property (nonatomic, copy) NSString * projectId;
@property (nonatomic, retain) NSObject<ProjectPropertyProvider> * delegate;
@property (nonatomic, retain) IBOutlet NSObject<BuildForcer> * buildForcer;

@end
