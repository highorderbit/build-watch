//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProjectPropertyProvider

- (NSString *) displayNameForProject:(NSString *)project;

- (BOOL) trackedStateForProject:(NSString *)project;

- (NSString *) labelForProject:(NSString *)project;

- (NSString *) descriptionForProject:(NSString *)project;

- (NSDate *) pubDateForProject:(NSString *)project;

- (NSString *) linkForProject:(NSString *)project;

- (NSString *) forceBuildLinkForProject:(NSString *)project;

- (BOOL) buildSucceededStateForProject:(NSString *)project;

@end
