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
    [super dealloc];
}

@end
