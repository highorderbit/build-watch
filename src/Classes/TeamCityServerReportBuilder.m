//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "TeamCityServerReportBuilder.h"
#import "RegexKitLite.h"

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

+ (NSString *) projectForceBuildLinkFromNode:(CXMLNode *)node
                                       error:(NSError **)error
{
    //
    // Force build URLs are of the form:
    //   http://localhost:8111/ajax.html?add2Queue=bt3
    // where 'bt3' is the buildTypeId provided in the build URL.
    //

    NSString * link =
        [[self class] projectLinkFromNode:node error:error];
    if (*error) return nil;
    if (!link || link.length == 0) return [[self class] xmlParsingFailed:error];

    static NSString * regex = @"^(.*://.*?)/(.*)*buildTypeId=(.*)";
    static NSString * replacementString = @"$1/ajax.html?add2Queue=$3";

    NSString * forceBuildLink =
        [link stringByReplacingOccurrencesOfRegex:regex
                                       withString:replacementString];

    return forceBuildLink ?
        [forceBuildLink
         stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] :
        [[self class] xmlParsingFailed:error];
}

@end
