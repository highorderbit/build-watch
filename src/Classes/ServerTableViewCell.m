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

- (void) layoutSubviews
{
    [super layoutSubviews];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone
                           forView:self
                             cache:YES];

    CGRect contentRect = self.contentView.bounds;

    CGRect webAddressLabelFrame = self.webAddressLabel.frame;
    webAddressLabelFrame.size.width = contentRect.size.width - 25.0;
    self.webAddressLabel.frame = webAddressLabelFrame;

    CGRect nameLabelFrame = self.nameLabel.frame;
    if (self.editing)
        nameLabelFrame.size.width = contentRect.size.width - 25.0;
    else
        // 113.0 provides the correct size as chosen in interface builder.
        // If this becomes a pain to maintain, cache the original rect in
        // 'awakeFromNib' and restore it here.
        nameLabelFrame.size.width = contentRect.size.width - 113.0;
    self.nameLabel.frame = nameLabelFrame;

    [self.brokenBuildsLabel setAlpha:self.editing ? 0.0 : 1.0];

    [UIView commitAnimations];
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

- (void) setBrokenBuildTextColor:(UIColor *)color
{
    [color retain];
    [brokenBuildTextColor release];
    brokenBuildTextColor = color;
    if (!self.selected)
        brokenBuildsLabel.textColor = brokenBuildTextColor;
}

@end
