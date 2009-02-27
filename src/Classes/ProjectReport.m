//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ProjectReport.h"

@implementation ProjectReport

@synthesize name;
@synthesize buildLabel;
@synthesize buildDescription;
@synthesize buildPubDate;
@synthesize buildDashboardLink;
@synthesize forceBuildLink;
@synthesize buildSucceededState;

+ (id) report
{
    return [[[[self class] alloc] init] autorelease];
}

- (void) dealloc
{
    [name release];
    [buildLabel release];
    [buildDescription release];
    [buildPubDate release];
    [buildDashboardLink release];
    [forceBuildLink release];
    [super dealloc];
}

- (id) copyWithZone:(NSZone *)zone
{
    ProjectReport * report = [[[self class] allocWithZone:zone] init];

    report.name = self.name;
    report.buildLabel = self.buildLabel;
    report.buildDescription = self.buildDescription;
    report.buildPubDate = self.buildPubDate;
    report.buildDashboardLink = self.buildDashboardLink;
    report.forceBuildLink = self.forceBuildLink;
    report.buildSucceededState = self.buildSucceededState;

    return report;
}

- (NSString *) longDescription
{
    NSMutableString * desc = [NSMutableString string];

    [desc appendFormat:@"Name: '%@'\n", self.name];
    [desc appendFormat:@"Label: '%@'\n", self.buildLabel];
    [desc appendFormat:@"Description: '%@'\n", self.buildDescription];
    [desc appendFormat:@"Pub date: '%@'\n", self.buildPubDate];
    [desc appendFormat:@"Link: '%@'\n", self.buildDashboardLink];
    [desc appendFormat:@"Force build link: '%@'\n", self.forceBuildLink];
    [desc appendFormat:@"Build succeeded: '%d'\n", self.buildSucceededState];

    return desc;
}

@end
