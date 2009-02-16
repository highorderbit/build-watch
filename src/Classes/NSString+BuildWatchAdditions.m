//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "NSString+BuildWatchAdditions.h"
#import "RegexKitLite.h"

@implementation NSString (BuildWatchAdditions)

+ (NSString *) stringWithData:(NSData *)data
                     encoding:(NSStringEncoding)encoding
{
    return [[[NSString alloc] initWithData:data encoding:encoding] autorelease];
}

- (BOOL) endsWithString:(NSString *)s
{
    static const NSRange NOT_FOUND = { NSNotFound, 0 };

    NSRange range = [self rangeOfString:s];
    return !NSEqualRanges(range, NOT_FOUND) &&
           range.location + range.length == self.length;
}

- (NSString *) stringByMatchingRegex:(NSString *)regex
{
    return [self stringByMatchingRegex:regex capture:1];
}

- (NSString *) stringByMatchingRegex:(NSString *)regex
                             capture:(NSInteger)capture
{
    static const NSRange NOT_FOUND = { NSNotFound, 0 };

    NSError * error = nil;
    NSRange matchedRange = [self rangeOfRegex:regex
                                      options:RKLNoOptions
                                      inRange:NSMakeRange(0, self.length)
                                      capture:capture
                                        error:&error];

    if (error || NSEqualRanges(matchedRange, NOT_FOUND))
        return nil;
    else
        return [self substringWithRange:matchedRange];
}

@end
