//
//  build_watchAppDelegate.m
//  build-watch
//
//  Created by Douglas Kurth on 2/3/09.
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "build_watchAppDelegate.h"
#import "RootViewController.h"


@implementation build_watchAppDelegate

@synthesize window;
@synthesize navigationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
