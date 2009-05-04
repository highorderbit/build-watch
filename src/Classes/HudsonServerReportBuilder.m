//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "HudsonServerReportBuilder.h"
#import "NSString+BuildWatchAdditions.h"
#import "RegexKitLite.h"

@implementation HudsonServerReportBuilder

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
    return @"yyyy-MM-dd'T'HH:mm:ss";
}

+ (NSString *) serverNameFromNode:(CXMLNode *)serverNode
                        sourceUrl:(NSString *)sourceUrl
                            error:(NSError **)error
{
    return NSLocalizedString(@"hudson.serverreport.name", @"");
}

+ (NSString *) serverDashboardLinkFromNode:(CXMLNode *)serverNode
                                 sourceUrl:(NSString *)sourceUrl
                                     error:(NSError **)error
{
    NSString * dashboardLink =
        [sourceUrl
         stringByReplacingOccurrencesOfRegex:@"(.*)/(?i:cctray.xml)$"
                                  withString:@"$1/"];

    if (dashboardLink == nil || dashboardLink.length == 0)
        return [[self class] xmlParsingFailed:error];
    else
        return [dashboardLink
            stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *) projectDescriptionFromNode:(CXMLNode *)node
                                    error:(NSError **)error
{
    return NSLocalizedString(@"hudson.description.notprovided.message", @"");
}

+ (NSString *) projectBuildLabelFromNode:(CXMLNode *)node
                                   error:(NSError **)error
{
    NSString * xpath = [[self class] projectBuildLabelXpath];
    NSString * value =
        [[self class] stringValueAtXpath:xpath fromNode:node error:error];
    if (*error) return nil;

    NSString * regex = [[self class] projectBuildLabelRegex];
    NSString * label = [value stringByMatchingRegex:regex];

    // some build labels for CC Java servers are left empty; this is okay
    return
        label == nil ?
            NSLocalizedString(@"ccjava.buildlabel.empty", @"") :
            label;
}

+ (NSDate *) projectPubDateFromNode:(CXMLNode *)node error:(NSError **)error
{
    NSDate * utcDate = [super projectPubDateFromNode:node error:error];
    if (*error)
        return nil;

    // Hudson uses UTC timestamps, so make sure our NSDate, which
    // has a time for the local time zone, is adjusted appropriately.
    NSTimeZone * local = [NSTimeZone localTimeZone];
    return [utcDate addTimeInterval:[local secondsFromGMT]];
}


+ (NSString *) projectForceBuildLinkFromNode:(CXMLNode *)node
                                       error:(NSError **)error
{
    //
    // Example URL:
    //   http://localhost:8080/job/Hudson%20Test%20Project/build?delay=0sec
    //

    NSString * link = [[self class] projectLinkFromNode:node error:error];
    if (*error) return nil;
    if (!link) return [[self class] xmlParsingFailed:error];

    return [link stringByAppendingString:@"build?delay=0sec"];
}

@end
