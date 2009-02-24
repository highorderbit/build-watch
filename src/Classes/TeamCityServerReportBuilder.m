//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "TeamCityServerReportBuilder.h"
#import "ServerReport.h"
#import "ProjectReport.h"
#import "NSDate+StringHelpers.h"
#import "NSString+BuildWatchAdditions.h"
#import "NSError+BuildWatchAdditions.h"
#import "TouchXML.h"
#import "RegexKitLite.h"

@interface TeamCityServerReportBuilder (Private)
+ (NSString *) projectNameFromProjectTitle:(NSString *)title;
+ (NSString *) buildLabelFromProjectTitle:(NSString *)title;
+ (NSDate *) dateFromTeamCityString:(NSString *)dateAsString;
+ (BOOL) buildSucceededFromProjectTitle:(NSString *)title;
@end

@implementation TeamCityServerReportBuilder

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

    /*
    NSArray * feeds = [xmlDoc rootElement] elementsForName:@"feed"];
    if (feeds.count != 1) {
        *error = [NSError errorWithLocalizedDescription:
            NSLocalizedString(@"xml.parse.failed", @"")
                                              rootCause:*error];
        NSLog(@"Failed to parse XML: '%@', returning error: '%@'.", xmlString,
            *error);

        return nil;
    }
     */

    CXMLElement * feed = [xmlDoc rootElement];

    report.name =
        [[[feed elementsForName:@"title"] objectAtIndex:0] stringValue];
    report.link = url;
    report.dashboardLink =
        [[[[feed elementsForName:@"link"] objectAtIndex:0]
           attributeForName:@"href"] stringValue];

    NSArray * projectNodes = [feed elementsForName:@"entry"];
    NSMutableArray * projectReports =
        [NSMutableArray arrayWithCapacity:projectNodes.count];

    for (CXMLElement * projectNode in projectNodes) {
        ProjectReport * projectReport = [ProjectReport report];
        NSString * title =
            [[[projectNode elementsForName:@"title"] objectAtIndex:0]
             stringValue];

        projectReport.name = [[self class] projectNameFromProjectTitle:title];
        projectReport.description =
            [[[projectNode elementsForName:@"summary"]
              objectAtIndex:0] stringValue];
        projectReport.label = [[self class] buildLabelFromProjectTitle:title];
        projectReport.pubDate =
            [[self class] dateFromTeamCityString:
             [[[projectNode elementsForName:@"published"] objectAtIndex:0]
              stringValue]];
        projectReport.link =
            [[[[projectNode elementsForName:@"link"] objectAtIndex:0]
              attributeForName:@"href"] stringValue];

        // TODO
        projectReport.forceBuildLink = @"http://www.google.com";

        projectReport.buildSucceeded =
            [[self class] buildSucceededFromProjectTitle:title];

        [projectReports addObject:projectReport];
    }

    report.projectReports = projectReports;

    return report;
}

+ (NSString *) projectNameFromProjectTitle:(NSString *)title
{
    static NSString * REGEX = @"^Build\\s+(.*)\\s+#\\d+";

    NSRange matchedRange = NSMakeRange(NSNotFound, 0);
    NSError * error = nil;

    matchedRange =
        [title rangeOfRegex:REGEX
                    options:RKLNoOptions
                    inRange:NSMakeRange(0, title.length)
                    capture:1
                      error:&error];

    if (error || NSEqualRanges(matchedRange, NSMakeRange(NSNotFound, 0)))
        return nil;
    else
        return [title substringWithRange:matchedRange];
}

+ (NSString *) buildLabelFromProjectTitle:(NSString *)title
{
    static NSString * REGEX = @"\\s+(#.*)\\s+(was|has)";

    NSRange matchedRange = NSMakeRange(NSNotFound, 0);
    NSError * error = nil;

    matchedRange =
        [title rangeOfRegex:REGEX
                    options:RKLNoOptions
                    inRange:NSMakeRange(0, title.length)
                    capture:1
                      error:&error];

    if (error || NSEqualRanges(matchedRange, NSMakeRange(NSNotFound, 0)))
        return nil;
    else
        return [title substringWithRange:matchedRange];
}

+ (NSDate *) dateFromTeamCityString:(NSString *)dateAsString
{
    NSDate * utcDate = [NSDate dateFromString:dateAsString
                                       format:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];

    // CruiseControl.rb uses UTC timestamps, so make sure our NSDate, which
    // has a time for the local time zone, is adjusted appropriately.
    NSTimeZone * local = [NSTimeZone localTimeZone];
    return [utcDate addTimeInterval:[local secondsFromGMT]];
}

+ (BOOL) buildSucceededFromProjectTitle:(NSString *)title
{
    static NSString * REGEX = @"(successful)$";

    NSRange matchedRange = NSMakeRange(NSNotFound, 0);
    NSError * error = nil;

    matchedRange =
        [title rangeOfRegex:REGEX
                    options:RKLNoOptions
                    inRange:NSMakeRange(0, title.length)
                    capture:1
                      error:&error];

    return !(error || NSEqualRanges(matchedRange, NSMakeRange(NSNotFound, 0)));
}

@end
