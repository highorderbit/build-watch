//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForceBuildTableViewCell : UITableViewCell
{
    UILabel * activityLabel;
    UIActivityIndicatorView * activityIndicator;
    UIImageView * checkmarkImage;
}

@property (nonatomic, retain) IBOutlet UILabel * activityLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *
    activityIndicator;
@property (nonatomic, retain) IBOutlet UIImageView * checkmarkImage;

+ (NSString *) reuseIdentifier;
+ (ForceBuildTableViewCell *) createInstance;

#pragma mark Control the display

- (void) showActivity:(NSString *)description;
- (void) showActivityCompletedSuccessfully:(NSString *)description;
- (void) resetDisplay:(BOOL)animated;

@end
