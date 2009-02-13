//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ProjectTableViewCell.h"

@implementation ProjectTableViewCell

@synthesize nameLabel;
@synthesize buildStatusLabel;

- (void) dealloc
{
    [nameLabel release];
    [buildStatusLabel release];
    [super dealloc];
}

- (void) awakeFromNib
{
    self.contentView.clipsToBounds = YES;
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{    
    [super setSelected:selected animated:animated];
    
    if (selected) {
        nameLabel.textColor = [UIColor whiteColor];
        buildStatusLabel.textColor = [UIColor whiteColor];
    } else {
        nameLabel.textColor = [UIColor blackColor];
        buildStatusLabel.textColor = buildStatusTextColor;
    }
}

- (void) setBuildStatusTextColor:(UIColor *)color
{
    [color retain];
    [buildStatusTextColor release];
    buildStatusTextColor = color;
    if (!self.selected)
        buildStatusLabel.textColor = buildStatusTextColor;
}

@end
