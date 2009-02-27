//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerGroupPropertyProvider

- (NSString *) displayNameForServerGroup:(NSString *)serverGroup;

- (NSString *) dashboardLinkForServerGroup:(NSString *)serverGroup;

- (NSUInteger) numberOfProjectsForServerGroup:(NSString *)serverGroup;

@end
