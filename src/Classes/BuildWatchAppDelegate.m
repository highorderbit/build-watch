//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "BuildWatchAppDelegate.h"
#import "ServerViewController.h"
#import "BuildWatchAppController.h"
#import "MockServerPersistentStore.h"

@implementation BuildWatchAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize appController;
@synthesize serverSelector;

- (void)dealloc
{
    [navigationController release];
    [window release];
    [appController release];
    [serverSelector release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"%@: Awaking from nib.", self);
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    // Configure and show the window
    [window addSubview:[navigationController view]];
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
