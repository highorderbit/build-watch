//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "EditServerDetailsViewController.h"
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
    kLinkRow,
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
@synthesize serverReport;
@synthesize serverName;

- (void)dealloc
{
    [tableView release];
    [editServerNameCell release];
    [delegate release];
    [serverReport release];
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

    self.serverName = serverReport.name;

    self.navigationItem.rightBarButtonItem.enabled =
        serverName.length > 0;

    UITextField * textField = (UITextField *)
        [self.editServerNameCell viewWithTag:SERVER_NAME_TEXT_FIELD_TAG];
    textField.text = self.serverName;
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
        textField.text = serverName;
    } else {
        NameValueTableViewCell * nameValueCell =
            (NameValueTableViewCell *) cell;

        switch (indexPath.row) {
            case kLinkRow:
                [nameValueCell setName:
                 NSLocalizedString(@"editserverdetails.link.label", @"")];
                [nameValueCell setValue:serverReport.link];
                break;

            case kDashboardLinkRow:
                [nameValueCell setName:
                 NSLocalizedString(@"editserverdetails.dashboardlink.label",
                    @"")];
                [nameValueCell setValue:serverReport.dashboardLink];
                break;

            case kNumberOfProjectsRow:
                [nameValueCell setName:
                 NSLocalizedString(@"editserverdetails.numprojects.label",
                    @"")];
                [nameValueCell setValue:
                 [NSString stringWithFormat:@"%d",
                  serverReport.projectReports.count]];
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
    self.serverName =
        [field.text stringByReplacingCharactersInRange:range withString:string];

    self.navigationItem.rightBarButtonItem.enabled =
        !(range.location == 0 && range.length == 1);

    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.serverName = @"";
    self.navigationItem.rightBarButtonItem.enabled = NO;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.serverName = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Navigation item button actions

- (void) userDidSave
{
    [delegate userDidAddServerNamed:[[serverName copy] autorelease]
             withInitialBuildReport:serverReport];
}

- (void) userDidCancel
{
    [delegate userDidCancel];
}

#pragma mark Accessors

- (UITableViewCell *)editServerNameCell
{
    if (editServerNameCell == nil) {
        editServerNameCell =
            [[UITableViewCell alloc]
              initWithFrame:CGRectZero
            reuseIdentifier:SettingsSectionCellIdentifier];

        CGRect textFieldFrame = CGRectMake(10, 10, 285, 22);
        UITextField * textField =
            [self editServerNameTextFieldWithFrame:textFieldFrame
                                               tag:SERVER_NAME_TEXT_FIELD_TAG];

        [editServerNameCell.contentView addSubview:textField];
    }

    return editServerNameCell;
}


#pragma mark Helper functions

- (UITextField *)editServerNameTextFieldWithFrame:(CGRect)frame
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
