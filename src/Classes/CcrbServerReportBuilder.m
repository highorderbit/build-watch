//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "CcrbServerReportBuilder.h"
#import "ServerReport.h"
#import "ProjectReport.h"
#import "NSDate+BuildServiceAdditions.h"
#import "TouchXML.h"
#import "RegexKitLite.h"

@interface CcrbServerReportBuilder (Private)
+ (NSString *) projectNameFromProjectTitle:(NSString *)projectTitle;
+ (BOOL) buildSucceededFromProjectTitle:(NSString *)projectTitle;
+ (NSString *) buildLabelFromProjectTitle:(NSString *)projectTitle;
+ (NSString *) forceBuildUrlForProject:(NSString *)projectName
                               withUrl:(NSString *)projectUrl;
+ (NSError *)xmlParseError:(NSString *)localizedDescription
             withRootCause:(NSError *)rootCause;
@end

@implementation CcrbServerReportBuilder

- (ServerReport *) serverReportFromData:(NSData *)data
                                  error:(NSError **)error
{
    NSString * xmlString =
        [[[NSString alloc]
          initWithData:data encoding:NSUTF8StringEncoding]
          autorelease];

    ServerReport * report = [ServerReport report];

    CXMLDocument * xmlDoc =
        [[CXMLDocument alloc]
         initWithXMLString:xmlString options:0 error:error];

    if (*error) {
        *error = [[self class]
            xmlParseError:NSLocalizedString(@"xml.parse.failed", @"")
            withRootCause:*error];
        NSLog(@"Failed to parse XML: '%@', returning error: '%@'.", xmlString,
            *error);

        return nil;
    }

    NSArray * channels = [[xmlDoc rootElement] elementsForName:@"channel"];
    if (channels.count != 1) {
        *error = [[self class]
            xmlParseError:NSLocalizedString(@"xml.parse.failed", @"")
            withRootCause:*error];
        NSLog(@"Failed to parse XML: '%@', returning error: '%@'.", xmlString,
            *error);

        return nil;
    }
        
    CXMLElement * channel = [channels objectAtIndex:0];

    report.name =
        [[[channel elementsForName:@"title"] objectAtIndex:0] stringValue];
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
            [NSDate dateFromCruiseControlRbString:
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

+ (NSError *) xmlParseError:(NSString *)localizedDescription
              withRootCause:(NSError *)rootCause
{
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
        localizedDescription, NSLocalizedDescriptionKey,
        rootCause.localizedDescription, NSLocalizedFailureReasonErrorKey,
        nil];

    return [NSError
        errorWithDomain:@"BuildWatchErrorDomain" code:1 userInfo:userInfo];
}

@end
