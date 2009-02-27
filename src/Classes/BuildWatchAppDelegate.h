//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerGroupSelector.h"

@class BuildWatchAppController;
@class ServerViewController;

@interface BuildWatchAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
    UIViewController * rootViewController;
    UINavigationController *navigationController;
    UIToolbar * toolbar;

    BuildWatchAppController * appController;
    NSObject<ServerGroupSelector> * serverGroupSelector;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIViewController * rootViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *
    navigationController;
@property (nonatomic, retain) IBOutlet UIToolbar * toolbar;
@property (nonatomic, retain) IBOutlet NSObject<ServerGroupSelector> *
    serverGroupSelector;

@property (nonatomic, retain) IBOutlet BuildWatchAppController * appController;

@end

