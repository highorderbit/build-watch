//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (BuildWatchAdditions)

+ (NSString *) stringWithData:(NSData *)data
                     encoding:(NSStringEncoding)encoding;

- (BOOL) beginsWithString:(NSString *)s;
- (BOOL) endsWithString:(NSString *)s;

- (NSString *) stringByMatchingRegex:(NSString *)regex;
- (NSString *) stringByMatchingRegex:(NSString *)regex
                             capture:(NSInteger)capture;

@end
