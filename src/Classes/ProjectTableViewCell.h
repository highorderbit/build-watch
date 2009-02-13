//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectTableViewCell : UITableViewCell {
    UILabel * nameLabel;
    UILabel * buildStatusLabel;
    UIColor * buildStatusTextColor;
}

@property (nonatomic, retain) IBOutlet UILabel * nameLabel;
@property (nonatomic, retain) IBOutlet UILabel * buildStatusLabel;

- (void) setBuildStatusTextColor:(UIColor *)color;
@end
