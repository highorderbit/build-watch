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

    // hide the number of broken builds
    [self.brokenBuildsLabel setAlpha:self.editing ? 0.0 : 1.0];

    [UIView commitAnimations];

    // reduce size of the URL so any trailing "..." is visible to the left
    // of the accessory views
    CGRect contentFrame = self.contentView.frame;
    CGRect webAddressFrame = webAddressLabel.frame;
    webAddressFrame.size.width = contentFrame.size.width - 25.0;
    webAddressLabel.frame = webAddressFrame;

    // stretch the size of the name during editing so it can make use of
    // the real estate freed up by hiding the # of broken builds
    CGRect nameFrame = nameLabel.frame;
    nameFrame.size.width = editing ? webAddressFrame.size.width : 182.0;
    nameLabel.frame = nameFrame;
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
