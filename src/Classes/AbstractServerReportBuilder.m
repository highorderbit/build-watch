//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "AbstractServerReportBuilder.h"
#import "ServerReport.h"
#import "ProjectReport.h"
#import "NSDate+StringHelpers.h"
#import "NSString+BuildWatchAdditions.h"
#import "NSError+BuildWatchAdditions.h"
#import "TouchXML.h"
#import "RegexKitLite.h"
@interface AbstractServerReportBuilder (Private)
+ (NSString *) serverNodeXpath;
+ (NSString *) projectNodesXpath;

+ (NSString *) serverNameXpath;
+ (NSString *) serverDashboardLinkXpath;
+ (NSString *) projectNameXpath;
+ (NSString *) projectDescriptionXpath;
+ (NSString *) projectBuildLabelXpath;
+ (NSString *) projectPubDateXpath;
+ (NSString *) projectLinkXpath;
+ (NSString *) projectBuildSucceededXpath;
+ (NSString *) projectForceBuildLinkXpath;

+ (NSString *) serverNameRegex;
+ (NSString *) serverDashboardLinkRegex;
+ (NSString *) projectNameRegex;
+ (NSString *) projectBuildLabelRegex;
+ (NSString *) projectPubDateRegex;
+ (NSString *) projectLinkRegex;
+ (NSString *) projectBuildSucceededRegex;
+ (NSString *) projectForceBuildLinkRegex;

+ (NSString *) projectPubDateFormatString;

+ (NSString *) hackXmlStringIfNecessary:(NSString *)xmlString;
@end


@implementation AbstractServerReportBuilder

- (ServerReport *) serverReportFromUrl:(NSString *)url
                                  data:(NSData *)data
                                 error:(NSError **)error
{
    NSString * xmlString =
        [[[NSString alloc]
          initWithData:data encoding:NSUTF8StringEncoding]
          autorelease];

    xmlString = [[self class] hackXmlStringIfNecessary:xmlString];

    ServerReport * report = [ServerReport report];

    CXMLDocument * xmlDoc = [[[CXMLDocument alloc]
         initWithXMLString:xmlString options:0 error:error] autorelease];

    if (*error)
        return [[self class] xmlParsingFailedWithRootCause:error];

    NSString * serverXpath = [[self class] serverNodeXpath];
    NSArray * serverNodes = [xmlDoc nodesForXPath:serverXpath error:error];
    if (*error || serverNodes.count != 1)
        return [[self class] xmlParsingFailedWithRootCause:error];

    CXMLElement * serverNode = [serverNodes objectAtIndex:0];

    report.name = [[self class] serverNameFromNode:serverNode
                                         sourceUrl:url
                                             error:error];
    if (*error)
        return [[self class] xmlParsingFailedWithRootCause:error];

    report.key = url;
    report.dashboardLink =
        [[self class] serverDashboardLinkFromNode:serverNode
                                        sourceUrl:url
                                            error:error];
    if (*error)
        return [[self class] xmlParsingFailedWithRootCause:error];

    report.key = url;

    NSString * projectsXpath = [[self class] projectNodesXpath];
    NSArray * projectNodes =
        [serverNode nodesForXPath:projectsXpath error:error];
    if (*error)
        return [[self class] xmlParsingFailedWithRootCause:error];

    NSMutableDictionary * projectReports =
        [NSMutableDictionary dictionaryWithCapacity:projectNodes.count];

    for (CXMLNode * projectNode in projectNodes) {
        ProjectReport * projectReport =
            [[self class] projectReportFromNode:projectNode error:error];
        if (*error)
            return [[self class] xmlParsingFailedWithRootCause:error];

        if (![projectReports objectForKey:projectReport.name])
            [projectReports setObject:projectReport forKey:projectReport.name];
    }

    report.projectReports = [projectReports allValues];

    NSLog(@"From server URL: '%@' built server report: %@", url,
        [report longDescription]);

    return report;
}

#pragma mark Helper methods

+ (NSString *) serverNameFromNode:(CXMLNode *)serverNode
                        sourceUrl:(NSString *)sourceUrl
                            error:(NSError **)error
{
    NSString * xpath = [[self class] serverNameXpath];
    NSString * value =
        [[self class] stringValueAtXpath:xpath fromNode:serverNode error:error];
    if (*error) return nil;

    NSString * regex = [[self class] serverNameRegex];
    NSString * serverName = [value stringByMatchingRegex:regex];

    return serverName == nil ?
        [[self class] xmlParsingFailed:error] : serverName;
}

+ (NSString *) serverDashboardLinkFromNode:(CXMLNode *)serverNode
                                 sourceUrl:(NSString *)sourceUrl
                                     error:(NSError **)error
{
    NSString * xpath = [[self class] serverDashboardLinkXpath];
    NSString * value =
        [[self class] stringValueAtXpath:xpath fromNode:serverNode error:error];
    if (*error) return nil;

    NSString * regex = [[self class] serverDashboardLinkRegex];
    NSString * link = [value stringByMatchingRegex:regex];

    return link == nil ? [[self class] xmlParsingFailed:error] : link;
}

+ (ProjectReport *) projectReportFromNode:(CXMLNode *)projectNode
                                    error:(NSError **)error
{
    ProjectReport * projectReport = [ProjectReport report];

    projectReport.name =
        [[self class] projectNameFromNode:projectNode error:error];
    if (*error) return nil;

    projectReport.buildDescription =
        [[self class] projectDescriptionFromNode:projectNode error:error];
    if (*error) return nil;

    projectReport.buildLabel =
        [[self class] projectBuildLabelFromNode:projectNode error:error];
    if (*error) return nil;

    projectReport.buildPubDate =
        [[self class] projectPubDateFromNode:projectNode error:error];
    if (*error) return nil;

    projectReport.buildDashboardLink =
        [[self class] projectLinkFromNode:projectNode error:error];
    if (*error) return nil;

    projectReport.buildSucceededState =
        [[self class] projectBuildSucceededFromNode:projectNode error:error];
    if (*error) return nil;

    projectReport.forceBuildLink =
        [[self class] projectForceBuildLinkFromNode:projectNode error:error];
    if (*error) return nil;

    return projectReport;
}

+ (NSString *) projectNameFromNode:(CXMLNode *)node error:(NSError **)error
{
    NSString * xpath = [[self class] projectNameXpath];
    NSString * value =
        [[self class] stringValueAtXpath:xpath fromNode:node error:error];
    if (*error) return nil;

    NSString * regex = [[self class] projectNameRegex];
    NSString * projectName = [value stringByMatchingRegex:regex];

    return projectName == nil ?
        [[self class] xmlParsingFailed:error] : projectName;
}

+ (NSString *) projectDescriptionFromNode:(CXMLNode *)node
                                    error:(NSError **)error
{
    NSString * xpath = [[self class] projectDescriptionXpath];
    NSString * value =
        [[self class] stringValueAtXpath:xpath fromNode:node error:error];
    if (*error) return nil;

    return value;
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

    return label == nil ? [[self class] xmlParsingFailed:error] : label;
}

+ (NSDate *) projectPubDateFromNode:(CXMLNode *)node error:(NSError **)error
{
    NSString * xpath = [[self class] projectPubDateXpath];
    NSString * value =
        [[self class] stringValueAtXpath:xpath fromNode:node error:error];
    if (*error) return nil;

    NSString * regex = [[self class] projectPubDateRegex];
    NSString * dateString = [value stringByMatchingRegex:regex];

    if (dateString == nil)
        return [[self class] xmlParsingFailed:error];

    NSString * format = [[self class] projectPubDateFormatString];
    NSDate * date = [NSDate dateFromString:dateString format:format];

    return date == nil ? [[self class] xmlParsingFailed:error] : date;
}

+ (NSString *) projectLinkFromNode:(CXMLNode *)node
                             error:(NSError **)error
{
    NSString * xpath = [[self class] projectLinkXpath];
    NSString * value =
        [[self class] stringValueAtXpath:xpath fromNode:node error:error];
    if (*error) return nil;

    NSString * regex = [[self class] projectLinkRegex];
    NSString * link = [value stringByMatchingRegex:regex];

    return link == nil ?
        [[self class] xmlParsingFailed:error] :
        [link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (BOOL) projectBuildSucceededFromNode:(CXMLNode *)node
                                 error:(NSError **)error
{
    NSString * xpath = [[self class] projectBuildSucceededXpath];
    NSString * value =
        [[self class] stringValueAtXpath:xpath fromNode:node error:error];
    if (*error) return NO;

    NSString * regex = [[self class] projectBuildSucceededRegex];
    NSString * match = [value stringByMatchingRegex:regex];

    return match && match.length > 0;
}

+ (NSString *) projectForceBuildLinkFromNode:(CXMLNode *)node
                                       error:(NSError **)error
{
    NSString * xpath = [[self class] projectForceBuildLinkXpath];
    NSString * value =
        [[self class] stringValueAtXpath:xpath fromNode:node error:error];
    if (*error) return nil;

    NSString * regex = [[self class] projectForceBuildLinkRegex];
    NSString * forceBuildLink = [value stringByMatchingRegex:regex];

    return forceBuildLink == nil ?
        [[self class] xmlParsingFailed:error] :
        [forceBuildLink
         stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *) stringValueAtXpath:(NSString *)xpath
                         fromNode:(CXMLNode *)node
                            error:(NSError **)error
{
    NSArray * nodes = [node nodesForXPath:xpath error:error];
    if (*error)
        return [[self class] xmlParsingFailedWithRootCause:error];

    if (nodes.count == 1)
        return [[nodes objectAtIndex:0] stringValue];
    else
        return [[self class] xmlParsingFailed:error];
}

#pragma mark Error handling helper functions

+ (id) xmlParsingFailed:(NSError **)error
{
    *error = [NSError errorWithLocalizedDescription:
        NSLocalizedString(@"xml.parse.failed", @"")
                                          rootCause:*error];
    NSLog(@"Failed to parse XML, returning error: '%@'.", *error);

    return nil;
}

+ (id) xmlParsingFailedWithRootCause:(NSError **)error
{
    NSString * errorMsg = NSLocalizedString(@"xml.parse.failed", @"");
    *error = [NSError errorWithLocalizedDescription:errorMsg
                                          rootCause:*error];
    NSLog(@"Failed to parse XML, returning error: '%@'.", *error);

    return nil;
}

+ (NSString *) hackXmlStringIfNecessary:(NSString *)xmlString
{
    //
    // Need to hack strings from certain CI servers (e.g. TeamCity) to
    // remove xmlns attributes from the root node. If it contains these,
    // all xpath operations fail.
    //

    static NSString * xmlnsHackRegex = @"<feed(\\s+(xmlns=.*))>";
    static NSString * xmlnsHackReplacementString = @"<feed>";

    NSString * xml =
        [xmlString
         stringByReplacingOccurrencesOfRegex:xmlnsHackRegex
                                  withString:xmlnsHackReplacementString];

    //
    // Now we need to remove \r\n that TeamCity seems to insert into the
    // server dashboard link attribute. Without this hack, the attribute is
    // not reachable via XPath.
    //

    static NSString * serverLinkHackRegex = @"href=\"&#xD;&#xA;(.*)\"";
    static NSString * serverLinkHackReplacementString = @"href=\"$1\"";

    xml =
        [xml
         stringByReplacingOccurrencesOfRegex:serverLinkHackRegex
                                  withString:serverLinkHackReplacementString];

    return xml;
}

@end
