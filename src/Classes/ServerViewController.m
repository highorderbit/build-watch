//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ServerViewController.h"
#import "BuildWatchAppDelegate.h"
#import "ProjectsViewController.h"

@implementation ServerViewController

@synthesize tableView;
@synthesize serverGroupNames;
@synthesize delegate;

- (void) dealloc
{
    [tableView release];
    [serverGroupNames release];
    [delegate release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"%@: Awaking from nib.", self);
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
    return serverGroupNames.count;
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
    cell.text = [serverGroupNames objectAtIndex:indexPath.row];

    return cell;
}

- (void)      tableView:(UITableView *)tv
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [delegate
     userDidSelectServerGroupName:[serverGroupNames objectAtIndex:indexPath.row]];
}

- (UITableViewCellAccessoryType) tableView:(UITableView *)tv
          accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark Accessors

- (void)setServerGroupNames:(NSArray *)someServerGroupNames
{
    [someServerGroupNames retain];
    [serverGroupNames release];
    serverGroupNames = someServerGroupNames;
    
    [tableView reloadData];
}

@end
