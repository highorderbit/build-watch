//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerSelector.h"

@class BuildWatchAppController;
@class ServerViewController;

@interface BuildWatchAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
    UINavigationController *navigationController;
    UIToolbar * toolbar;

    BuildWatchAppController * appController;
    NSObject<ServerSelector> * serverSelector;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *
    navigationController;
@property (nonatomic, retain) IBOutlet UIToolbar * toolbar;
@property (nonatomic, retain) IBOutlet NSObject<ServerSelector> *
    serverSelector;

@property (nonatomic, retain) IBOutlet BuildWatchAppController * appController;

@end

