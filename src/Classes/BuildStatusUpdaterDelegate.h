//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BuildStatusUpdater.h"

@protocol BuildStatusUpdaterDelegate

- (void) updater:(NSObject<BuildStatusUpdater> *)updater
  didReceiveData:(NSData *)data;

- (void) updater:(NSObject<BuildStatusUpdater> *)updater
 didReceiveError:(NSError *)error;

@end
