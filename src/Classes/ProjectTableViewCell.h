//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectTableViewCell : UITableViewCell {
    IBOutlet UILabel * nameLabel;
    IBOutlet UILabel * buildStatusLabel;
    IBOutlet UILabel * pubDateLabel;

    BOOL buildSucceeded;
    NSString * buildLabel;
    BOOL tracked;
    NSDate * pubDate;
}

- (void) setName:(NSString *)name;

- (void) setBuildSucceeded:(BOOL)buildSucceeded;

- (void) setBuildLabel:(NSString *)buildLabel;

- (void) setTracked:(BOOL)tracked;

- (void) setPubDate:(NSDate *)pubDate;

@end
