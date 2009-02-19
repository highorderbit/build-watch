//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ProjectReporter

- (void) reportDetailsForProject:(NSString *)projectId animated:(BOOL)animated;

@end
