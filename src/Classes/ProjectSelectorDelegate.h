//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ProjectSelectorDelegate

- (void) userDidSelectProject:(NSString *)project;

- (void) setTrackedState:(BOOL)state onProject:(NSString *)project;

- (NSString *) displayNameForCurrentProjectGroup;

@end
