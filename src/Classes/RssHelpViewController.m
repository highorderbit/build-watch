//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "RssHelpViewController.h"

@implementation RssHelpViewController

@synthesize webView;

- (void)dealloc
{
    [webView release];
    [super dealloc];
}

- (void) viewDidLoad
{
    self.navigationItem.title = NSLocalizedString(@"rsshelp.view.title", @"");

    NSString * htmlFilePath =
        [[NSBundle mainBundle] pathForResource:@"rss-help" ofType:@"html"];  
    if (htmlFilePath) {
        NSString * html = [NSString stringWithContentsOfFile:htmlFilePath];

        // Loading the bundle path as the baseURL of the web view will
        // enable us to embed CSS or image files into the HTML later if
        // desired without any additional code.
        NSString * path = [[NSBundle mainBundle] bundlePath];
        NSURL * url = [NSURL URLWithString:path];

        [webView loadHTMLString:html baseURL:url];
    } else
        NSLog(@"Failed to load RSS Help file.");
}

@end
