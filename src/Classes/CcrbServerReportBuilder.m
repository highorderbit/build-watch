//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "CcrbServerReportBuilder.h"
#import "RegexKitLite.h"

@implementation CcrbServerReportBuilder

+ (NSString *) serverNodeXpath
{
    return @"//channel";
}

+ (NSString *) projectNodesXpath
{
    return @"./item";
}

+ (NSString *) serverNameXpath
{
    return @"./title";
}

+ (NSString *) serverDashboardLinkXpath
{
    return @"./link";
}

+ (NSString *) projectNameXpath
{
    return @"./title";
}

+ (NSString *) projectDescriptionXpath
{
    return @"./description";
}

+ (NSString *) projectBuildLabelXpath
{
    return @"./title";
}

+ (NSString *) projectPubDateXpath
{
    return @"./pubDate";
}

+ (NSString *) projectLinkXpath
{
    return @"./link";
}

+ (NSString *) projectBuildSucceededXpath
{
    return @"./title";
}

+ (NSString *) projectForceBuildLinkXpath
{
    return @"./link";
}

+ (NSString *) serverNameRegex
{
    return @"(^.*$)";
}

+ (NSString *) serverDashboardLinkRegex
{
    return @"(^.*$)";
}

+ (NSString *) projectNameRegex
{
    return @"(^.*)\\s+build\\s+.*\\s+(success|failed)$";
}

+ (NSString *) projectBuildLabelRegex
{
    return @"build\\s+(.*?)\\s|(success|failed)$";
}

+ (NSString *) projectPubDateRegex
{
    return @"(^.*$)";
}

+ (NSString *) projectLinkRegex
{
    return @"(^.*$)";
}

+ (NSString *) projectBuildSucceededRegex
{
    return @"(success)$";
}

+ (NSString *) projectPubDateFormatString
{
    return @"EEE, dd MMM yyyy HH:mm:ss 'Z'";
}

+ (NSDate *) projectPubDateFromNode:(CXMLNode *)node error:(NSError **)error
{
    NSDate * utcDate = [super projectPubDateFromNode:node error:error];
    if (*error)
        return nil;

    // CruiseControl.rb uses UTC timestamps, so make sure our NSDate, which
    // has a time for the local time zone, is adjusted appropriately.
    NSTimeZone * local = [NSTimeZone localTimeZone];
    return [utcDate addTimeInterval:[local secondsFromGMT]];
}

+ (NSString *) projectForceBuildLinkFromNode:(CXMLNode *)node
                                       error:(NSError **)error
{
    static NSString * regex = @"^(.*)/builds/(.*)/\\d+.*$";
    static NSString * replacementString = @"$1/projects/build/$2";

    NSString * title =
        [[self class] stringValueAtXpath:@"./link"
                                fromNode:node
                                   error:error];
    if (*error) return [[self class] xmlParsingFailedWithRootCause:error];
    if (!title) return [[self class] xmlParsingFailed:error];

    NSString * forceBuildUrl =
        [title stringByReplacingOccurrencesOfRegex:regex
                                        withString:replacementString];

    if (forceBuildUrl == nil || forceBuildUrl.length == 0)
        return [[self class] xmlParsingFailed:error];

    return [forceBuildUrl
        stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
