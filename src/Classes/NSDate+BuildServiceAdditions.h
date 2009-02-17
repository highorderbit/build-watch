//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (BuildServiceAdditions)

+ (NSDate *) dateFromCruiseControlRbString:(NSString *)dateAsString;

+ (NSDate *) dateWithString:(NSString *)string format:(NSString *)formatString;

- (NSString *) localizedString;

@end
