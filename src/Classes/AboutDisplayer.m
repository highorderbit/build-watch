//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "AboutDisplayer.h"

@interface AboutDisplayer (Private)

- (void) initVersionLabel;
- (void) hideAboutView;

@end

@implementation AboutDisplayer

@synthesize navController;
@synthesize aboutButton;
@synthesize versionLabel;

- (void) dealloc
{
    [navController release];
    [aboutButton release];
    [versionLabel release];
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
        [navController presentModalViewController:self animated:YES];
        [self initVersionLabel];
        aboutButton.style = UIBarButtonItemStyleDone;
        aboutButton.title = @"Done";
    } else
        [self hideAboutView];
}

- (IBAction) displayWebsite:(id)sender
{
    NSString * webAddress = @"http://www.sandbox.highorderbit.com/home";
    NSURL * url = [[NSURL alloc] initWithString:webAddress];
    [[UIApplication sharedApplication] openURL:url];
    [url release];
}

- (IBAction) sendFeedback:(id)sender
{
    NSString * feedbackAddress = @"buildwatchfeedback@highorderbit.com";
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
    [navController dismissModalViewControllerAnimated:YES];
    aboutButton.style = UIBarButtonItemStyleBordered;
    aboutButton.title = @"About";
}

- (void) initVersionLabel
{
    NSString * fullPath = [PlistUtils fullBundlePathForPlist:@"Info"];
    NSDictionary * infoPList = [PlistUtils readDictionaryFromPlist:fullPath];
    NSString * versionText = [infoPList objectForKey:@"CFBundleVersion"];
    NSString * versionLabelText =
        [NSString stringWithFormat:@"Version %@", versionText];
    
    [versionLabel setText:versionLabelText];
}

@end
