//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "NSDate+IsToday.h"

@implementation NSDate (IsToday)

- (BOOL) isToday
{
    NSCalendar * currentCalendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags =
        NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    NSDateComponents * selfComponents =
        [currentCalendar components:unitFlags fromDate:self];
    
    NSDate * now = [NSDate date];

    NSDateComponents * nowComponents =
        [currentCalendar components:unitFlags fromDate:now];
    
    return [nowComponents day] == [selfComponents day] &&
        [nowComponents month] == [selfComponents month] &&
        [nowComponents year] == [selfComponents year];
}

@end
