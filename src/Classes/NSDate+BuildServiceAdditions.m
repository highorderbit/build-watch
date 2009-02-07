//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "NSDate+BuildServiceAdditions.h"

@implementation NSDate (BuildServiceAdditions)

+ (NSDate *)dateFromCruiseControlRbString:(NSString *)dateAsString
{
    static NSString * DATE_FORMAT = @"EEE, dd MMM yyyy HH:mm:ss 'Z'";

    //
    // Consider reusing the DateFormatter instance.
    //

    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = DATE_FORMAT;
    NSDate * date = [dateFormatter dateFromString:dateAsString];
    [dateFormatter release];

    return date;
}

@end
