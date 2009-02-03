//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "BuildWatchAppDelegate.h"
#import "RootViewController.h"

@implementation BuildWatchAppDelegate

@synthesize window;
@synthesize navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Save data if appropriate
}

- (void)dealloc
{
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
