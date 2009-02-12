//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ProjectReport.h"

@implementation ProjectReport

@synthesize name;
@synthesize label;
@synthesize description;
@synthesize pubDate;
@synthesize link;
@synthesize forceBuildLink;
@synthesize buildSucceeded;

+ (id) report
{
    return [[[[self class] alloc] init] autorelease];
}

- (void) dealloc
{
    [name release];
    [label release];
    [description release];
    [pubDate release];
    [link release];
    [forceBuildLink release];
    [super dealloc];
}

- (id) copyWithZone:(NSZone *)zone
{
    ProjectReport * report = [[[self class] allocWithZone:zone] init];

    report.name = self.name;
    report.label = self.label;
    report.description = self.description;
    report.pubDate = self.pubDate;
    report.link = self.link;
    report.forceBuildLink = self.forceBuildLink;
    report.buildSucceeded = self.buildSucceeded;

    return report;
}

@end
