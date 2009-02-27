//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "TextFieldTableViewCell.h"

@implementation TextFieldTableViewCell

@synthesize textField;

#pragma mark Helper functions for creating instances

+ (TextFieldTableViewCell *) createInstance
{
    NSString * rid = [[self class] reuseIdentifier];
    TextFieldTableViewCell * cell =
        [[[self class] alloc] initWithFrame:CGRectZero reuseIdentifier:rid];

    return [cell autorelease];
}

+ (NSString *) reuseIdentifier
{
    return @"TextFieldTableViewCell";
}

- (void)dealloc
{
    [textField release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // turn off selection use
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

#pragma mark Accessors

- (void) setTextField:(UITextField *)aTextField
{
    if (textField != aTextField) {
        [textField removeFromSuperview];

        [textField release];
        textField = [aTextField retain];

        [self.contentView addSubview:textField];
    }
}

@end
