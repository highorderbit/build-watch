//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "NSDate+BuildServiceAdditions.h"

@implementation NSDate (BuildServiceAdditions)

+ (NSDate *) dateFromString:(NSString *)string format:(NSString *)formatString
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = formatString;
    NSDate * date = [formatter dateFromString:string];
    [formatter release];

    return date;
}

- (NSString *) localizedString
{
    NSString * localFormat = NSLocalizedString(@"date.format.localized", @"");

    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = localFormat;
    NSString * s = [dateFormatter stringFromDate:self];
    [dateFormatter release];

    return s;
}

@end