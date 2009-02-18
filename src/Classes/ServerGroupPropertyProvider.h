//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerGroupPropertyProvider

- (NSString *) displayNameForServerGroupName:(NSString *)serverGroupName;

- (NSString *) linkForServerGroupName:(NSString *)serverGroupName;

- (NSString *) dashboardLinkForServerGroupName:(NSString *)serverGroupName;

- (NSUInteger) numberOfProjectsForServerGroupName:(NSString *)serverGroupName;

@end
