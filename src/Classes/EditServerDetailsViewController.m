//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "EditServerDetailsViewController.h"
#import "ServerReport.h"

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
@synthesize delegate;
@synthesize serverReport;
@synthesize serverName;

- (void)dealloc
{
    [tableView release];
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
    self.serverName = serverReport.name;
    self.navigationItem.rightBarButtonItem.enabled =
        serverName.length > 0;
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
    static NSString * SettingsSectionCellIdentifier = @"SettingsSectionCell";
    static NSString * DetailsSectionCellIdentifier = @"DetailsSectionCell";

    NSString * cellIdentifier = indexPath.section == kSettingsSection ?
        SettingsSectionCellIdentifier : DetailsSectionCellIdentifier;

    UITableViewCell * cell =
        [tv dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        cell =
            [[[UITableViewCell alloc]
              initWithFrame:CGRectZero reuseIdentifier:cellIdentifier]
             autorelease];

        if (indexPath.section == kSettingsSection) {
            CGRect textFieldFrame = CGRectMake(10, 10, 285, 22);
            UITextField * textField =
                [self
                 editServerNameTextFieldWithFrame:textFieldFrame
                                              tag:SERVER_NAME_TEXT_FIELD_TAG];

            [cell.contentView addSubview:textField];

            // only one text field will ever be created, so this is safe
            [textField becomeFirstResponder];
        }
    }

    if (indexPath.section == kSettingsSection) {
        UITextField * textField =
            (UITextField *) [cell viewWithTag:SERVER_NAME_TEXT_FIELD_TAG];
        textField.text = serverName;
    } else
        switch (indexPath.row) {
            case kLinkRow:
                cell.text = serverReport.link;
                break;

            case kDashboardLinkRow:
                cell.text = serverReport.dashboardLink;
                break;

            case kNumberOfProjectsRow:
                cell.text = [NSString stringWithFormat:NSLocalizedString(
                    @"editserverdetails.numprojects.default.formatstring", @""),
                    serverReport.projectReports.count];
                break;
        }

    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // items in the details section are not selectable
    return indexPath.section == kDetailsSection ? nil : indexPath;
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
    [delegate userDidAddServerNamed:serverName
             withInitialBuildReport:serverReport];
}

- (void) userDidCancel
{
    [delegate userDidCancel];
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
