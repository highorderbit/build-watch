//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ServerReport.h"


@implementation ServerReport

@synthesize name;
@synthesize link;
@synthesize projectReports;

- (void)dealloc
{
    [name release];
    [link release];
    [projectReports release];
    [super dealloc];
}

@end
