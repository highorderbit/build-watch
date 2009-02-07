//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ServerDataRefresherDelegate

- (void) refreshingDataForServer:(NSString *)server;

- (void) didRefreshDataForServer:(NSString *)server;

@end
