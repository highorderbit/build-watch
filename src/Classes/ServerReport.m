//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ServerReport.h"
#import "ProjectReport.h"

@implementation ServerReport

@synthesize name;
@synthesize key;
@synthesize dashboardLink;
@synthesize projectReports;

- (void)dealloc
{
    [name release];
    [key release];
    [dashboardLink release];
    [projectReports release];
    [super dealloc];
}

+ (id)report
{
    return [[[[self class] alloc] init] autorelease];
}

+ (id)reportWithName:(NSString *)aName
                key:(NSString *)aLink
{
    return [[[[self class] alloc] reportWithName:aName key:aLink] autorelease];
}

+ (id)reportWithName:(NSString *)aName
                 key:(NSString *)aLink
       dashboardLink:(NSString *)aDashboardLink
      projectReports:(NSArray *)someReports
{
    return [[[[self class] alloc] initWithName:aName
                                          key:aLink
                                 dashboardLink:aDashboardLink
                                       reports:someReports]
            autorelease];
}

- (id)init
{
    return [self initWithName:nil key:nil];
}

- (id)initWithName:(NSString *)aName
               key:(NSString *)aLink
{
    return [self initWithName:aName key:aLink dashboardLink:nil reports:nil];
}

- (id)initWithName:(NSString *)aName
               key:(NSString *)aLink
     dashboardLink:(NSString *)aDashboardLink
           reports:(NSArray *)someReports
{
    if (self = [super init]) {
        self.name = aName;
        self.key = aLink;
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
                                                   key:self.key
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
    [desc appendFormat:@"Link: '%@'\n", self.key];
    [desc appendFormat:@"Dashboard link: '%@'\n", self.dashboardLink];
    [desc appendFormat:@"Num project reports: '%d'\n",
        self.projectReports.count];

    for (ProjectReport * report in self.projectReports)
        [desc appendFormat:@"%@\n", [report longDescription]];

    return desc;
}

@end
