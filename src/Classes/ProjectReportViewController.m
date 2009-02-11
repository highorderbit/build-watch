//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "ProjectReportViewController.h"

static const NSInteger NUM_SECTIONS = 2;

enum Sections
{
    kProjectDetailSection,
    kProjectActionSection
};

static const NSInteger NUM_PROPERTY_CELLS = 1;
static const NSInteger NUM_ACTION_CELLS = 3;

enum ActionCells
{
    kForceBuildCell,
    kEmailReportCell,
    kVisitWebsiteCell
};

@interface ProjectReportViewController (Private)
- (NSString *) buttonTextForCellAtIndex:(NSInteger)row;
- (void) forceBuild;
- (void) emailReport;
- (void) visitWebsite;
@end

@implementation ProjectReportViewController

@synthesize tableView;
@synthesize projectId;
@synthesize delegate;

- (void) dealloc
{
    [tableView release];
    [projectId release];
    [delegate release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationItem.title =
        NSLocalizedString(@"projectdetails.view.title", @"");

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
    return section == kProjectDetailSection ?
        NUM_PROPERTY_CELLS : NUM_ACTION_CELLS;
}

- (UITableViewCell *) tableView:(UITableView *)tv
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell";

    UITableViewCell * cell =
        [tv dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
        cell =
        [[[UITableViewCell alloc]
          initWithFrame:CGRectZero reuseIdentifier:CellIdentifier]
         autorelease];

    switch (indexPath.section) {
        case kProjectDetailSection:
            cell.text = [delegate displayNameForProject:projectId];
            break;

        case kProjectActionSection:
            cell.text = [self buttonTextForCellAtIndex:indexPath.row];
            break;
    }

    return cell;
}

- (NSIndexPath *) tableView:(UITableView *)tv
   willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == kProjectActionSection ? indexPath : nil;
}

- (void)      tableView:(UITableView *)tv
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case kForceBuildCell:
            [self forceBuild];
            break;
        case kEmailReportCell:
            [self emailReport];
            break;
        case kVisitWebsiteCell:
            [self visitWebsite];
            break;
    }
}

#pragma mark Helper methods

- (NSString *) buttonTextForCellAtIndex:(NSInteger)row
{
    switch (row) {
        case kForceBuildCell:
            return NSLocalizedString(@"projectdetails.forcebuild.label", @"");

        case kEmailReportCell:
            return NSLocalizedString(@"projectdetails.emailreport.label", @"");

        case kVisitWebsiteCell:
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
    
    NSDateFormatter * dateFormatter =
        [[[NSDateFormatter alloc] init]  autorelease];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate * pubDate = [delegate pubDateForProject:projectId];
    NSString * pubDateString = [dateFormatter stringFromDate:pubDate];
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

#pragma mark Accessors

- (void) setProjectId:(NSString *)newProjectId
{
    [newProjectId retain];
    [projectId release];
    projectId = newProjectId;
    [tableView reloadData];
}

@end
