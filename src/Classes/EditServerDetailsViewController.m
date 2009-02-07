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
static const NSInteger NUMBER_OF_ROWS_IN_DETAILS_SECTION = 2;
enum DetailsSectionRows
{
    kUrlRow,
    kNumberOfProjectsRow
};


@implementation EditServerDetailsViewController

@synthesize tableView;
@synthesize serverNameTextField;
@synthesize delegate;
@synthesize serverReport;

- (void)dealloc
{
    [tableView release];
    [serverNameTextField release];
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

    serverNameTextField.font = [UIFont systemFontOfSize:20.0];
    serverNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
}

- (void) viewWillAppear:(BOOL)animated
{
    serverNameTextField.text = serverReport.name;
    [serverNameTextField becomeFirstResponder];
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

    if (cell == nil)
        cell =
            [[[UITableViewCell alloc]
              initWithFrame:CGRectZero reuseIdentifier:cellIdentifier]
             autorelease];

    if (indexPath.section == kSettingsSection) {
        [cell.contentView addSubview:serverNameTextField];
        cell.indentationLevel = 1;
    } else
        cell.text = indexPath.row == kUrlRow ?
            serverReport.link :
            [NSString stringWithFormat:
             NSLocalizedString(
                @"editserverdetails.numprojects.default.formatstring",
                @""),
             serverReport.projectReports.count];

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
    self.navigationItem.rightBarButtonItem.enabled =
        !(range.location == 0 && range.length == 1);
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Navigation item button actions

- (void) userDidSave
{
    NSString * serverName = serverNameTextField.text;
    [delegate userDidAddServerNamed:serverName
             withInitialBuildReport:serverReport];
}

- (void) userDidCancel
{
    [delegate userDidCancel];
}

@end
