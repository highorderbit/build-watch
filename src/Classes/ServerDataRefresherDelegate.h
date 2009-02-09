//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ServerDataRefresherDelegate

- (void) refreshingDataForServer:(NSString *)server
                     displayName:(NSString *)displayName;

- (void) didRefreshDataForServer:(NSString *)server
                     displayName:(NSString *)displayName;

- (void) failedToRefreshDataForServer:(NSString *)server
                          displayName:(NSString *)displayName
                                error:(NSError *)error;

@end
