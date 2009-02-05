//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ProjectReport.h"

@implementation ProjectReport

@synthesize name;
@synthesize description;
@synthesize pubDate;
@synthesize link;
@synthesize buildSucceeded;

- (void)dealloc
{
    [name release];
    [description release];
    [pubDate release];
    [link release];
    [super dealloc];
}

@end
