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
@synthesize delegate;
@synthesize propertyProvider;

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
    tableView.allowsSelectionDuringEditing = YES;
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
    [cell setName:[propertyProvider displayNameForProject:project]];
    
    BOOL buildSucceeded =
        [propertyProvider buildSucceededStateForProject:project];
    [cell setBuildSucceeded:buildSucceeded];
    
    NSString * buildLabel = [propertyProvider labelForProject:project];
    [cell setBuildLabel:buildLabel];
    
    NSDate * pubDate = [propertyProvider pubDateForProject:project];
    [cell setPubDate:pubDate];
    
    BOOL tracked = [propertyProvider trackedStateForProject:project];
    [cell setTracked:tracked];
}

- (CGFloat)   tableView:(UITableView *)tv
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (void)          tableView:(UITableView *)tv
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * project = [visibleProjects objectAtIndex:indexPath.row];
    ProjectTableViewCell * cell =
        (ProjectTableViewCell *)[tv cellForRowAtIndexPath:indexPath];
    if (!self.editing)
        [delegate userDidSelectProject:project];
    else {
        BOOL newTrackedState =
            ![propertyProvider trackedStateForProject:project];
        [delegate setTrackedState:newTrackedState onProject:project];
        
        [cell setTracked:newTrackedState];
        
        [tv deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (UITableViewCellAccessoryType) tableView:(UITableView *)tv
          accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{    
    return self.editing ?
        UITableViewCellAccessoryCheckmark :
        UITableViewCellAccessoryDisclosureIndicator;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tv
            editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

#pragma mark Accessors

- (void) setProjects:(NSArray *)someProjects
{
    NSMutableArray * tempProjects = [someProjects mutableCopy];
    [projects release];
    projects = tempProjects;

    [self updateVisibleProjects];
    
    [tableView reloadData];
}

- (void) setVisibleProjects:(NSArray *)someVisibleProjects
{
    NSMutableArray * tempVisibleProjects = [someVisibleProjects mutableCopy];
    [visibleProjects release];
    visibleProjects = tempVisibleProjects;
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
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone
                               forView:tableView
                                 cache:YES];
    }
    
    NSMutableArray * indexPathsOfHidden = [NSMutableArray array];
    for (NSInteger i = 0; i < projects.count; ++i) {
        NSString * project = [projects objectAtIndex:i];
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        if (![propertyProvider trackedStateForProject:project])
            [indexPathsOfHidden addObject:indexPath];
        else {
            UITableViewCell * cell =
                [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = [self tableView:tableView
                accessoryTypeForRowWithIndexPath:indexPath];
        }
    }
    
    [tableView setEditing:editing animated:animated];
    
    if (animated)
        [UIView commitAnimations];
    
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
}

#pragma mark Private helper functions

- (void) updateVisibleProjects
{
    if (!self.editing) {
        NSMutableArray * tempVisibleProjects = [[NSMutableArray alloc] init];
        for (NSString * project in projects)
            if ([propertyProvider trackedStateForProject:project])
                [tempVisibleProjects addObject:project];
        [self setVisibleProjects:tempVisibleProjects];
    } else
        [self setVisibleProjects:projects];
}

@end
