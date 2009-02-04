//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ProjectsViewController.h"

@implementation ProjectsViewController

@synthesize tableView;

- (void) dealloc
{
    [tableView release];
    [super dealloc];
}

#pragma mark UITableViewDelegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tv
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tv
  numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *) tableView:(UITableView *)tv
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell =
    [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell =
        [[[UITableViewCell alloc]
          initWithFrame:CGRectZero reuseIdentifier:CellIdentifier]
         autorelease];
    
    // Set up the cell
    cell.text = [NSString stringWithFormat:@"project %d", indexPath.row];
    
    return cell;
}

- (void)      tableView:(UITableView *)tv
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic -- create and push a new view controller
}

@end
