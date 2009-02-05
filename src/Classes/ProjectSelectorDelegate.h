//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ProjectSelectorDelegate

- (void) userDidSelectProject:(NSString *)project;

- (void) userDidDeselectServer;

- (NSString *) displayNameForProject:(NSString *)project;

@end
