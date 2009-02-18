//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ServerGroupNameSelectorDelegate

- (void) userDidSelectServerGroupName:(NSString *)serverGroupName;

- (void) userDidDeselectServerGroupName;

- (NSString *) displayNameForServerGroupName:(NSString *)serverGroupName;

- (NSString *) webAddressForServerGroupName:(NSString *)serverGroupName;

- (int) numBrokenForServerGroupName:(NSString *)serverGroupName;

- (BOOL) canServerGroupBeDeleted:(NSString *)serverGroupName;

- (void) deleteServerGroupWithName:(NSString *)serverGroupName;

- (void) createServerGroup;

- (void) editServerGroupName:(NSString *)serverGroupName;

- (void) userDidSetServerGroupSortOrder:(NSArray *)serverGroupNames;

@end
