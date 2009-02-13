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
    
    ProjectTableViewCell * cell =
        (ProjectTableViewCell *)
        [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray * nib =
        [[NSBundle mainBundle] loadNibNamed:@"ProjectTableViewCell"
                                      owner:self
                                    options:nil];
        cell = (ProjectTableViewCell *) [nib objectAtIndex:0];
    }
    
    NSString * project = [visibleProjects objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = [delegate displayNameForProject:project];
    
    BOOL buildSucceeded = [delegate buildSucceededStateForProject:project];
    NSString * statusDesc = buildSucceeded ? @"succeeded" : @"failed";
    NSString * buildLabel = [delegate labelForProject:project];
    
    cell.buildStatusLabel.text =
        [NSString stringWithFormat:@"Build %@ %@", buildLabel, statusDesc];
    
    UIColor * buildStatusTextColor =
        buildSucceeded ?
        [UIColor colorWithRed:0 green:0.4 blue:0 alpha:1] :
        [UIColor redColor];
    
    [cell setBuildStatusTextColor:buildStatusTextColor];
    
    return cell;
}

- (CGFloat)   tableView:(UITableView *)tv
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (void)      tableView:(UITableView *)tv
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * project = [visibleProjects objectAtIndex:indexPath.row];
    if (!self.editing)
        [delegate userDidSelectProject:project];
    else {
        BOOL currentTrackedState = [delegate trackedStateForProject:project];
        [delegate setTrackedState:!currentTrackedState onProject:project];
        
        UITableViewCell * cell = [tv cellForRowAtIndexPath:indexPath];
        cell.accessoryType =
            [self tableView:tv accessoryTypeForRowWithIndexPath:indexPath];

        [tv deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (UITableViewCellAccessoryType) tableView:(UITableView *)tv
          accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCellAccessoryType editAccessoryType =
        [delegate trackedStateForProject:
        [projects objectAtIndex:indexPath.row]] ?
        UITableViewCellAccessoryCheckmark :
        UITableViewCellAccessoryNone;
    
    return self.editing ?
        editAccessoryType :
        UITableViewCellAccessoryDisclosureIndicator;
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
    
    NSMutableArray * indexPathsOfHidden = [NSMutableArray array];
    for (NSInteger i = 0; i < projects.count; ++i) {
        NSString * project = [projects objectAtIndex:i];
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        if (![delegate trackedStateForProject:project])
            [indexPathsOfHidden addObject:indexPath];
        else {
            UITableViewCell * cell =
                [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = [self tableView:tableView
                accessoryTypeForRowWithIndexPath:indexPath];
        }
    }

    [tableView beginUpdates];
    
    if (editing) {
        [tableView insertRowsAtIndexPaths:indexPathsOfHidden
                         withRowAnimation:UITableViewRowAnimationTop];
    }
    else {
        [tableView deleteRowsAtIndexPaths:indexPathsOfHidden
                         withRowAnimation:UITableViewRowAnimationTop];
    }
    [tableView endUpdates];
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
