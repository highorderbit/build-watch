//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ServerViewController.h"
#import "BuildWatchAppDelegate.h"

@implementation ServerViewController

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView
  numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *) tableView:(UITableView *)tableView
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell =
            [[[UITableViewCell alloc]
              initWithFrame:CGRectZero reuseIdentifier:CellIdentifier]
             autorelease];
    
    // Set up the cell
    cell.text = [NSString stringWithFormat:@"row %d", indexPath.row];
    
    return cell;
}

- (void)      tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic -- create and push a new view controller
}

- (BOOL) shouldAutorotateToInterfaceOrientation:
    (UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview
    [super didReceiveMemoryWarning];
    
    // Release anything that's not essential, such as cached data
}

- (void) dealloc
{
    [super dealloc];
}

@end
