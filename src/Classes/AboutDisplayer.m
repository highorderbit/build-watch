//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "AboutDisplayer.h"

@interface AboutDisplayer (Private)

- (void) initVersionLabel;
- (void) hideAboutView;

@end

@implementation AboutDisplayer

@synthesize rootView;
@synthesize aboutButton;
@synthesize versionLabel;
@synthesize configReader;

- (void) dealloc
{
    [rootView release];
    [aboutButton release];
    [versionLabel release];
    [configReader release];
    [super dealloc];
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    displayed = NO;
    self.navigationItem.title = @"About";
}

- (IBAction) displayAboutView:(id)sender
{
    if (!displayed) {
        displayed = YES;
        [rootView presentModalViewController:self animated:YES];
        [self initVersionLabel];
        aboutButton.style = UIBarButtonItemStyleDone;
        aboutButton.title = @"Done";

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
    NSString * urlString =
        [NSString stringWithFormat:@"mailto:%@", feedbackAddress];
    
    NSURL * url = [[NSURL alloc] initWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
    [url release];
}

#pragma mark Private helper functions

- (void) hideAboutView
{
    displayed = NO;
    [rootView dismissModalViewControllerAnimated:YES];
    aboutButton.style = UIBarButtonItemStyleBordered;
    aboutButton.title = @"About";
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
