//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "NSDate+StringHelpers.h"
#import "NSDate+IsToday.h"

@implementation NSDate (StringHelpers)

- (NSString *) buildWatchDescription
{
    NSDateFormatter * formatter = [[[NSDateFormatter alloc] init]  autorelease];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    return [formatter stringFromDate:self];
}

- (NSString *) shortDescription
{
    NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
    
    if ([self isToday])
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    else if ([self isLessThanWeekAgo]) {
        // Seems like you should be able to set the date format on the current
        // formatter instance, but it doesn't format properly, so...
        formatter =
            [[[NSDateFormatter alloc]
              initWithDateFormat:@"%A" allowNaturalLanguage:NO] autorelease];
    } else
        [formatter setDateStyle:NSDateFormatterShortStyle];

    return [formatter stringFromDate:self];
}

+ (NSDate *) dateFromString:(NSString *)string format:(NSString *)formatString
{
    NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
    formatter.dateFormat = formatString;
    NSDate * date = [formatter dateFromString:string];
    
    return date;
}

@end