//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BuildForcer

- (void) forceBuildForProject:(NSString *)projectUrl
            withForceBuildUrl:(NSString *)projectForceBuildUrl;

@end