//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "CcnetServerReportBuilder.h"
#import "RegexKitLite.h"

@implementation CcnetServerReportBuilder

+ (NSString *) serverNodeXpath
{
    return @"//Projects";
}

+ (NSString *) projectNodesXpath
{
    return @"./Project";
}

+ (NSString *) projectNameXpath
{
    return @"./@name";
}

+ (NSString *) projectBuildLabelXpath
{
    return @"./@lastBuildLabel";
}

+ (NSString *) projectPubDateXpath
{
    return @"./@lastBuildTime";
}

+ (NSString *) projectLinkXpath
{
    return @"./@webUrl";
}

+ (NSString *) projectBuildSucceededXpath
{
    return @"./@lastBuildStatus";
}

+ (NSString *) projectNameRegex
{
    return @"(^.*$)";
}

+ (NSString *) projectBuildLabelRegex
{
    return @"(^.*$)";
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
    return @"(Success)";
}

+ (NSString *) projectPubDateFormatString
{
    return @"yyyy-MM-dd'T'HH:mm:SS.SSSSZZZ";
}

+ (NSString *) serverNameFromNode:(CXMLNode *)serverNode
                        sourceUrl:(NSString *)sourceUrl
                            error:(NSError **)error
{
    return NSLocalizedString(@"ccnet.serverreport.name", @"");
}

+ (NSString *) serverDashboardLinkFromNode:(CXMLNode *)serverNode
                                 sourceUrl:(NSString *)sourceUrl
                                     error:(NSError **)error
{
    NSString * dashboardLink =
        [sourceUrl
         stringByReplacingOccurrencesOfRegex:@"(.*)/(?i:XmlServerReport.aspx)$"
                                  withString:@"$1/"];

    if (dashboardLink == nil || dashboardLink.length == 0)
        return [[self class] xmlParsingFailed:error];
    else
        return dashboardLink;
}

+ (NSString *) projectDescriptionFromNode:(CXMLNode *)node
                                    error:(NSError **)error
{
    return NSLocalizedString(@"ccserver.description.notprovided.message", @"");
}

+ (NSString *) projectForceBuildLinkFromNode:(CXMLNode *)node
                                       error:(NSError **)error
{
    static NSString * regex =
        @"^(.*)/server/(.*)/project/.*/ViewLatestBuildReport.aspx$";
    static NSString * replacementString =
        @"$1/ViewFarmReport.aspx?serverName=$2";

    NSString * projectName =
        [[self class] projectNameFromNode:node error:error];
    if (*error) return nil;
    if (!projectName) return [[self class] xmlParsingFailed:error];

    NSString * link = [[self class] projectLinkFromNode:node error:error];
    if (*error) return nil;
    if (!link) return [[self class] xmlParsingFailed:error];

    NSString * s =
        [link stringByReplacingOccurrencesOfRegex:regex
                                       withString:replacementString];

    return [[s stringByAppendingFormat:@"&projectName=%@&ForceBuild=Force",
             projectName]
            stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
