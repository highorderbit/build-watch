//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "ProjectReportViewController.h"
#import "NameValueTableViewCell.h"

static NSString * ActionSectionCellIdentifier = @"ActionSectionCell";

static const NSInteger NUM_SECTIONS = 3;
enum Sections
{
    kBuildDetailsSection,
    kBuildChangesetSection,
    kBuildActionSection
};

static const NSInteger NUM_BUILD_DETAIL_ROWS = 2;
enum BuildDetailRows
{
    kBuildDateRow,
    kBuildLabelRow
};

static const NSInteger NUM_BUILD_CHANGESET_ROWS = 1;
enum BuildChangesetRows
{
    kBuildChangesetDetails
};

static const NSInteger NUM_BUILD_ACTION_ROWS = 3;
enum ActionRows
{
    kForceBuildRow,
    kEmailReportRow,
    kVisitWebsiteRow
};

@interface ProjectReportViewController (Private)
- (void) configureBuildDetailTableViewCell:(NameValueTableViewCell *)cell
                                  forIndex:(NSInteger)index;
- (NSString *) buttonTextForCellAtIndex:(NSInteger)row;
- (void) forceBuild;
- (void) emailReport;
- (void) visitWebsite;
- (NSString *) reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *) cellInstanceForRowAtIndexPath:(NSIndexPath *)indexPath
                                    reuseIdentifier:(NSString *)identifier;
- (void) configureBuildDetailTableViewCell:(NameValueTableViewCell *)cell
                                    forRow:(NSInteger)row;
@end

@implementation ProjectReportViewController

@synthesize tableView;
@synthesize headerImage;
@synthesize headerLabel;
@synthesize projectId;
@synthesize delegate;

- (void) dealloc
{
    [tableView release];
    [headerImage release];
    [headerLabel release];
    [projectId release];
    [delegate release];
    [super dealloc];
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationItem.title =
        NSLocalizedString(@"projectdetails.view.title", @"");

    headerLabel.text = [delegate displayNameForProject:projectId];

    NSIndexPath * selectedRow = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selectedRow animated:NO];
}

#pragma mark UITableViewDelegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tv
{
    return NUM_SECTIONS;
}

- (NSInteger) tableView:(UITableView *)tv
  numberOfRowsInSection:(NSInteger)section
{
    NSInteger nrows = 0;

    switch (section) {
        case kBuildDetailsSection:
            nrows = NUM_BUILD_DETAIL_ROWS;
            break;
        case kBuildChangesetSection:
            nrows = NUM_BUILD_CHANGESET_ROWS;
            break;
        case kBuildActionSection:
            nrows = NUM_BUILD_ACTION_ROWS;
            break;
    }

    return nrows;
}

- (UITableViewCell *) tableView:(UITableView *)tv
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * reuseIdentifier =
        [self reuseIdentifierForRowAtIndexPath:indexPath];

    UITableViewCell * cell =
        [tv dequeueReusableCellWithIdentifier:reuseIdentifier];

    if (cell == nil)
        cell = [self cellInstanceForRowAtIndexPath:indexPath
                                   reuseIdentifier:reuseIdentifier];

    switch (indexPath.section) {
        case kBuildDetailsSection: {
            NameValueTableViewCell * nvcell = (NameValueTableViewCell *) cell;
            [self configureBuildDetailTableViewCell:nvcell
                                             forRow:indexPath.row];
            break;
        }

        case kBuildChangesetSection:
            cell.textAlignment = UITextAlignmentLeft;
            cell.text =
                NSLocalizedString(@"projectdetails.builddetails.label", @"");
            break;

        case kBuildActionSection:
            cell.textAlignment = UITextAlignmentCenter;
            cell.text = [self buttonTextForCellAtIndex:indexPath.row];
            break;
    }

    return cell;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tv
         accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == kBuildChangesetSection ?
        UITableViewCellAccessoryDisclosureIndicator :
        UITableViewCellAccessoryNone;
}

- (NSIndexPath *) tableView:(UITableView *)tv
   willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == kBuildActionSection ? indexPath : nil;
}

- (void)      tableView:(UITableView *)tv
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case kForceBuildRow:
            [self forceBuild];
            break;
        case kEmailReportRow:
            [self emailReport];
            break;
        case kVisitWebsiteRow:
            [self visitWebsite];
            break;
    }
}

#pragma mark Helper methods

- (void) configureBuildDetailTableViewCell:(NameValueTableViewCell *)cell
                                  forIndex:(NSInteger)index
{
    switch (index) {
        case kBuildDateRow:
            cell.name =
                NSLocalizedString(@"projectdetails.builddate.label", @"");
            cell.value = [delegate pubDateForProject:projectId];
            break;

        case kBuildLabelRow:
            cell.name =
                NSLocalizedString(@"projectdetails.buildlabel.label", @"");
            cell.value = [delegate labelForProject:projectId];
            break;
    }
}

- (NSString *) buttonTextForCellAtIndex:(NSInteger)row
{
    switch (row) {
        case kForceBuildRow:
            return NSLocalizedString(@"projectdetails.forcebuild.label", @"");

        case kEmailReportRow:
            return NSLocalizedString(@"projectdetails.emailreport.label", @"");

        case kVisitWebsiteRow:
            return NSLocalizedString(@"projectdetails.visitwebsite.label", @"");
    }

    NSAssert1(0, @"Invalid row provided: %d.", row);
    return nil;  // return something to keep the compiler happy
}

- (void) forceBuild
{
    UIAlertView * alertView =
        [[UIAlertView alloc] initWithTitle:@"Handle button click"
                                   message:nil
                                  delegate:nil
                         cancelButtonTitle:@"Cancel"
                         otherButtonTitles:nil];
    
    alertView.message = @"TODO: force build";
    [alertView show];
}

- (void) emailReport
{
    NSString * displayName = [delegate displayNameForProject:projectId];
    NSString * buildLabel = [delegate labelForProject:projectId];
    NSString * buildStatus =
        [delegate buildSucceededStateForProject:projectId] ?
        @"succeeded" : @"failed";
    NSDate * pubDate = [delegate pubDateForProject:projectId];
    NSString * webAddress = [delegate linkForProject:projectId];
    NSString * details = [delegate descriptionForProject:projectId];
    
    NSString * subject =
        [NSString stringWithFormat:@"%@ build %@ %@",
         displayName, buildLabel, buildStatus];
    NSString * body =
        [NSString stringWithFormat:
         @"-- %@ build report --\n\n"
         "Status:  %@\n"
         "Date:  %@\n"
         "Build:  %@\n\n"
         "Web page:  %@\n\n"
         "Details:\n\n%@",
         displayName, buildStatus, pubDate, buildLabel, webAddress, details];
    NSString * urlString =
        [NSString stringWithFormat:@"mailto:?subject=%@&body=%@",
         subject, body];
    
    NSURL * url = [[NSURL alloc] initWithString:urlString];
    //[[UIApplication sharedApplication] openURL:url];
    NSLog(@"Subject: %@", subject);
    NSLog(@"Body: %@", body);
    NSLog(@"URL: %@", urlString);
    [url release];
}

- (void) visitWebsite
{
    NSString * webAddress = [delegate linkForProject:projectId];
    NSURL * url = [[NSURL alloc] initWithString:webAddress];
    [[UIApplication sharedApplication] openURL:url];
    [url release];
}

- (NSString *) reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * reuseIdentifier = @"";

    switch (indexPath.section) {
        case kBuildDetailsSection:
        case kBuildChangesetSection:
            reuseIdentifier = ActionSectionCellIdentifier;
            break;
        case kBuildActionSection:
            reuseIdentifier = [NameValueTableViewCell reuseIdentifier];
            break;
    }

    return reuseIdentifier;
}

- (UITableViewCell *) cellInstanceForRowAtIndexPath:(NSIndexPath *)indexPath
                                    reuseIdentifier:(NSString *)identifier
{
    UITableViewCell * cell = nil;

    switch (indexPath.section) {
        case kBuildDetailsSection:
            cell = [NameValueTableViewCell createInstance];
            break;
        case kBuildChangesetSection:
        case kBuildActionSection:
            cell =
                [[[UITableViewCell alloc]
                  initWithFrame:CGRectZero reuseIdentifier:identifier]
                 autorelease];
            break;
    }

    return cell;
}

- (void) configureBuildDetailTableViewCell:(NameValueTableViewCell *)cell
                                    forRow:(NSInteger)row
{
    switch (row) {
        case kBuildDateRow:
            cell.name =
                NSLocalizedString(@"projectdetails.builddate.label", @"");
            cell.value = [[NSDate date] description];
            break;

        case kBuildLabelRow:
            cell.name =
                NSLocalizedString(@"projectdetails.buildlabel.label", @"");
            cell.value = @"7.2";
            break;
    }
}

#pragma mark Accessors

- (void) setProjectId:(NSString *)newProjectId
{
    [newProjectId retain];
    [projectId release];
    projectId = newProjectId;
    [tableView reloadData];
}

@end
