//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServerReport;

@protocol EditServerDetailsViewControllerDelegate

- (void) userDidEditServerGroupName:(NSString *)serverGroupName
             serverGroupDisplayName:(NSString *)serverGroupDisplayName;

- (void) userDidCancelEditingServerGroupName:(NSString *)serverGroupName;

@end
