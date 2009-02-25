//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "AboutDisplayer.h"

@interface AboutDisplayer (Private)

- (void) initVersionLabel;
- (void) hideAboutView;

@end

@implementation AboutDisplayer

@synthesize rootViewController;
@synthesize versionLabel;
@synthesize configReader;

- (void) dealloc
{
    [rootViewController release];
    [versionLabel release];
    [configReader release];
    [super dealloc];
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    displayed = NO;
}

- (IBAction) displayAboutView:(id)sender
{
    if (!displayed) {
        displayed = YES;
        [rootViewController presentModalViewController:self animated:YES];
        [self initVersionLabel];

        [[UIApplication sharedApplication]
         setStatusBarStyle:UIStatusBarStyleBlackOpaque
                  animated:YES];
    } else {
        [self hideAboutView];

        [[UIApplication sharedApplication]
         setStatusBarStyle:UIStatusBarStyleDefault
                  animated:YES];
    }
}

- (IBAction) displayWebsite:(id)sender
{
    NSString * webAddress =
        (NSString *) [configReader valueForKey:@"Website"];
    NSURL * url = [[NSURL alloc] initWithString:webAddress];
    
    [[UIApplication sharedApplication] openURL:url];
    [url release];
}

- (IBAction) sendFeedback:(id)sender
{
    NSString * feedbackAddress =
        (NSString *) [configReader valueForKey:@"FeedbackAddress"];
    
    NSString * version =
        (NSString *) [configReader valueForKey:@"CFBundleVersion"];
    
    NSString * subject =
        [NSString stringWithFormat:@"Build Watch %@ feedback", version];
    
    NSString * urlString =
        [[NSString stringWithFormat:@"mailto:%@?subject=%@", feedbackAddress,
         subject]
         stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * url = [[NSURL alloc] initWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
    [url release];
}

#pragma mark Private helper functions

- (void) hideAboutView
{
    displayed = NO;
    [rootViewController dismissModalViewControllerAnimated:YES];
}

- (void) initVersionLabel
{
    NSString * versionText =
        (NSString *) [configReader valueForKey:@"CFBundleVersion"];
 
    NSString * versionLabelText =
        [NSString stringWithFormat:@"Version %@", versionText];
    
    [versionLabel setText:versionLabelText];
}

@end
