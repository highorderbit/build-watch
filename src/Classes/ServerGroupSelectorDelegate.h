//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ServerGroupSelectorDelegate

- (void) userDidSelectServerGroup:(NSString *)serverGroup;

- (void) userDidDeselectServerGroup;

- (NSString *) displayNameForServerGroup:(NSString *)serverGroup;

- (NSString *) webAddressForServerGroup:(NSString *)serverGroup;

- (int) numBrokenForServerGroup:(NSString *)serverGroup;

- (BOOL) canServerGroupBeDeleted:(NSString *)serverGroup;

- (void) deleteServerGroupWithKey:(NSString *)serverGroupKey;

- (void) createServerGroup;

- (void) editServerGroup:(NSString *)serverGroup;

- (void) userDidSetServerGroupSortOrder:(NSArray *)serverGroups;

@end
