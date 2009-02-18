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

- (void) awakeFromNib
{
    [super awakeFromNib];
    self.contentView.clipsToBounds = YES;
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{    
    [super setSelected:selected animated:animated];
    
    if(selected) {
        nameLabel.textColor = [UIColor whiteColor];
        webAddressLabel.textColor = [UIColor whiteColor];
        brokenBuildsLabel.textColor = [UIColor whiteColor];
    } else {
        nameLabel.textColor = [UIColor blackColor];
        webAddressLabel.textColor = [UIColor grayColor];
        brokenBuildsLabel.textColor = brokenBuildTextColor;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone
                           forView:self
                             cache:YES];

    [self.brokenBuildsLabel setAlpha:self.editing ? 0.0 : 1.0];

    [UIView commitAnimations];
}

- (void) setBrokenBuildTextColor:(UIColor *)color
{
    [color retain];
    [brokenBuildTextColor release];
    brokenBuildTextColor = color;
    if (!self.selected)
        brokenBuildsLabel.textColor = brokenBuildTextColor;
}

@end
