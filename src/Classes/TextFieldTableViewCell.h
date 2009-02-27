//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldTableViewCell : UITableViewCell
{
    UITextField * textField;
}

@property (nonatomic, retain) UITextField * textField;

#pragma mark Helper functions for creating instances

+ (TextFieldTableViewCell *) createInstance;
+ (NSString *) reuseIdentifier;

@end
