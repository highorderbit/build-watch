//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectReporterDelegate.h"

@interface BuildDetailsViewController : UIViewController
{
    UILabel * headerLabel;
    UIImageView * headerImage;
    UIWebView * webView;
    NSObject<ProjectReporterDelegate> * delegate;

    NSString * projectId;
}

@property (nonatomic, retain) IBOutlet UILabel * headerLabel;
@property (nonatomic, retain) IBOutlet UIImageView * headerImage;
@property (nonatomic, retain) IBOutlet UIWebView * webView;
@property (nonatomic, retain) NSObject<ProjectReporterDelegate> * delegate;
@property (nonatomic, copy) NSString * projectId;

@end
