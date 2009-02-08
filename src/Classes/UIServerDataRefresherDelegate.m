//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "UIServerDataRefresherDelegate.h"

@interface UIServerDataRefresherDelegate (Private)
- (void) showRefreshInProgressView;
- (void) showRefreshCompletedView;
+ (NSString *) titleForFailedRequestsAlert:(NSDictionary *)requests;
+ (NSString *) messageForFailedRequestsAlert:(NSDictionary *)requests;
@end


@implementation UIServerDataRefresherDelegate

- (void) dealloc
{
    [refreshLabel release];
    [activityIndicator release];
    [updateLabel release];
    [view release];
    [failedServerRequests release];
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

    failedServerRequests = [[NSMutableDictionary alloc] init];
}

- (void) refreshingDataForServer:(NSString *)server
{
    if (numOutstandingRequests == 0)
        [self showRefreshInProgressView];

    numOutstandingRequests++;
}

- (void) didRefreshDataForServer:(NSString *)server
{
    if (numOutstandingRequests == 1)
        [self showRefreshCompletedView];

    numOutstandingRequests--;
}

- (void) failedToRefreshDataForServer:(NSString *)server error:(NSError *)error
{
    [failedServerRequests setObject:error forKey:server];

    if (numOutstandingRequests == 1) {
        [self showRefreshCompletedView];

        NSString * title =
            [[self class] titleForFailedRequestsAlert:failedServerRequests];
        NSString * message =
            [[self class] messageForFailedRequestsAlert:failedServerRequests];
        NSString * viewDetailsButtonTitle =
            NSLocalizedString(@"server.refresh.failed.details", @"");
        NSString * okButtonTitle =
            NSLocalizedString(@"server.refresh.failed.ok", @"");

        UIAlertView * alertView =
            [[[UIAlertView alloc]
              initWithTitle:title
                    message:message
                   delegate:self
          cancelButtonTitle:viewDetailsButtonTitle
          otherButtonTitles:okButtonTitle, nil]
             autorelease];

        [alertView show];
    }

    numOutstandingRequests--;
}

#pragma mark UIAlertView delegate functions

- (void)       alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //
    // Present an alert for each failed server refresh attempt.
    //

    if (buttonIndex == 0 && failedServerRequests.count > 0) {
        NSString * serverUrl = [[failedServerRequests allKeys] objectAtIndex:0];
        NSError * error = [failedServerRequests objectForKey:serverUrl];

        NSString * title = serverUrl;
        NSString * message = error.localizedDescription;

        NSString * viewNextButtonTitle = failedServerRequests.count == 1 ?
            nil : NSLocalizedString(@"server.refresh.failed.next", @"");
        NSString * okButtonTitle =
            NSLocalizedString(@"server.refresh.failed.ok", @"");

        UIAlertView * nextAlert =
            [[[UIAlertView alloc]
              initWithTitle:title
                    message:message
                   delegate:self
          cancelButtonTitle:viewNextButtonTitle
          otherButtonTitles:okButtonTitle, nil]
             autorelease];

        [nextAlert show];

        [failedServerRequests removeObjectForKey:serverUrl];
    }
}

- (void) showRefreshCompletedView
{
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

- (void) showRefreshInProgressView
{
    [view addSubview:activityIndicator];
    [view addSubview:refreshLabel];

    [activityIndicator startAnimating];

    [updateLabel removeFromSuperview];

    [failedServerRequests removeAllObjects];
}

#pragma mark Message formatting helper methods

+ (NSString *) titleForFailedRequestsAlert:(NSDictionary *)requests
{
    NSString * formatString = requests.count == 1 ?
        NSLocalizedString(@"server.refresh.failed.title.singular", @"") :
        NSLocalizedString(@"server.refresh.failed.title.plural", @"");

    return [NSString stringWithFormat:formatString, requests.count];
}

+ (NSString *) messageForFailedRequestsAlert:(NSDictionary *)requests
{
    NSMutableString * message = [NSMutableString string];

    for (NSString * serverUrl in [requests allKeys])
        [message appendFormat:@"%@\n", serverUrl];

    return message;
}

@end
