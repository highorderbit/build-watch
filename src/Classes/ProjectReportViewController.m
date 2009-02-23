//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "ProjectReportViewController.h"
#import "BuildDetailsViewController.h"
#import "NameValueTableViewCell.h"
#import "ForceBuildTableViewCell.h"
#import "NSDate+StringHelpers.h"
#import "UIColor+BuildWatchColors.h"
#import "NSDate+StringHelpers.h"

static NSString * StandardSectionCellIdentifier = @"StandardSectionCell";

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
                               forRowIndex:(NSInteger)row;
- (NSString *) buttonTextForCellAtIndex:(NSInteger)row;
- (void) showBuildChangeset;
- (void) forceBuild;
- (void) emailReport;
- (void) visitWebsite;
- (NSString *) reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *) cellInstanceForRowAtIndexPath:(NSIndexPath *)indexPath
                                    reuseIdentifier:(NSString *)identifier;
+ (UIColor *) textColorForBuildStatus:(BOOL)buildSucceeded;
@end

@implementation ProjectReportViewController

@synthesize headerView;
@synthesize headerImage;
@synthesize headerProjectLabel;
@synthesize headerStatusLabel;
@synthesize tableView;
@synthesize forceBuildTableViewCell;
@synthesize projectId;
@synthesize delegate;
@synthesize buildForcer;

- (void) dealloc
{
    [headerView release];
    [headerImage release];
    [headerProjectLabel release];
    [headerStatusLabel release];
    [tableView release];
    [forceBuildTableViewCell release];
    [projectId release];
    [delegate release];
    [buildForcer release];
    [super dealloc];
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.headerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.tableHeaderView = headerView;

    self.navigationItem.title =
        NSLocalizedString(@"projectdetails.view.title", @"");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationItem.title =
        NSLocalizedString(@"projectdetails.view.title", @"");

    headerImage.image =
        [delegate buildSucceededStateForProject:projectId] ?
            [UIImage imageNamed:@"build-succeeded.png"] :
            [UIImage imageNamed:@"build-broken.png"];
    headerProjectLabel.text = [delegate displayNameForProject:projectId];

    BOOL succeeded = [delegate buildSucceededStateForProject:projectId];
    headerStatusLabel.text = succeeded ?
         NSLocalizedString(@"projectdetails.buildstatus.succeeded.label", @"") :
         NSLocalizedString(@"projectdetails.buildstatus.failed.label", @"");
    headerStatusLabel.textColor =
        [[self class] textColorForBuildStatus:succeeded];

    [self.forceBuildTableViewCell resetDisplay:NO];

    NSIndexPath * selectedRow = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selectedRow animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.forceBuildTableViewCell resetDisplay:NO];
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
                                        forRowIndex:indexPath.row];
            break;
        }

        case kBuildChangesetSection:
            cell.text =
                NSLocalizedString(@"projectdetails.builddetails.label", @"");
            break;

        case kBuildActionSection:
            if (indexPath.row != kForceBuildRow)
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
    return indexPath.section == kBuildDetailsSection ? nil : indexPath;
}

- (void)      tableView:(UITableView *)tv
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kBuildChangesetSection:
            [self showBuildChangeset];
            break;

        case kBuildActionSection:
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
            [tv deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark Helper methods

- (void) configureBuildDetailTableViewCell:(NameValueTableViewCell *)cell
                               forRowIndex:(NSInteger)index
{
    switch (index) {
        case kBuildDateRow:
            cell.name =
                NSLocalizedString(@"projectdetails.builddate.label", @"");
            cell.value =
                [[delegate pubDateForProject:projectId] buildWatchDescription];
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

- (void) showBuildChangeset
{
    BuildDetailsViewController * controller =
        [[BuildDetailsViewController alloc] initWithNibName:@"BuildDetailsView"
                                                     bundle:nil];
    controller.delegate = self.delegate;
    controller.projectId = self.projectId;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (void) forceBuild
{
    [buildForcer
     forceBuildForProject:projectId
        withForceBuildUrl:[delegate forceBuildLinkForProject:projectId]];

    [self.forceBuildTableViewCell showActivity:
        NSLocalizedString(@"projectdetails.forcebuild.started.label", @"")];
}

- (void) emailReport
{
    NSString * displayName = [delegate displayNameForProject:projectId];
    NSString * buildLabel = [delegate labelForProject:projectId];
    NSString * buildStatus =
        [delegate buildSucceededStateForProject:projectId] ?
        @"succeeded" : @"failed";
    
    NSDate * pubDate = [delegate pubDateForProject:projectId];
    NSString * pubDateString = [pubDate buildWatchDescription];
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
         displayName, buildStatus, pubDateString, buildLabel, webAddress,
         details];
    NSString * urlString =
        [[NSString stringWithFormat:@"mailto:?subject=%@&body=%@",
         subject, body]
         stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * url = [[NSURL alloc] initWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
    [url release];
}

- (void) visitWebsite
{
    NSString * webAddress = [delegate linkForProject:projectId];
    NSURL * url = [[NSURL alloc] initWithString:webAddress];
    [[UIApplication sharedApplication] openURL:url];
    [url release];
}

#pragma mark BuildForcerDelegate protocol implememtation

- (void) buildForcedForProject:(NSString *)projectUrl
             withForceBuildUrl:(NSString *)projectForceBuildUrl
{
    [self.forceBuildTableViewCell showActivityCompletedSuccessfully:
        NSLocalizedString(@"projectdetails.forcebuild.finished.label", @"")];
}

- (void) forceBuildForProject:(NSString *)projectUrl
            withForceBuildUrl:(NSString *)projectForceBuildUrl
             didFailWithError:(NSError *)error
{
    [self.forceBuildTableViewCell resetDisplay:NO];

    UIAlertView * alertView =
        [[[UIAlertView alloc]
          initWithTitle:NSLocalizedString(@"forcebuild.failed.title", @"")
                message:
                    [NSString stringWithFormat:
                     NSLocalizedString(
                         @"forcebuild.failed.message.formatstring", @""),
                     [delegate displayNameForProject:projectUrl],
                     error.localizedDescription]
               delegate:nil
      cancelButtonTitle:NSLocalizedString(@"forcebuild.failed.ok", @"")
      otherButtonTitles:nil]
         autorelease];

    [alertView show];
}

#pragma mark Table view helper functions

- (NSString *) reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * reuseIdentifier = @"";

    switch (indexPath.section) {
        case kBuildDetailsSection:
            reuseIdentifier = [NameValueTableViewCell reuseIdentifier];
            break;
        case kBuildChangesetSection:
            reuseIdentifier = StandardSectionCellIdentifier;
            break;
        case kBuildActionSection:
            reuseIdentifier =
                indexPath.row == kForceBuildRow ?
                    [self.forceBuildTableViewCell reuseIdentifier] :
                    StandardSectionCellIdentifier;
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
            cell =
                [[[UITableViewCell alloc]
                  initWithFrame:CGRectZero reuseIdentifier:identifier]
                 autorelease];
            break;
        case kBuildActionSection:
            if (indexPath.row == kForceBuildRow)
                cell = self.forceBuildTableViewCell;
            else
                cell =
                    [[[UITableViewCell alloc]
                      initWithFrame:CGRectZero reuseIdentifier:identifier]
                     autorelease];
            break;
    }

    return cell;
}

+ (UIColor *) textColorForBuildStatus:(BOOL)buildSucceeded
{
    return buildSucceeded ?
        [UIColor colorWithRed:0.118
                        green:0.157
                         blue:0.224
                        alpha:1.0] :
        [UIColor buildWatchRedColor];
}

#pragma mark Accessors

- (ForceBuildTableViewCell *) forceBuildTableViewCell
{
    if (forceBuildTableViewCell == nil)
        forceBuildTableViewCell =
            [[ForceBuildTableViewCell createInstance] retain];

    return forceBuildTableViewCell;
}

- (void) setProjectId:(NSString *)newProjectId
{
    [newProjectId retain];
    [projectId release];
    projectId = newProjectId;
    [tableView reloadData];
}

@end
