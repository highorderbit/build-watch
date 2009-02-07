//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ServerGroupNameSelectorDelegate

- (void) userDidSelectServerGroupName:(NSString *)serverGroupName;

- (NSString *) displayNameForServerGroupName:(NSString *)serverGroupName;

- (BOOL) canServerGroupBeDeleted:(NSString *)serverGroupName;

- (void) deleteServerGroupWithName:(NSString *)serverGroupName;

- (void) createServerGroup;

@end
