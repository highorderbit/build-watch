//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "AddServerViewController.h"
#import "UITableViewCell+BuildWatchAdditions.h"

static NSString * TEXT_FIELD_TABLE_VIEW_CELL_IDENTIFIER =
    @"TextFieldTableViewCellIdentifier";
static NSString * STANDARD_TABLE_VIEW_CELL_IDENTIFIER =
    @"StandardTableViewCellIdentifier";
static const NSInteger SERVER_URL_TEXT_FIELD_TAG = 1;

static const NSInteger NUM_SECTIONS = 2;
enum Sections
{
    kInputSection,
    kHelpSection
};

// Changing this constant to '2' will show the server type selection row.
// Removing until this feature is revisited.
static const NSInteger NUM_INPUT_ROWS = 1;
enum InputRows
{
    kUrlRow,
    kRssSelectionRow
};

static const NSInteger NUM_HELP_ROWS = 1;
enum HelpRows
{
    kHelpRow
};

@interface AddServerViewController (Private)
- (void) userDidSave;
- (void) userDidCancel;
- (NSString *) reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *) tableViewCellInstanceForIndexPath:(NSIndexPath *)indexPath
                                        reuseIdentifier:(NSString *)identifier;
- (UITextField *) editServerUrlTextFieldWithFrame:(CGRect)frame
                                              tag:(NSInteger)tag;
@end

@implementation AddServerViewController

@synthesize tableView;
@synthesize editServerUrlCell;
@synthesize delegate;
@synthesize serverUrl;
@synthesize serverType;

- (void)dealloc
{
    [tableView release];
    [editServerUrlCell release];
    [delegate release];
    [serverUrl release];
    [serverType release];
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

    NSIndexPath * selectedCell = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selectedCell animated:NO];

    UITextField * textField = (UITextField *)
        [self.editServerUrlCell viewWithTag:SERVER_URL_TEXT_FIELD_TAG];
    textField.text = serverUrl;
    textField.enabled = YES;
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

// TODO: REMOVE ME BEFORE DEPLOYING
- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        self.serverUrl = @"http://builds.highorderbit.com/projects.rss";
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        self.serverUrl = @"http://megatron.local:8080/dashboard/cctray.xml";

    UITextField * textField = (UITextField *)
        [self.editServerUrlCell viewWithTag:SERVER_URL_TEXT_FIELD_TAG];
    textField.text = serverUrl;
    self.navigationItem.rightBarButtonItem.enabled = YES;

    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UITableView functions

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tv
{
    return NUM_SECTIONS;
}

- (NSInteger) tableView:(UITableView *)tv
  numberOfRowsInSection:(NSInteger)section
{
    NSInteger nrows = 0;

    switch (section) {
        case kInputSection:
            nrows = NUM_INPUT_ROWS;
            break;
        case kHelpSection:
            nrows = NUM_HELP_ROWS;
            break;
    }

    return nrows;
}

- (UITableViewCell *) tableView:(UITableView *)tv
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * reuseIdentifier =
        [self reuseIdentifierForCellAtIndexPath:indexPath];

    UITableViewCell * cell =
        [tv dequeueReusableCellWithIdentifier:reuseIdentifier];

    if (cell == nil)
        cell =
            [self tableViewCellInstanceForIndexPath:indexPath
                                    reuseIdentifier:reuseIdentifier];

    switch (indexPath.section) {
        case kInputSection:
            switch (indexPath.row) {
                case kUrlRow: {
                    UITextField * textField = (UITextField *)
                        [cell viewWithTag:SERVER_URL_TEXT_FIELD_TAG];
                    textField.text = serverUrl;
                    break;
                }

                case kRssSelectionRow:
                    cell.text =
                        NSLocalizedString(@"addserver.rsstype.label", @"");
                    break;
            }
            break;

        case kHelpSection:
            switch (indexPath.row) {
                case kHelpRow:
                    cell.text = NSLocalizedString(@"addserver.help.label", @"");
                    break;
            }
            break;
    }

    return cell;
}

- (NSIndexPath *) tableView:(UITableView *)tableView
   willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == kInputSection && indexPath.row == kUrlRow) ?
        nil : indexPath;
}

- (void)          tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kInputSection && indexPath.row == kRssSelectionRow)
        [delegate userDidSelectServerType];
    else if (indexPath.section == kHelpSection)
        [delegate userRequestsHelp];
}

- (UITableViewCellAccessoryType) tableView:(UITableView *)tableView
          accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    return
        (indexPath.section == kInputSection && indexPath.row == kUrlRow) ?
        UITableViewCellAccessoryNone :
        UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark UITextField delegate functions

- (BOOL)                textField:(UITextField *)field
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string
{
    self.serverUrl =
        [field.text stringByReplacingCharactersInRange:range withString:string];

    self.navigationItem.rightBarButtonItem.enabled =
        serverUrl.length > 0 && [delegate isServerGroupUrlValid:serverUrl];

    return YES;
}

- (BOOL) textFieldShouldClear:(UITextField *)textField
{
    self.serverUrl = @"";
    self.navigationItem.rightBarButtonItem.enabled = NO;

    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
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
    textField.enabled = NO;

    [delegate addServerWithUrl:[[self.serverUrl copy] autorelease]];
}

- (void) userDidCancel
{
    [delegate userDidCancelAddingServerWithUrl:
        [[self.serverUrl copy] autorelease]];
}

#pragma mark Accessor methods

- (UITableViewCell *)editServerUrlCell
{
    if (editServerUrlCell == nil) {
        editServerUrlCell =
            [[UITableViewCell alloc]
              initWithFrame:CGRectZero
            reuseIdentifier:TEXT_FIELD_TABLE_VIEW_CELL_IDENTIFIER];

        CGRect textFieldFrame = CGRectMake(10.0, 10.0, 285.0, 22.0);
        UITextField * textField =
            [self editServerUrlTextFieldWithFrame:textFieldFrame
                                              tag:SERVER_URL_TEXT_FIELD_TAG];

        [editServerUrlCell.contentView addSubview:textField];
    }

    return editServerUrlCell;
}

#pragma mark Helper functions

- (NSString *) reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == kInputSection && indexPath.row == kUrlRow ?
        TEXT_FIELD_TABLE_VIEW_CELL_IDENTIFIER :
        STANDARD_TABLE_VIEW_CELL_IDENTIFIER;
}

- (UITableViewCell *) tableViewCellInstanceForIndexPath:(NSIndexPath *)indexPath
                                        reuseIdentifier:(NSString *)identifier
{
    UITableViewCell * cell = nil;

    switch (indexPath.section) {
        case kInputSection:
            cell =
                indexPath.row == kUrlRow ?
                self.editServerUrlCell :
                [UITableViewCell standardTableViewCell:identifier];
            break;
        case kHelpSection:
            cell = [UITableViewCell standardTableViewCell:identifier];
            break;
    }

    return cell;
}

- (UITextField *) editServerUrlTextFieldWithFrame:(CGRect)frame
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
