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

- (NSString *) longDescription
{
    NSMutableString * desc = [NSMutableString string];

    [desc appendFormat:@"Name: '%@'\n", self.name];
    [desc appendFormat:@"Label: '%@'\n", self.label];
    [desc appendFormat:@"Description: '%@'\n", self.description];
    [desc appendFormat:@"Pub date: '%@'\n", self.pubDate];
    [desc appendFormat:@"Link: '%@'\n", self.link];
    [desc appendFormat:@"Force build link: '%@'\n", self.forceBuildLink];
    [desc appendFormat:@"Build succeeded: '%d'\n", self.buildSucceeded];

    return desc;
}

@end
