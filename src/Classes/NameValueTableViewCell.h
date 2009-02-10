//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NameValueTableViewCell : UITableViewCell
{
    UILabel * nameLabel;
    UILabel * valueLabel;
}

@property (nonatomic, retain) IBOutlet UILabel * nameLabel;
@property (nonatomic, retain) IBOutlet UILabel * valueLabel;

#pragma mark Get and set the values of the name and value

- (void) setName:(NSString *)name;
- (NSString *) name;

- (void) setValue:(NSString *)value;
- (NSString *)value;

@end