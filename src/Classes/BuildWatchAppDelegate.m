//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "BuildWatchAppDelegate.h"
#import "ServerViewController.h"
#import "BuildWatchAppController.h"

@implementation BuildWatchAppDelegate

@synthesize window;
@synthesize rootViewController;
@synthesize navigationController;
@synthesize toolbar;
@synthesize appController;
@synthesize serverGroupNameSelector;

- (void)dealloc
{
    [window release];
    [rootViewController release];
    [navigationController release];
    [toolbar release];
    [appController release];
    [serverGroupNameSelector release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    UIView * rootView = rootViewController.view;

    CGRect toolbarFrame = [toolbar frame];
    CGRect navFrame = [[navigationController view] frame];
    navFrame.size.height = navFrame.size.height - toolbarFrame.size.height;
    navFrame.origin.y = 0.0;
    toolbarFrame.origin.y = navFrame.origin.y + navFrame.size.height;
    [[navigationController view] setFrame:navFrame];
    [toolbar setFrame:toolbarFrame];

    CGRect rootFrame = [rootView frame];
    rootFrame.origin.y = 20.0;  // slide down to make room for the status bar
    [rootView setFrame:rootFrame];

    // Configure and show the window
    [rootView addSubview:[navigationController view]];
    [rootView addSubview:toolbar];

    [navigationController viewWillAppear:YES];
    [rootViewController viewWillAppear:YES];
    [window addSubview:rootView];
    [window makeKeyAndVisible];

    [appController start];
}

- (void) applicationWillTerminate:(UIApplication *)application
{
    [appController persistState];
}

@end
