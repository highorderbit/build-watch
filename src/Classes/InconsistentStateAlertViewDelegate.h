//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BuildWatchAppController.h"
#import "BuildWatchPersistentStore.h"

@interface InconsistentStateAlertViewDelegate : NSObject <UIAlertViewDelegate>
{
    BuildWatchAppController * appController;
    NSObject<BuildWatchPersistentStore> *  persistentStore;
}

- (InconsistentStateAlertViewDelegate *)
    initWithAppController:(BuildWatchAppController *)appController
    andPersistentStore:
    (NSObject<BuildWatchPersistentStore> *)persistentStore;

@end
