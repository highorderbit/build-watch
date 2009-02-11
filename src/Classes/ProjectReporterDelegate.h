//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ProjectReporterDelegate

- (NSString *) displayNameForProject:(NSString *)projectId;

- (NSString *) labelForProject:(NSString *)project;

- (NSString *) descriptionForProject:(NSString *)project;

- (NSDate *) pubDateForProject:(NSString *)project;

- (NSString *) linkForProject:(NSString *)project;

- (BOOL) buildSucceededStateForProject:(NSString *)project;

@end
