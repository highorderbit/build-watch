//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (BuildWatchAdditions)

+ (NSString *) applicationErrorDomain;
+ (NSError *) errorWithLocalizedDescription:(NSString *)localizedDescription;
+ (NSError *) errorWithLocalizedDescription:(NSString *)localizedDescription
                                  rootCause:(NSError *)rootCause;

@end