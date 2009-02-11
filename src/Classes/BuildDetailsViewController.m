//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "BuildDetailsViewController.h"

@implementation BuildDetailsViewController

@synthesize headerLabel;
@synthesize headerImage;
@synthesize webView;
@synthesize delegate;
@synthesize projectId;

- (void) dealloc
{
    [headerLabel release];
    [headerImage release];
    [webView release];
    [delegate release];
    [projectId release];
    [super dealloc];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSString * displayName = [delegate displayNameForProject:projectId];
    NSString * label = [delegate labelForProject:projectId];
    NSString * description = [delegate descriptionForProject:projectId];

    self.navigationItem.title =
        [NSString stringWithFormat:
         NSLocalizedString(@"builddetails.title.formatstring", @""),
         displayName, label];

    NSString * bodyCss = @"font-family: 'Lucida Grande';"
                          "font-size: 3em;"
                          "margin: 30px";
    NSString * html = [NSString stringWithFormat:
        @"<html><head><title>%@</title></head>"
        "<body style=\"%@\">%@</body>"
         "</body></html>",
        displayName, bodyCss, description];

    [webView loadHTMLString:html baseURL:[NSURL URLWithString:@"/"]];
}

@end
