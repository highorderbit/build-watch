//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "AddServerViewController.h"

static NSString * CellIdentifier = @"Cell";
static const NSInteger SERVER_URL_TEXT_FIELD_TAG = 1;

@interface AddServerViewController (Private)
- (void) userDidSave;
- (void) userDidCancel;
- (UITextField *)editServerUrlTextFieldWithFrame:(CGRect)frame
                                             tag:(NSInteger)tag;
@end

@implementation AddServerViewController

@synthesize tableView;
@synthesize editServerUrlCell;
@synthesize delegate;
@synthesize serverUrl;

- (void)dealloc
{
    [tableView release];
    [editServerUrlCell release];
    [delegate release];
    [serverUrl release];
    [super dealloc];
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem * connectButtonItem = [[UIBarButtonItem alloc]
        initWithTitle:NSLocalizedString(@"addserver.nav.connect.title", @"")
                style:UIBarButtonItemStyleDone
               target:self
               action:@selector(userDidSave)];
    UIBarButtonItem * cancelButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                             target:self
                             action:@selector(userDidCancel)];

    [self.navigationItem setRightBarButtonItem:connectButtonItem animated:YES];
    [self.navigationItem setLeftBarButtonItem:cancelButtonItem animated:YES];

    [connectButtonItem release];
    [cancelButtonItem release];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationItem.title = NSLocalizedString(@"addserver.view.title", @"");
    self.navigationItem.prompt =
        NSLocalizedString(@"addserver.view.prompt", @"");

    self.navigationItem.rightBarButtonItem.enabled = serverUrl.length > 0;

    UITextField * textField = (UITextField *)
        [self.editServerUrlCell viewWithTag:SERVER_URL_TEXT_FIELD_TAG];
    textField.text = serverUrl;
    [textField becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.navigationItem.prompt = nil;

    UITextField * textField = (UITextField *)
        [self.editServerUrlCell viewWithTag:SERVER_URL_TEXT_FIELD_TAG];
    [textField resignFirstResponder];
}

#pragma mark UITableView functions

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tv
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tv
  numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tv
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell =
        [tv dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
        cell = self.editServerUrlCell;

    UITextField * textField =
        (UITextField *) [cell viewWithTag:SERVER_URL_TEXT_FIELD_TAG];
    textField.text = serverUrl;

    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;  // selection is forbidden
}

#pragma mark UITextField delegate functions

- (BOOL)                textField:(UITextField *)field
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string
{
    self.serverUrl =
        [field.text stringByReplacingCharactersInRange:range withString:string];

    self.navigationItem.rightBarButtonItem.enabled =
        !(range.location == 0 && range.length == 1);

    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.serverUrl = @"";
    self.navigationItem.rightBarButtonItem.enabled = NO;

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.serverUrl = textField.text;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self userDidSave];
    return NO;
}

#pragma mark Navigation item button actions

- (void) userDidSave
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.prompt =
        NSLocalizedString(@"addserver.connecting.prompt", @"");

    UITextField * textField = (UITextField *)
        [self.editServerUrlCell viewWithTag:SERVER_URL_TEXT_FIELD_TAG];
    [textField resignFirstResponder];

    [delegate addServerWithUrl:self.serverUrl];
}

- (void) userDidCancel
{
    [delegate userDidCancel];
}

#pragma mark Accessor methods

- (UITableViewCell *)editServerUrlCell
{
    if (editServerUrlCell == nil) {
        editServerUrlCell =
            [[[UITableViewCell alloc]
              initWithFrame:CGRectZero reuseIdentifier:CellIdentifier]
             autorelease];

        CGRect textFieldFrame = CGRectMake(10, 10, 285, 22);
        UITextField * textField =
            [self editServerUrlTextFieldWithFrame:textFieldFrame
                                              tag:SERVER_URL_TEXT_FIELD_TAG];

        [editServerUrlCell.contentView addSubview:textField];
    }

    return editServerUrlCell;
}

#pragma mark Helper functions

- (UITextField *)editServerUrlTextFieldWithFrame:(CGRect)frame
                                             tag:(NSInteger)tag
{
     UITextField * textField =
         [[[UITextField alloc] initWithFrame:frame] autorelease];

    textField.placeholder =
        NSLocalizedString(@"addserver.url.placeholder", @"");
    textField.adjustsFontSizeToFitWidth = YES;
    textField.font = [UIFont systemFontOfSize:16.0];
    textField.minimumFontSize = 10.0;
    textField.tag = tag;
    textField.delegate = self;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.clearsOnBeginEditing = NO;
    textField.borderStyle = UITextBorderStyleNone;

    // UITextInputTraits properties
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.returnKeyType = UIReturnKeyDone;
    textField.keyboardType = UIKeyboardTypeURL;
    textField.enablesReturnKeyAutomatically = YES;

    return textField;
}

@end
