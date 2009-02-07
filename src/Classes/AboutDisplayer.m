//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "AboutDisplayer.h"

@implementation AboutDisplayer

@synthesize navController;
@synthesize aboutViewController;

- (void) dealloc
{
    [navController release];
    [aboutViewController release];
    [super dealloc];
}

- (void) awakeFromNib
{
    aboutViewController.navigationItem.title = @"About";
}

- (IBAction) displayAboutView:(id)sender
{
    [navController pushViewController:aboutViewController animated:YES];
}

@end
