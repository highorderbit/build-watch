//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectPropertyProvider.h"

@interface BuildDetailsViewController : UIViewController
                                        < UIWebViewDelegate >
{
    UILabel * headerLabel;
    UIImageView * headerImage;
    UIWebView * webView;
    NSObject<ProjectPropertyProvider> * delegate;

    NSString * projectId;
}

@property (nonatomic, retain) IBOutlet UILabel * headerLabel;
@property (nonatomic, retain) IBOutlet UIImageView * headerImage;
@property (nonatomic, retain) IBOutlet UIWebView * webView;
@property (nonatomic, retain) NSObject<ProjectPropertyProvider> * delegate;
@property (nonatomic, copy) NSString * projectId;

@end
