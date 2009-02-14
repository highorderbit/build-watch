//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectTableViewCell : UITableViewCell {
    UILabel * IBOutlet nameLabel;
    UILabel * IBOutlet buildStatusLabel;

    BOOL buildSucceeded;
    BOOL tracked;
}

- (void) setName:(NSString *)name;

- (void) setBuildStatusText:(NSString *)text;

- (void) setBuildSucceeded:(BOOL)buildSucceeded;

- (void) setTracked:(BOOL)tracked;

@end
