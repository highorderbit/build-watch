//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "CcrbServerReportBuilder.h"
#import "ServerReport.h"
#import "ProjectReport.h"
#import "NSDate+StringHelpers.h"
#import "NSString+BuildWatchAdditions.h"
#import "NSError+BuildWatchAdditions.h"
#import "TouchXML.h"
#import "RegexKitLite.h"

@interface CcrbServerReportBuilder (Private)
+ (NSString *) projectNameFromProjectTitle:(NSString *)projectTitle;
+ (NSDate *) dateFromCruiseControlRbString:(NSString *)dateAsString;
+ (BOOL) buildSucceededFromProjectTitle:(NSString *)projectTitle;
+ (NSString *) buildLabelFromProjectTitle:(NSString *)projectTitle;
+ (NSString *) forceBuildUrlForProject:(NSString *)projectName
                               withUrl:(NSString *)projectUrl;
+ (CXMLDocument *) xmlDocumentWithString:(NSString *)xmlString
                                   error:(NSError **)error;
+ (NSError *)xmlParseError:(NSString *)localizedDescription
             withRootCause:(NSError *)rootCause;
@end

@implementation CcrbServerReportBuilder

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

    NSArray * channels = [[xmlDoc rootElement] elementsForName:@"channel"];
    if (channels.count != 1) {
        *error = [NSError errorWithLocalizedDescription:
            NSLocalizedString(@"xml.parse.failed", @"")
            rootCause:*error];
        NSLog(@"Failed to parse XML: '%@', returning error: '%@'.", xmlString,
            *error);

        return nil;
    }

    CXMLElement * channel = [channels objectAtIndex:0];

    report.name =
        [[[channel elementsForName:@"title"] objectAtIndex:0] stringValue];
    report.link = url;
    report.dashboardLink =
        [[[channel elementsForName:@"link"] objectAtIndex:0] stringValue];

    NSArray * projectNodes = [channel elementsForName:@"item"];
    NSMutableArray * projectReports =
        [NSMutableArray arrayWithCapacity:projectNodes.count];

    for (CXMLElement * projectNode in projectNodes) {
        ProjectReport * projectReport = [ProjectReport report];
        NSString * title =
            [[[projectNode elementsForName:@"title"] objectAtIndex:0]
             stringValue];

        projectReport.name = [[self class] projectNameFromProjectTitle:title];
        projectReport.description =
            [[[projectNode elementsForName:@"description"]
                              objectAtIndex:0] stringValue];
        projectReport.label = [[self class] buildLabelFromProjectTitle:title];
        projectReport.pubDate =
            [[self class] dateFromCruiseControlRbString:
             [[[projectNode elementsForName:@"pubDate"]
                              objectAtIndex:0] stringValue]];
        projectReport.link =
            [[[projectNode elementsForName:@"link"]
                              objectAtIndex:0] stringValue];
        projectReport.buildSucceeded =
            [[self class] buildSucceededFromProjectTitle:title];

        projectReport.forceBuildLink =
            [[self class] forceBuildUrlForProject:projectReport.name
                                          withUrl:projectReport.link];

        [projectReports addObject:projectReport];
    }

    report.projectReports = projectReports;

    return report;
}

#pragma mark Functions to help extract project attributes from XML data

+ (NSString *) projectNameFromProjectTitle:(NSString *)projectTitle
{
    static NSString * BUILD_STRING = @" build";

    NSRange where = [projectTitle rangeOfString:BUILD_STRING];
    if (NSEqualRanges(where, NSMakeRange(NSNotFound, 0)))
        return projectTitle;

    return [projectTitle substringWithRange:NSMakeRange(0, where.location)];
}

+ (NSDate *) dateFromCruiseControlRbString:(NSString *)dateAsString
{
    return [NSDate dateFromString:dateAsString
                           format:@"EEE, dd MMM yyyy HH:mm:ss 'Z'"];
}

+ (BOOL) buildSucceededFromProjectTitle:(NSString *)projectTitle
{
    static NSString * FAILED_STRING = @"failed";

    NSRange where = [projectTitle rangeOfString:FAILED_STRING];
    return NSEqualRanges(where, NSMakeRange(NSNotFound, 0));
}

+ (NSString *) buildLabelFromProjectTitle:(NSString *)projectTitle
{
    static NSString * REGEX = @"build\\s+(\\d+\\.*\\d*)\\s+(success|failed)";

    NSRange matchedRange = NSMakeRange(NSNotFound, 0);
    NSError * error = nil;

    matchedRange =
        [projectTitle rangeOfRegex:REGEX
                           options:RKLNoOptions
                           inRange:NSMakeRange(0, projectTitle.length)
                           capture:1
                             error:&error];

    if (error || NSEqualRanges(matchedRange, NSMakeRange(NSNotFound, 0)))
        return nil;
    else
        return [projectTitle substringWithRange:matchedRange];
}

+ (NSString *) forceBuildUrlForProject:(NSString *)projectName
                               withUrl:(NSString *)projectUrl
{
    NSString * forceBuildUrl = nil;
    NSURL * url = [NSURL URLWithString:projectUrl];

    if (url) {
        // If this proves to not be deterministic, switch to a regex where
        // the returned string is projectUrl with the results of
        // [url paramterString] removed.

        forceBuildUrl =
            [NSString stringWithFormat:@"%@://%@:%@/projects/build/%@",
             [url scheme], [url host], [url port], projectName];
    }

    NSLog(@"%@: build url: '%@'.", projectName, forceBuildUrl);
    return forceBuildUrl;
}

#pragma mark Helper functions

+ (CXMLDocument *) xmlDocumentWithString:(NSString *)xmlString
                                   error:(NSError **)error
{
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

    return xmlDoc;
}

@end
