//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "AboutDisplayer.h"

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
    self.navigationItem.title = @"About";
}

- (void) viewWillDisappear:(BOOL)animated
{
    [aboutButton setEnabled:YES];
}

- (IBAction) displayAboutView:(id)sender
{
    [navController pushViewController:self animated:YES];
    [aboutButton setEnabled:NO];
    NSDictionary * infoPList = [PListUtils readDictionaryFromPList:@"Info"];
    NSString * versionText = [infoPList objectForKey:@"CFBundleVersion"];
    NSString * versionLabelText =
        [NSString stringWithFormat:@"Version %@", versionText];
    [versionLabel setText:versionLabelText];
}

- (IBAction) displayWebsite:(id)sender
{
    NSString * webAddress = @"http://www.sandbox.highorderbit.com/home";
    NSURL * url = [[NSURL alloc] initWithString:webAddress];
    [[UIApplication sharedApplication] openURL:url];
    [url release];
}

@end
