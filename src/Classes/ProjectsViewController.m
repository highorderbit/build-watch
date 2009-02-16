//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ProjectsViewController.h"

@interface ProjectsViewController (Private)

- (void) setVisibleProjects:(NSArray *)someVisibleProjects;

- (void) updateVisibleProjects;

- (void) updateCell:(ProjectTableViewCell *)cell
        withProject:(NSString *)project;

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
    NSLog(@"%@: Displaying.", self);
    
    [super viewWillAppear:animated];

    self.navigationItem.title = [delegate displayNameForCurrentProjectGroup];

    NSIndexPath * selectedRow = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selectedRow animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated
{
    NSLog(@"%@: Hiding.", self);
    
    [super viewWillDisappear:animated];
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
    
    [self updateCell:cell withProject:project];
    
    return cell;
}

- (void) updateCell:(ProjectTableViewCell *)cell withProject:(NSString *)project
{
    [cell setName:[delegate displayNameForProject:project]];
    
    BOOL buildSucceeded = [delegate buildSucceededStateForProject:project];
    [cell setBuildSucceeded:buildSucceeded];
    
    NSString * buildLabel = [delegate labelForProject:project];
    [cell setBuildLabel:buildLabel];
    
    NSDate * pubDate = [delegate pubDateForProject:project];
    [cell setPubDate:pubDate];
    
    BOOL tracked = [delegate trackedStateForProject:project];
    [cell setTracked:tracked];
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
    ProjectTableViewCell * cell =
        (ProjectTableViewCell *)[tv cellForRowAtIndexPath:indexPath];
    if (!self.editing)
        [delegate userDidSelectProject:project];
    else {
        BOOL formerTrackedState = [delegate trackedStateForProject:project];
        BOOL newTrackedState = !formerTrackedState;
        [delegate setTrackedState:newTrackedState onProject:project];
        
        [cell setTracked:newTrackedState];
        
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
    NSLog(@"Setting editing state to %@ on %@.",
          [NSNumber numberWithBool:editing], self);
    
    [super setEditing:editing animated:animated];
    
    [self updateVisibleProjects];

    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone
                               forView:self.view
                                 cache:YES];
    }
    
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
        self.navigationItem.hidesBackButton = YES;
        [tableView insertRowsAtIndexPaths:indexPathsOfHidden
                         withRowAnimation:UITableViewRowAnimationTop];
    } else {
        self.navigationItem.hidesBackButton = NO;
        [tableView deleteRowsAtIndexPaths:indexPathsOfHidden
                         withRowAnimation:UITableViewRowAnimationTop];
    }
    
    [tableView endUpdates];
    
    if (animated)
        [UIView commitAnimations];
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
    } else
        [self setVisibleProjects:projects];
}

@end
