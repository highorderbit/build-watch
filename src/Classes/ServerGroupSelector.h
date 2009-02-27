//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerGroupSelector

- (void) selectServerGroupsFrom:(NSArray *)someServerGroups
                      animated:(BOOL)animated;

@end
