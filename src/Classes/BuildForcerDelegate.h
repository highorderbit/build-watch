//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BuildForcerDelegate

- (void) buildForcedForProject:(NSString *)projectUrl
             withForceBuildUrl:(NSString *)projectForceBuildUrl;

- (void) forceBuildForProject:(NSString *)projectUrl
            withForceBuildUrl:(NSString *)projectForceBuildUrl
             didFailWithError:(NSError *)error;

@end