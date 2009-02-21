//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "UITableViewCell+BuildWatchAdditions.h"

@implementation UITableViewCell (BuildWatchAdditions)

+ (UITableViewCell *) standardTableViewCell:(NSString *)reuseIdentifier
{
    return [[[UITableViewCell alloc]
             initWithFrame:CGRectZero reuseIdentifier:reuseIdentifier]
            autorelease];
}

@end
