//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "InconsistentStateAlertViewDelegate.h"

@implementation InconsistentStateAlertViewDelegate

- (void) dealloc
{
    [appController release];
    [persistentStore release];
    [super dealloc];
}

- (InconsistentStateAlertViewDelegate *)
    initWithAppController:(BuildWatchAppController *)someAppController
    andPersistentStore:
    (NSObject<BuildWatchPersistentStore> *)somePersistentStore
{
    [super init];
    appController = [someAppController retain];
    persistentStore = [somePersistentStore retain];
    
    return self;
}


- (void)            alertView:(UIAlertView *)alertView
    didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { // restore
        [persistentStore restoreToDefaultState];
        [appController start];
    } else // ignore
        [appController refreshDataAndDisplayInitialView];
}

@end
