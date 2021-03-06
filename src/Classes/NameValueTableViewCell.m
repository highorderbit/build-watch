//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "NameValueTableViewCell.h"

@interface NameValueTableViewCell (Private)
+ (UIColor *) nameColor;
+ (UIColor *) nameSelectedColor;
+ (UIColor *) valueColor;
+ (UIColor *) valueSelectedColor;
@end

@implementation NameValueTableViewCell

@synthesize nameLabel;
@synthesize valueLabel;

- (void) dealloc
{
    [nameLabel release];
    [valueLabel release];
    [super dealloc];
}

- (id) initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    UIColor * nameColor, * valueColor;
    if (selected && self.selectionStyle != UITableViewCellSelectionStyleNone) {
        nameColor = [[self class] nameSelectedColor];
        valueColor = [[self class] valueSelectedColor];
    } else {
        nameColor = [[self class] nameColor];
        valueColor = [[self class] valueColor];
    }

    nameLabel.textColor = nameColor;
    valueLabel.textColor = valueColor;
}

#pragma mark Helper functions for creating instances

+ (NameValueTableViewCell *) createInstance
{
    NSArray * nib =
        [[NSBundle mainBundle]
          loadNibNamed:@"NameValueTableViewCell" 
                 owner:self
               options:nil];

    return [nib objectAtIndex:0];
}

+ (NSString *) reuseIdentifier
{
    // must match what is set in the nib file
    return @"NameValueTableViewCell";
}

#pragma mark Get and set the values of the name and value

- (void) setName:(NSString *)name
{
    nameLabel.text = name;
}

- (NSString *) name
{
    return [[nameLabel.text copy] autorelease];
}

- (void) setValue:(NSString *)value
{
    valueLabel.text = value;
}

- (NSString *) value
{
    return [[valueLabel.text copy] autorelease];
}

#pragma mark Static helper methods

+ (UIColor *) nameColor
{
    return [UIColor colorWithRed:0.318
                           green:0.4
                            blue:0.569
                           alpha:1.0];
}

+ (UIColor *) nameSelectedColor
{
    return [UIColor whiteColor];
}

+ (UIColor *) valueColor
{
    return [UIColor blackColor];
}

+ (UIColor *) valueSelectedColor
{
    return [UIColor whiteColor];
}

@end
