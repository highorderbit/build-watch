//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ProjectTableViewCell.h"
#import "UIColor+BuildWatchColors.h"

@interface ProjectTableViewCell (Private)

- (void) updateUnselectedStyle;

+ (UIColor *) untrackedColor;

+ (UIColor *) buildSucceededColor;

+ (UIColor *) buildFailedColor;

- (UIColor *) currentBuildSucceededColor;

@end

@implementation ProjectTableViewCell

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
    } else
        [self updateUnselectedStyle];
}

- (void) setName:(NSString *)name
{
    nameLabel.text = name;
}

- (void) setBuildStatusText:(NSString *)text
{
    buildStatusLabel.text = text;
}

- (void) setBuildSucceeded:(BOOL)newBuildSucceeded
{
    buildSucceeded = newBuildSucceeded;
    if (!self.selected)
        [self updateUnselectedStyle];
}

- (void) setTracked:(BOOL)newTracked
{
    tracked = newTracked;
    if (!self.selected)
        [self updateUnselectedStyle];
}

#pragma mark Private helper functions

- (void) updateUnselectedStyle
{
    nameLabel.textColor =
        tracked ? [UIColor blackColor] : [[self class] untrackedColor];
    buildStatusLabel.textColor =
        tracked ? [self currentBuildSucceededColor] :
        [[self class] untrackedColor];
}

- (UIColor *) currentBuildSucceededColor
{
    return buildSucceeded ?
        [[self class] buildSucceededColor] : [[self class] buildFailedColor];
}

#pragma mark Private static helper functions

+ (UIColor *) untrackedColor
{
    return [UIColor grayColor];
}

+ (UIColor *) buildSucceededColor
{
    return [UIColor buildWatchGreenColor];
}

+ (UIColor *) buildFailedColor
{
    return [UIColor buildWatchRedColor];
}

@end
