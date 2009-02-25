//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "TeamCityServerReportBuilder.h"

@implementation TeamCityServerReportBuilder

+ (NSString *) serverNodeXpath
{
    return @"//feed";
}

+ (NSString *) projectNodesXpath
{
    return @"./entry";
}

+ (NSString *) serverNameXpath
{
    return @"./title";
}

+ (NSString *) serverDashboardLinkXpath
{
    return @"./link/@href";
}

+ (NSString *) projectNameXpath
{
    return @"./title";
}

+ (NSString *) projectDescriptionXpath
{
    return @"./summary";
}

+ (NSString *) projectBuildLabelXpath
{
    return @"./title";
}

+ (NSString *) projectPubDateXpath
{
    return @"./published";
}

+ (NSString *) projectLinkXpath
{
    return @"./link/@href";
}

+ (NSString *) projectBuildSucceededXpath
{
    return @"./title";
}

+ (NSString *) projectForceBuildLinkXpath
{
    return @"./link/@href";
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
    return @"^Build\\s+(.*)\\s+#\\d+";
}

+ (NSString *) projectBuildLabelRegex
{
    return @"\\s+(#.*)\\s+(was|has)";
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
    return @"(successful)$";
}

+ (NSString *) projectForceBuildLinkRegex
{
    return @"(^.*$)";
}

+ (NSString *) projectPubDateFormatString
{
    return @"yyyy-MM-dd'T'HH:mm:ss'Z'";
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

@end
