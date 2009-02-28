//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "UIServerDataRefresherDelegate.h"
#import "NSDate+StringHelpers.h"

@interface UIServerDataRefresherDelegate (Private)
- (void) showRefreshInProgressView;
- (void) showRefreshCompletedView;
- (void) showFailedUpdatesIfNecessary;
+ (NSString *) titleForFailedRequestsAlert:(NSDictionary *)requests
                              displayNames:(NSDictionary *)displayNames;
+ (NSString *) messageForFailedRequestsAlert:(NSDictionary *)requests
                                displayNames:(NSDictionary *)displayNames;
@end


@implementation UIServerDataRefresherDelegate

- (void) dealloc
{
    [refreshLabel release];
    [activityIndicator release];
    [updateLabel release];
    [view release];
    [failedServerRequests release];
    [serverDisplayNames release];
    [serverGroupPropertyProvider release];
    [super dealloc];
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    // initialize refresh label
    refreshLabel = [[UILabel alloc] init];
    [refreshLabel
        setText:NSLocalizedString(@"server.refresh.checking.label", @"")];
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
    serverDisplayNames = [[NSMutableDictionary alloc] init];
}

- (void) refreshingDataForServer:(NSString *)serverKey
{
    if (numOutstandingRequests == 0)
        [self showRefreshInProgressView];

    NSString * displayName =
        [serverGroupPropertyProvider displayNameForServerGroup:serverKey];
    [serverDisplayNames setObject:displayName forKey:serverKey];
    numOutstandingRequests++;
}

- (void) didRefreshDataForServer:(NSString *)server
{
    [serverDisplayNames removeObjectForKey:server];

    if (numOutstandingRequests == 1) {
        [self showRefreshCompletedView];
        [self showFailedUpdatesIfNecessary];
    }

    numOutstandingRequests--;
}

- (void) failedToRefreshDataForServer:(NSString *)server
                                error:(NSError *)error
{
    [failedServerRequests setObject:error forKey:server];

    if (numOutstandingRequests == 1) {
        [self showRefreshCompletedView];
        [self showFailedUpdatesIfNecessary];
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

        NSString * title = [serverDisplayNames objectForKey:serverUrl];
        NSString * message = [NSString stringWithFormat:@"%@\n%@",
                 serverUrl, error.localizedDescription];

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
        [serverDisplayNames removeObjectForKey:serverUrl];
    }
}

- (void) showRefreshCompletedView
{
    [refreshLabel removeFromSuperview];
    [activityIndicator stopAnimating];

    NSDate * currentDate = [NSDate date];
    NSString * dateString = [currentDate buildWatchDescription];

    [updateLabel
        setText:
        [NSString
        stringWithFormat:NSLocalizedString(
        @"server.refresh.update.format.string", @""),
        dateString]];

    [view addSubview:updateLabel];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void) showRefreshInProgressView
{
    [view addSubview:activityIndicator];
    [view addSubview:refreshLabel];

    [activityIndicator startAnimating];

    [updateLabel removeFromSuperview];

    [failedServerRequests removeAllObjects];
    [serverDisplayNames removeAllObjects];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) showFailedUpdatesIfNecessary
{
    if (failedServerRequests.count == 0)
        return;

    NSString * title =
        [[self class] titleForFailedRequestsAlert:failedServerRequests
                                     displayNames:serverDisplayNames];
    NSString * message =
        [[self class] messageForFailedRequestsAlert:failedServerRequests
                                       displayNames:serverDisplayNames];
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

#pragma mark Message formatting helper methods

+ (NSString *) titleForFailedRequestsAlert:(NSDictionary *)requests
                              displayNames:(NSDictionary *)displayNames
{
    NSString * formatString = requests.count == 1 ?
        NSLocalizedString(@"server.refresh.failed.title.singular", @"") :
        NSLocalizedString(@"server.refresh.failed.title.plural", @"");

    return [NSString stringWithFormat:formatString, requests.count];
}

+ (NSString *) messageForFailedRequestsAlert:(NSDictionary *)requests
                                displayNames:(NSDictionary *)displayNames
{
    NSMutableString * message = [NSMutableString string];

    for (NSString * serverUrl in [displayNames allKeys])
        [message appendFormat:@"%@\n", [displayNames objectForKey:serverUrl]];

    return message;
}

@end
