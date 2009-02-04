//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ServerViewController.h"
#import "BuildWatchAppDelegate.h"
#import "ProjectsViewController.h"

@implementation ServerViewController

@synthesize tableView;
@synthesize servers;
@synthesize delegate;

- (void) dealloc
{
    [tableView release];
    [servers release];
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
    return servers.count;
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
    cell.text = [servers objectAtIndex:indexPath.row];

    return cell;
}

- (void)      tableView:(UITableView *)tv
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [delegate userDidSelectServer:[servers objectAtIndex:indexPath.row]];
}

- (UITableViewCellAccessoryType) tableView:(UITableView *)tv
          accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark Accessors

- (void)setServers:(NSArray *)someServers
{
    [servers release];
    servers = [someServers retain];
    [tableView reloadData];
}

@end
