//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ProjectSelectorDelegate

- (void) userDidSelectProject:(NSString *)project;

- (NSString *) displayNameForProject:(NSString *)project;

- (void) userDidDeselectServerGroupName;

- (NSString *) displayNameForCurrentProjectGroup;

@end
