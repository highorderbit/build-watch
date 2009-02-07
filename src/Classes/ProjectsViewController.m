//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ProjectsViewController.h"

@interface ProjectsViewController (Private)
- (void) setVisibleProjects:(NSArray *)someVisibleProjects;
- (void) updateVisibleProjects;
@end

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

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setRightBarButtonItem:self.editButtonItem animated:NO];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationItem.title = [delegate displayNameForCurrentProjectGroup];

    NSIndexPath * selectedRow = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selectedRow animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [delegate userDidDeselectServerGroupName];
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

- (UITableViewCellEditingStyle) tableView:(UITableView *)tv
            editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * project = [visibleProjects objectAtIndex:indexPath.row];
    UITableViewCellEditingStyle cellStyle;
    
    if (self.editing)
        cellStyle = [delegate trackedStateForProject:project] ?
            UITableViewCellEditingStyleDelete :
            UITableViewCellEditingStyleInsert;
    else
        cellStyle = UITableViewCellEditingStyleNone;

    return cellStyle;
}

- (void)     tableView:(UITableView *)tv
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleNone) {
        NSString * project = [visibleProjects objectAtIndex:indexPath.row];
        BOOL showProject = editingStyle != UITableViewCellEditingStyleDelete;

        [delegate setTrackedState:showProject onProject:project];
    
        [tableView reloadData];
    }
}

#pragma mark Accessors

- (void) setProjects:(NSArray *)someProjects
{
    [projects release];
    projects = [someProjects retain];

    [self updateVisibleProjects];
    
    [tableView reloadData];
}

- (void) setVisibleProjects:(NSArray *)someVisibleProjects
{
    [someVisibleProjects retain];
    [visibleProjects release];
    visibleProjects = someVisibleProjects;
}

#pragma mark Project manipulation

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{    
    [super setEditing:editing animated:animated];
    
    [self updateVisibleProjects];
    
    [tableView beginUpdates];
    [tableView setEditing:editing animated:animated];
    [tableView endUpdates];
    [tableView reloadData];
}

#pragma mark Private helper functions

- (void) updateVisibleProjects
{
    if (!self.editing) {
        NSMutableArray * tempVisibleProjects = [[NSMutableArray alloc] init];
        for (NSString * project in projects)
            if ([delegate trackedStateForProject:project])
                [tempVisibleProjects addObject:project];
        [self setVisibleProjects:tempVisibleProjects];
    }
    else
        [self setVisibleProjects:projects];
}

@end
