//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ProjectReporterDelegate

- (NSString *) displayNameForProject:(NSString *)projectId;

- (NSString *) labelForProject:(NSString *)project;

- (NSString *) descriptionForProject:(NSString *)project;

- (NSString *) pubDateForProject:(NSString *)project;

- (NSString *) linkForProject:(NSString *)project;

- (NSString *) buildSucceededStateForProject:(NSString *)project;

@end
