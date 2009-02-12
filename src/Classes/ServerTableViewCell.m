//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ServerTableViewCell.h"

@implementation ServerTableViewCell

@synthesize nameLabel;
@synthesize webAddressLabel;
@synthesize brokenBuildsLabel;

- (void) awakeFromNib
{
    self.contentView.clipsToBounds = YES;
}

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
    if(self.contentView == webAddressLabel.superview)
        NSLog(@"Name label IS in the content view");
    else
        NSLog(@"Name label IS NOT in the content view");
    
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
