//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "BuildWatchAppDelegate.h"
#import "ServerViewController.h"
#import "BuildWatchAppController.h"
#import "MockBuildWatchPersistentStore.h"

@implementation BuildWatchAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize toolbar;
@synthesize appController;
@synthesize serverGroupNameSelector;

- (void)dealloc
{
    [navigationController release];
    [toolbar release];
    [window release];
    [appController release];
    [serverGroupNameSelector release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"%@: Awaking from nib.", self);
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    CGRect toolbarFrame = [toolbar frame];
    CGRect navFrame = [[navigationController view] frame];
    navFrame.size.height = navFrame.size.height - toolbarFrame.size.height;
    toolbarFrame.origin.y = navFrame.origin.y + navFrame.size.height;
    [[navigationController view] setFrame:navFrame];
    [toolbar setFrame:toolbarFrame];

    // Configure and show the window
    [window addSubview:[navigationController view]];
    [window addSubview:toolbar];
    [window makeKeyAndVisible];

    /*
    NSObject<ServerPersistentStore> * store =
        [[MockServerPersistentStore alloc] init];
    appController = [[BuildWatchAppController alloc]
        initWithPersistentStore:store
              andServerSelector:serverSelector];
    [store release];
     */

    [appController start];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Save data if appropriate
}

@end
