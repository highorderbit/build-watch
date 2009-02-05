//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ServerReport.h"


@implementation ServerReport

@synthesize link;
@synthesize projectReports;

- (void)dealloc
{
    [link release];
    [projectReports release];
    [super dealloc];
}

@end
