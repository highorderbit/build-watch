//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "UIServerDataRefresher.h"

@implementation UIServerDataRefresher

- (void) dealloc
{
    [refresher release];
    [super dealloc];
}

- (IBAction) refreshAllServerData:(id)sender
{
    [refresher refreshAllServerData];
}

@end
