//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "MockBuildService.h"
#import "ServerReport.h"
#import "ProjectReport.h"

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
    report.link = server;
    
    ProjectReport * projReport1 = [[ProjectReport alloc] init];
    projReport1.title = @"BrokenApp build 7.10 failed";
    projReport1.description =
        @"&lt;pre&gt;Build was manually requested&lt;/pre&gt;";
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss 'Z'";
    projReport1.pubDate =
        [dateFormatter dateFromString:@"Tue, 03 Feb 2009 04:34:11 Z"];
    projReport1.link = @"http://10.0.1.100:3333/builds/BrokenApp/7.10";
    
    ProjectReport * projReport2 = [[ProjectReport alloc] init];
    projReport2.title = @"RandomApp build 4.5 success";
    projReport2.description =
        @"&lt;pre&gt;Build was manually requested&lt;/pre&gt;";
    projReport2.pubDate =
        [dateFormatter dateFromString:@"Tue, 03 Feb 2009 03:50:25 Z"];
    projReport2.link = @"http://10.0.1.100:3333/builds/RandomApp/4.5";
    
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

@end
