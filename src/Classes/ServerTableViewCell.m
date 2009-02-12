//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ServerTableViewCell.h"

@implementation ServerTableViewCell

@synthesize nameLabel;
@synthesize webAddressLabel;
@synthesize brokenBuildsLabel;

- (void) dealloc
{
    [nameLabel release];
    [webAddressLabel release];
    [brokenBuildsLabel release];
    [brokenBuildTextColor release];
    [super dealloc];
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if(selected) {
        nameLabel.textColor = [UIColor whiteColor];
        webAddressLabel.textColor = [UIColor whiteColor];
        brokenBuildsLabel.textColor = [UIColor whiteColor];
    }
    else {
        nameLabel.textColor = [UIColor blackColor];
        webAddressLabel.textColor = [UIColor grayColor];
        brokenBuildsLabel.textColor = brokenBuildTextColor;
    }
}

- (void) setBrokenBuildTextColor:(UIColor *)color
{
    [color retain];
    [brokenBuildTextColor release];
    brokenBuildTextColor = color;
    if(!self.selected)
        brokenBuildsLabel.textColor = brokenBuildTextColor;
}

@end
