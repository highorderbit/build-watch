//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ProjectReport.h"

@implementation ProjectReport

@synthesize title;
@synthesize description;
@synthesize pubDate;
@synthesize link;

- (void)dealloc
{
    [title release];
    [description release];
    [pubDate release];
    [link release];
    [super dealloc];
}

@end
