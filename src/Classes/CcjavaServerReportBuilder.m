//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "CcjavaServerReportBuilder.h"
#import "ServerReport.h"
#import "ProjectReport.h"
#import "NSString+BuildWatchAdditions.h"
#import "NSDate+BuildServiceAdditions.h"
#import "NSError+BuildWatchAdditions.h"
#import "TouchXML.h"
#import "RegexKitLite.h"

@interface CcjavaServerReportBuilder (Private)
+ (NSString *) buildLabelFromString:(NSString *)string;
+ (NSDate *) dateFromCruiseControlJavaString:(NSString *)string;
+ (BOOL) buildSucceededFromString:(NSString *)string;
+ (NSString *) forceBuildUrlForProject:(NSString *)projectName
                               withUrl:(NSString *)link;
@end

@implementation CcjavaServerReportBuilder

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

    NSArray * channels =
        [[xmlDoc rootElement] nodesForXPath:@"//Projects" error:error];
    if (*error || channels.count != 1) {
        *error = [NSError errorWithLocalizedDescription:
            NSLocalizedString(@"xml.parse.failed", @"")
            rootCause:*error];
        NSLog(@"Failed to parse XML: '%@', returning error: '%@'.", xmlString,
            *error);

        return nil;
    }

    CXMLElement * channel = [channels objectAtIndex:0];

    report.name = NSLocalizedString(@"ccjava.serverreport.name", @"");
    report.link = url;
    report.dashboardLink =
        [url stringByReplacingOccurrencesOfRegex:@"(.*)/cctray.xml$"
                                      withString:@"$1"];

    NSArray * projectNodes = [channel elementsForName:@"Project"];
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

        projectReport.pubDate = [[self class] dateFromCruiseControlJavaString:
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
    NSString * label = [string stringByMatchingRegex:@"^build\\.(\\d+.*)$"];

    // sometimes labels are empty strings
    return label ? label : @"";
}

+ (NSDate *) dateFromCruiseControlJavaString:(NSString *)string
{
    return [NSDate dateWithString:string format:@"yyyy-MM-dd'T'HH:mm:ss"];
}

+ (BOOL) buildSucceededFromString:(NSString *)string
{
    return [string isEqualToString:@"Success"];
}

+ (NSString *) forceBuildUrlForProject:(NSString *)projectName
                               withUrl:(NSString *)link
{
    static NSString * URL_FORMAT_STRING =
        @"%@://%@:8000/invoke?operation=build&objectname=";

    NSLog(@"Extracting force build URL from: '%@' and '%@'.",
            projectName, link);

    NSURL * url = [NSURL URLWithString:link];
    NSMutableString * result = [NSMutableString
        stringWithFormat:URL_FORMAT_STRING, [url scheme], [url host]];

    // append strings incrementally since URL encodings mess up the formats
    [result appendString:@"CruiseControl+Project%3Aname%3D"];
    [result appendString:projectName];

    NSLog(@"Generated: '%@'.", result);
    return result;
}

@end
