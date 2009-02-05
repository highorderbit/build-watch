//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "MockBuildService.h"
#import "ServerReport.h"
#import "ProjectReport.h"

@interface MockBuildService (Private)
+ (BOOL)buildSucceededFromProjectName:(NSString *)projectName;
@end

@implementation MockBuildService

@synthesize delegate;

- (void) refreshDataForServer:(NSString *)server
{
    [NSTimer
     scheduledTimerWithTimeInterval:10.0
                             target:self
                           selector:@selector(refreshDataForServerOnTimer:)
                           userInfo:[server copy] repeats:NO];
}

- (void) refreshDataForServerOnTimer:(NSTimer *) timer
{
    NSString * server = (NSString *)timer.userInfo;
    
    ServerReport * report = [[ServerReport alloc] init];
    report.name = @"CruiseControl RSS feed";
    report.link = server;
    
    ProjectReport * projReport1 = [[ProjectReport alloc] init];
    projReport1.name = @"BrokenApp build 7.10 failed";
    projReport1.description =
        @"&lt;pre&gt;Build was manually requested&lt;/pre&gt;";
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss 'Z'";
    projReport1.pubDate =
        [dateFormatter dateFromString:@"Tue, 03 Feb 2009 04:34:11 Z"];
    projReport1.link = @"http://10.0.1.100:3333/builds/BrokenApp/7.10";
    projReport1.buildSucceeded =
        [[self class] buildSucceededFromProjectName:projReport1.name];
    
    ProjectReport * projReport2 = [[ProjectReport alloc] init];
    projReport2.name = @"RandomApp build 4.5 success";
    projReport2.description =
        @"&lt;pre&gt;Build was manually requested&lt;/pre&gt;";
    projReport2.pubDate =
        [dateFormatter dateFromString:@"Tue, 03 Feb 2009 03:50:25 Z"];
    projReport2.link = @"http://10.0.1.100:3333/builds/RandomApp/4.5";
    projReport2.buildSucceeded =
        [[self class] buildSucceededFromProjectName:projReport2.name];
    
    [dateFormatter release];
    
    NSArray * projectReports =
        [NSArray arrayWithObjects:projReport1, projReport2, nil];
    
    report.projectReports = projectReports;
    
    [projReport1 release];
    [projReport2 release];
    
    [delegate report:report receivedFrom:server];
    [report release];
    
    [server release];
}

+ (BOOL)buildSucceededFromProjectName:(NSString *)projectName
{
    static const NSRange NOT_FOUND = { NSNotFound, 0 };
    static NSString * FAILED_STRING = @"failed";

    NSRange where = [projectName rangeOfString:FAILED_STRING];
    return where.location == NOT_FOUND.location &&
           where.length == NOT_FOUND.length;
}

@end
