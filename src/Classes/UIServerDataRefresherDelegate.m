//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "UIServerDataRefresherDelegate.h"


@implementation UIServerDataRefresherDelegate

- (void) dealloc
{
    [refreshLabel release];
    [activityIndicator release];
    [updateLabel release];
    [view release];
    [super dealloc];
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    // initialize refresh label
    refreshLabel = [[UILabel alloc] init];
    [refreshLabel setText:@"Checking for build updates..."];
    refreshLabel.adjustsFontSizeToFitWidth = YES;
    refreshLabel.backgroundColor =
        [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    refreshLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    CGRect refreshLabelFrame = CGRectMake(25, 1, 150, 38);
    [refreshLabel setFrame:refreshLabelFrame];
    
    // initialize activity indicator
    activityIndicator = [[UIActivityIndicatorView alloc] init];
    [activityIndicator sizeToFit];
    CGRect activityIndicatorFrame = CGRectMake(0, 14, 18, 18);
    [activityIndicator setFrame:activityIndicatorFrame];
    
    // initialize update label
    updateLabel = [[UILabel alloc] init];
    updateLabel.adjustsFontSizeToFitWidth = YES;
    updateLabel.backgroundColor =
        [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    updateLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    CGRect updateLabelFrame = CGRectMake(10, 1, 165, 38);
    [updateLabel setFrame:updateLabelFrame];
}

- (void) refreshingDataForServer:(NSString *)server
{
    if (numOutstandingRequests == 0) {
        [view addSubview:activityIndicator];
        [view addSubview:refreshLabel];
        
        [activityIndicator startAnimating];
        
        [updateLabel removeFromSuperview];
    }
    
    numOutstandingRequests++;
}

- (void) didRefreshDataForServer:(NSString *)server
{
    if (numOutstandingRequests == 1) {
        [refreshLabel removeFromSuperview];
        [activityIndicator stopAnimating];
        
        NSDate * currentDate = [NSDate date];
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"M/d/yy h:mm aa";
        NSString * dateString = [dateFormatter stringFromDate:currentDate];
        
        [updateLabel setText:[NSString stringWithFormat:@"Updated %@", dateString]];
        [view addSubview:updateLabel];
        
        [dateFormatter release];
    }
    
    numOutstandingRequests--;
}

@end
