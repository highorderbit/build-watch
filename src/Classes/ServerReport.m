//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ServerReport.h"
#import "ProjectReport.h"

@implementation ServerReport

@synthesize name;
@synthesize link;
@synthesize dashboardLink;
@synthesize projectReports;

- (void)dealloc
{
    [name release];
    [link release];
    [dashboardLink release];
    [projectReports release];
    [super dealloc];
}

+ (id)report
{
    return [[[[self class] alloc] init] autorelease];
}

+ (id)reportWithName:(NSString *)aName
                link:(NSString *)aLink
{
    return [[[[self class] alloc] reportWithName:aName link:aLink] autorelease];
}

+ (id)reportWithName:(NSString *)aName
                link:(NSString *)aLink
       dashboardLink:(NSString *)aDashboardLink
      projectReports:(NSArray *)someReports
{
    return [[[[self class] alloc] initWithName:aName
                                          link:aLink
                                 dashboardLink:aDashboardLink
                                       reports:someReports]
            autorelease];
}

- (id)init
{
    return [self initWithName:nil link:nil];
}

- (id)initWithName:(NSString *)aName
              link:(NSString *)aLink
{
    return [self initWithName:aName link:aLink dashboardLink:nil reports:nil];
}

- (id)initWithName:(NSString *)aName
              link:(NSString *)aLink
       dashboardLink:(NSString *)aDashboardLink
           reports:(NSArray *)someReports
{
    if (self = [super init]) {
        self.name = aName;
        self.link = aLink;
        self.dashboardLink = aDashboardLink;
        self.projectReports = someReports;
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    NSArray * reports = [projectReports copyWithZone:zone];

    ServerReport * report =
        [[[self class] allocWithZone:zone] initWithName:self.name
                                                   link:self.link
                                          dashboardLink:self.dashboardLink
                                                reports:reports];

    [reports release];

    return report;
}

- (NSString *) longDescription
{
    NSMutableString * desc = [NSMutableString string];

    [desc appendFormat:@"ServerReport: '%@'\n", self];
    [desc appendFormat:@"Name: '%@'\n", self.name];
    [desc appendFormat:@"Link: '%@'\n", self.link];
    [desc appendFormat:@"Dashboard link: '%@'\n", self.dashboardLink];
    [desc appendFormat:@"Num project reports: '%d'\n",
        self.projectReports.count];

    for (ProjectReport * report in self.projectReports)
        [desc appendFormat:@"%@\n", [report longDescription]];

    return desc;
}

@end
