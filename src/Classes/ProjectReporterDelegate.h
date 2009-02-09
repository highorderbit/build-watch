//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ProjectReporterDelegate

- (NSString *) displayNameForProject:(NSString *)projectId;

- (NSString *) linkForProject:(NSString *)projectId;

@end
