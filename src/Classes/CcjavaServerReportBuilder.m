//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "CcjavaServerReportBuilder.h"
#import "NSString+BuildWatchAdditions.h"
#import "RegexKitLite.h"

@implementation CcjavaServerReportBuilder

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
    return @"^build\\.(\\d+.*)$";
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
    return NSLocalizedString(@"ccjava.serverreport.name", @"");
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
        return dashboardLink;
}

+ (NSString *) projectDescriptionFromNode:(CXMLNode *)node
                                    error:(NSError **)error
{
    return NSLocalizedString(@"ccserver.description.notprovided.message", @"");
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

+ (NSString *) projectForceBuildLinkFromNode:(CXMLNode *)node
                                       error:(NSError **)error
{
    static NSString * regex =
        @"^(.*://.*?)(:\\d+)?/dashboard(/.*)*/(.*?)$";
    static NSString * replacementString =
        @"$1:8000/invoke?operation=build&"
         "objectname=CruiseControl+Project%3Aname%3D$4";

    NSString * projectName =
        [[self class] projectNameFromNode:node error:error];
    if (*error) return nil;
    if (!projectName) return [[self class] xmlParsingFailed:error];

    NSString * link = [[self class] projectLinkFromNode:node error:error];
    if (*error) return nil;
    if (!link) return [[self class] xmlParsingFailed:error];

    NSString * forceBuildLink =
        [link stringByReplacingOccurrencesOfRegex:regex
                                       withString:replacementString];

    if (!forceBuildLink || forceBuildLink.length == 0)
        return [[self class] xmlParsingFailed:error];

    return forceBuildLink;
}

@end
