//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "EditServerDetailsViewController.h"
#import "TextFieldTableViewCell.h"
#import "NameValueTableViewCell.h"
#import "ServerReport.h"

static NSString * SettingsSectionCellIdentifier = @"SettingsSectionCell";

static const NSInteger NUMBER_OF_SECTIONS = 2;
enum Sections
{
    kSettingsSection,
    kDetailsSection
};

static const NSInteger NUMBER_OF_ROWS_IN_SETTINGS_SECTION = 1;
static const NSInteger NUMBER_OF_ROWS_IN_DETAILS_SECTION = 3;
enum DetailsSectionRows
{
    kKeyRow,
    kDashboardLinkRow,
    kNumberOfProjectsRow
};

static const NSInteger SERVER_NAME_TEXT_FIELD_TAG = 1;

@interface EditServerDetailsViewController (Private)
- (UITextField *)editServerNameTextFieldWithFrame:(CGRect)frame
                                              tag:(NSInteger)tag;
@end


@implementation EditServerDetailsViewController

@synthesize tableView;
@synthesize editServerNameCell;
@synthesize delegate;
@synthesize serverGroupPropertyProvider;
@synthesize serverGroupKey;
@synthesize serverGroupName;

- (void)dealloc
{
    [tableView release];
    [editServerNameCell release];
    [delegate release];
    [serverGroupPropertyProvider release];
    [serverGroupKey release];
    [serverGroupName release];
    [super dealloc];
}

- (void) viewDidLoad
{
    self.navigationItem.title =
        NSLocalizedString(@"editserverdetails.view.title", @"");

    UIBarButtonItem * saveButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                             target:self
                             action:@selector(userDidSave)];
    UIBarButtonItem * cancelButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                             target:self
                             action:@selector(userDidCancel)];

    [self.navigationItem setRightBarButtonItem:saveButtonItem animated:YES];
    [self.navigationItem setLeftBarButtonItem:cancelButtonItem animated:YES];

    [saveButtonItem release];
    [cancelButtonItem release];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.serverGroupName =
        [serverGroupPropertyProvider
         displayNameForServerGroup:serverGroupKey];

    self.navigationItem.rightBarButtonItem.enabled =
        serverGroupName.length > 0;

    UITextField * textField = (UITextField *)
        [self.editServerNameCell viewWithTag:SERVER_NAME_TEXT_FIELD_TAG];
    textField.text = self.serverGroupName;
    [textField becomeFirstResponder];

    // view is cached once it's created and the table view is not repopulated
    // unless done so manually
    [tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    UITextField * textField = (UITextField *)
        [self.editServerNameCell viewWithTag:SERVER_NAME_TEXT_FIELD_TAG];
    [textField resignFirstResponder];
}

#pragma mark UITableView functions

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tv
{
    return NUMBER_OF_SECTIONS;
}

- (NSInteger) tableView:(UITableView *)tv
  numberOfRowsInSection:(NSInteger)section
{
    return section == kSettingsSection ?
        NUMBER_OF_ROWS_IN_SETTINGS_SECTION : NUMBER_OF_ROWS_IN_DETAILS_SECTION;
}

- (UITableViewCell *) tableView:(UITableView *)tv
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentifier =
        indexPath.section == kSettingsSection ?
            SettingsSectionCellIdentifier :
            [NameValueTableViewCell reuseIdentifier];

    UITableViewCell * cell =
        [tv dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil)
        if (indexPath.section == kSettingsSection)
            cell = self.editServerNameCell;
        else
            cell = [NameValueTableViewCell createInstance];

    if (indexPath.section == kSettingsSection) {
        UITextField * textField =
            (UITextField *) [cell viewWithTag:SERVER_NAME_TEXT_FIELD_TAG];
        textField.text = serverGroupName;
    } else {
        NameValueTableViewCell * nameValueCell =
            (NameValueTableViewCell *) cell;

        switch (indexPath.row) {
            case kKeyRow:
                [nameValueCell setName:
                 NSLocalizedString(@"editserverdetails.link.label", @"")];
                [nameValueCell setValue:serverGroupKey];
                break;

            case kDashboardLinkRow:
                [nameValueCell setName:
                 NSLocalizedString(@"editserverdetails.dashboardlink.label",
                    @"")];
                [nameValueCell setValue:
                 [serverGroupPropertyProvider
                  dashboardLinkForServerGroup:serverGroupKey]];
                break;

            case kNumberOfProjectsRow:
                [nameValueCell setName:
                 NSLocalizedString(@"editserverdetails.numprojects.label",
                    @"")];
                [nameValueCell setValue:
                 [NSString stringWithFormat:@"%d",
                  [serverGroupPropertyProvider
                   numberOfProjectsForServerGroup:serverGroupKey]]];
                break;
        }
    }

    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark UITextField delegate functions

- (BOOL)                textField:(UITextField *)field
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string
{
    self.serverGroupName =
        [field.text stringByReplacingCharactersInRange:range withString:string];

    self.navigationItem.rightBarButtonItem.enabled =
        serverGroupName.length > 0;

    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.serverGroupName = @"";
    self.navigationItem.rightBarButtonItem.enabled = NO;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.serverGroupName = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Navigation item button actions

- (void) userDidSave
{
    NSString * name = [[serverGroupKey copy] autorelease];
    NSString * displayName = [[serverGroupName copy] autorelease];

    [delegate userDidEditServerGroupName:name
                  serverGroupDisplayName:displayName];
}

- (void) userDidCancel
{
    [delegate userDidCancelEditingServerGroupName:
     [[serverGroupKey copy] autorelease]];
}

#pragma mark Accessors

- (TextFieldTableViewCell *) editServerNameCell
{
    if (editServerNameCell == nil) {
        editServerNameCell = [[TextFieldTableViewCell createInstance] retain];

        CGRect textFieldFrame = CGRectMake(10.0, 10.0, 285.0, 22.0);
        UITextField * textField =
            [self editServerNameTextFieldWithFrame:textFieldFrame
                                               tag:SERVER_NAME_TEXT_FIELD_TAG];

        editServerNameCell.textField = textField;
    }

    return editServerNameCell;
}

#pragma mark Helper functions

- (UITextField *) editServerNameTextFieldWithFrame:(CGRect)frame
                                               tag:(NSInteger)tag
{
     UITextField * textField =
         [[[UITextField alloc] initWithFrame:frame] autorelease];

    textField.placeholder =
        NSLocalizedString(@"editserverdetails.servername.placeholder", @"");
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
    textField.returnKeyType = UIReturnKeyDone;
    textField.enablesReturnKeyAutomatically = YES;

    return textField;
}

@end
