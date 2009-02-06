//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ProjectsViewController.h"

@implementation ProjectsViewController

@synthesize tableView;
@synthesize projects;
@synthesize delegate;

- (void) dealloc
{
    [tableView release];
    [projects release];
    [visibleProjects release];
    [delegate release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"%@: Awaking from nib.", self);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationItem.title = [delegate displayNameForCurrentProjectGroup];

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
    return visibleProjects.count;
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
    
    cell.text =
        [delegate
         displayNameForProject:[visibleProjects objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)      tableView:(UITableView *)tv
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [delegate
     userDidSelectProject:[visibleProjects objectAtIndex:indexPath.row]];
}

- (UITableViewCellAccessoryType) tableView:(UITableView *)tv
          accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark Accessors

- (void) setProjects:(NSArray *)someProjects
{
    [projects release];
    projects = [someProjects retain];

    [visibleProjects release];
    NSMutableArray * tempVisibleProjects = [[NSMutableArray alloc] init];
    for (NSString * project in someProjects)
        if ([delegate trackedStateForProject:project])
            [tempVisibleProjects addObject:project];
    
    visibleProjects = tempVisibleProjects;
    
    [tableView reloadData];
}

@end
