//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ServerViewController.h"
#import "BuildWatchAppDelegate.h"
#import "ProjectsViewController.h"

@implementation ServerViewController

@synthesize tableView;

- (void) dealloc
{
    [tableView release];
    [super dealloc];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Servers";
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSIndexPath * selectedRow = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selectedRow animated:NO];
}

#pragma mark UITableViewDelegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tv
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tv
  numberOfRowsInSection:(NSInteger)section
{
    return 30;
}

- (UITableViewCell *) tableView:(UITableView *)tv
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell * cell =
        [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell =
            [[[UITableViewCell alloc]
              initWithFrame:CGRectZero reuseIdentifier:CellIdentifier]
             autorelease];
    
    // Set up the cell
    cell.text = [NSString stringWithFormat:@"server %d", indexPath.row];
    
    return cell;
}

- (void)      tableView:(UITableView *)tv
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProjectsViewController * projectsViewController =
        [[ProjectsViewController alloc]
         initWithNibName:@"ProjectsView" bundle:nil];
    
    [self.navigationController
     pushViewController:projectsViewController animated:YES];
    
    [projectsViewController release];
}

- (UITableViewCellAccessoryType) tableView:(UITableView *)tv
          accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellAccessoryDisclosureIndicator;
}

@end
