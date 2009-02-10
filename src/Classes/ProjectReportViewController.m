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
    UIAlertView * alertView =
        [[UIAlertView alloc] initWithTitle:@"Handle button click"
                                   message:nil
                                  delegate:nil
                         cancelButtonTitle:@"Cancel"
                         otherButtonTitles:nil];
       switch (indexPath.row) {
        case kForceBuildCell:
            alertView.message = @"TODO: force build";
            [alertView show];
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

- (void) emailReport
{
    NSURL * url =
        [[NSURL alloc]
         initWithString:@"mailto:?subject=subject&body=body"];
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
