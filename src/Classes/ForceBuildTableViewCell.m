//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ForceBuildTableViewCell.h"

@implementation ForceBuildTableViewCell

@synthesize forceBuildLabel;
@synthesize activityLabel;
@synthesize activityIndicator;
@synthesize checkmarkImage;

+ (NSString *) reuseIdentifier
{
    return @"ForceBuildTableViewCell";
}

+ (ForceBuildTableViewCell *) createInstance
{
    NSArray * nib =
        [[NSBundle mainBundle]
          loadNibNamed:@"ForceBuildTableViewCell" 
                 owner:self
               options:nil];

    return [nib objectAtIndex:0];
}

- (void)dealloc
{
    [forceBuildLabel release];
    [activityLabel release];
    [activityIndicator release];
    [checkmarkImage release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    
    [self resetDisplay:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (selected) {
        forceBuildLabel.textColor = [UIColor whiteColor];
        activityLabel.textColor = [UIColor whiteColor];;
        activityIndicator.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyleWhite;
    } else {
        forceBuildLabel.textColor = [UIColor blackColor];
        activityLabel.textColor = [UIColor blackColor];
        activityIndicator.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyleGray;
    }
}

#pragma mark Control the display

- (void) showActivity:(NSString *)description
{
    if (![activityIndicator isAnimating])
        [activityIndicator startAnimating];

    [checkmarkImage setAlpha:0.0];
    [activityLabel setAlpha:1.0];
    activityLabel.text = description;
}

- (void) showActivityCompletedSuccessfully:(NSString *)description
{
    if ([activityIndicator isAnimating])
        [activityIndicator stopAnimating];

    activityLabel.text = description;
    [checkmarkImage setAlpha:1.0];

    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(resetDisplayOnTimer:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void) resetDisplay:(BOOL)animated
{
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone
                               forView:self
                                 cache:YES];
    }

    if ([activityIndicator isAnimating])
        [activityIndicator stopAnimating];

    [checkmarkImage setAlpha:0.0];
    [activityLabel setAlpha:0.0];

    if (animated)
        [UIView commitAnimations];
}

- (void) resetDisplayOnTimer:(NSTimer *)timer
{
    [self resetDisplay:YES];
}

@end
