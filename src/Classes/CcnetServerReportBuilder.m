//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "CcnetServerReportBuilder.h"
#import "ServerReport.h"
#import "ProjectReport.h"
#import "NSString+BuildWatchAdditions.h"
#import "NSDate+StringHelpers.h"
#import "NSError+BuildWatchAdditions.h"
#import "TouchXML.h"
#import "RegexKitLite.h"

@interface CcnetServerReportBuilder (Private)
+ (NSString *) buildLabelFromString:(NSString *)string;
+ (NSDate *) dateFromCruiseControlNetString:(NSString *)string;
+ (BOOL) buildSucceededFromString:(NSString *)string;
+ (NSString *) forceBuildUrlForProject:(NSString *)projectName
                               withUrl:(NSString *)link;
@end

@implementation CcnetServerReportBuilder

- (ServerReport *) serverReportFromUrl:(NSString *)url
                                  data:(NSData *)data
                                 error:(NSError **)error
{
    NSString * xmlString =
        [[[NSString alloc]
          initWithData:data encoding:NSUTF8StringEncoding]
          autorelease];

    ServerReport * report = [ServerReport report];

    CXMLDocument * xmlDoc = [[[CXMLDocument alloc]
         initWithXMLString:xmlString options:0 error:error] autorelease];

    if (*error) {
        *error = [NSError errorWithLocalizedDescription:
            NSLocalizedString(@"xml.parse.failed", @"")
            rootCause:*error];
        NSLog(@"Failed to parse XML: '%@', returning error: '%@'.", xmlString,
            *error);

        return nil;
    }

    NSArray * channels = [[xmlDoc rootElement] elementsForName:@"Projects"];
    if (channels.count != 1) {
        *error = [NSError errorWithLocalizedDescription:
            NSLocalizedString(@"xml.parse.failed", @"")
            rootCause:*error];
        NSLog(@"Failed to parse XML: '%@', returning error: '%@'.", xmlString,
            *error);

        return nil;
    }

    CXMLElement * channel = [channels objectAtIndex:0];

    report.name = NSLocalizedString(@"ccnet.serverreport.name", @"");
    report.link = url;
    report.dashboardLink =
        [url stringByReplacingOccurrencesOfRegex:@"(.*)/XmlServerReport.aspx$"
                                      withString:@"$1"];

    NSArray * projectNodes = [channel nodesForXPath:@"//Project" error:error];
    if (*error) {
        *error = [NSError errorWithLocalizedDescription:
                  NSLocalizedString(@"xml.parse.failed", @"")
                                              rootCause:*error];
        NSLog(@"Failed to parse XML: '%@', returning error: '%@'.", xmlString,
              *error);

        return nil;
    }

    NSMutableArray * projectReports =
        [NSMutableArray arrayWithCapacity:projectNodes.count];

    for (CXMLElement * projectNode in projectNodes) {
        ProjectReport * projectReport = [ProjectReport report];

        projectReport.name =
            [[[projectNode nodesForXPath:@"./@name" error:error] objectAtIndex:0]
              stringValue];

        projectReport.description =
            NSLocalizedString(@"ccserver.description.notprovided.message",
                @"");

        projectReport.label = [[self class] buildLabelFromString:
            [[[projectNode nodesForXPath:@"./@lastBuildLabel" error:error]
              objectAtIndex:0]
             stringValue]];

        projectReport.pubDate = [[self class] dateFromCruiseControlNetString:
            [[[projectNode nodesForXPath:@"./@lastBuildTime" error:error]
              objectAtIndex:0]
             stringValue]];

        projectReport.link =
            [[[projectNode nodesForXPath:@"./@webUrl" error:error]
              objectAtIndex:0]
             stringValue];

        projectReport.buildSucceeded = [[self class] buildSucceededFromString:
            [[[projectNode nodesForXPath:@"./@lastBuildStatus" error:error]
              objectAtIndex:0] stringValue]];

        projectReport.forceBuildLink =
            [[self class] forceBuildUrlForProject:projectReport.name
                                          withUrl:projectReport.link];

        [projectReports addObject:projectReport];
    }

    report.projectReports = projectReports;

    return report;
}

#pragma mark Parsing helper functions

+ (NSString *) buildLabelFromString:(NSString *)string
{
    return string;
}

+ (NSDate *) dateFromCruiseControlNetString:(NSString *)string
{
    static NSString * STRICT_FORMAT = @"yyyy-MM-dd'T'HH:mm:SS.SSSSZZZ";
    static NSString * SAFE_FORMAT = @"yyyy-MM-dd'T'HH:mm:ss";

    //
    // Jump through an extra hoop here just to be safe. The strict format
    // has been tested and works with the public cc.net server at:
    //  http://ccnetlive.thoughtworks.com/ccnet/ViewFarmReport.aspx
    // but I want to be defensive in case there are deviations out there.
    // The safe format should always work. Returning nil will cause the
    // application to crash.
    //

    NSDate * date = [NSDate dateFromString:string format:STRICT_FORMAT];
    if (date == nil)
        date = [NSDate dateFromString:string format:SAFE_FORMAT];

    return date;
}

+ (BOOL) buildSucceededFromString:(NSString *)string
{
    return [string isEqualToString:@"Success"];
}

+ (NSString *) forceBuildUrlForProject:(NSString *)projectName
                               withUrl:(NSString *)link
{
    static NSString * regex =
        @"^(.*)/server/(.*)/project/.*/ViewLatestBuildReport.aspx$";
    static NSString * replacementString =
        @"$1/ViewFarmReport.aspx?serverName=$2";

    NSLog(@"Building string from: '%@' and '%@'.", projectName, link);
    NSString * s =
        [link stringByReplacingOccurrencesOfRegex:regex
                                       withString:replacementString];

    return [[s stringByAppendingFormat:@"&projectName=%@&ForceBuild=Force",
             projectName]
            stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
