//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServerTableViewCell : UITableViewCell
{
    UILabel * nameLabel;
    UILabel * webAddressLabel;
    UILabel * brokenBuildsLabel;
    UIColor * brokenBuildTextColor;
}

@property (nonatomic, retain) IBOutlet UILabel * nameLabel;
@property (nonatomic, retain) IBOutlet UILabel * webAddressLabel;
@property (nonatomic, retain) IBOutlet UILabel * brokenBuildsLabel;

- (void) setBrokenBuildTextColor:(UIColor *)color;

@end
