//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ServerViewController.h"
#import "BuildWatchAppDelegate.h"
#import "ProjectsViewController.h"

@implementation ServerViewController

@synthesize tableView;
@synthesize visibleServerGroupNames;
@synthesize delegate;

- (void) dealloc
{
    [tableView release];
    [serverGroupNames release];
    [visibleServerGroupNames release];
    [delegate release];
    [addBarButtonItem release];
    [super dealloc];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Servers";

    addBarButtonItem = [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                              target:self
                              action:@selector(addServerGroup)];

    [self.navigationItem setLeftBarButtonItem:addBarButtonItem animated:NO];
    [self.navigationItem setRightBarButtonItem:self.editButtonItem animated:NO];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSIndexPath * selectedRow = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selectedRow animated:NO];

    self.navigationItem.leftBarButtonItem.enabled =
        visibleServerGroupNames.count > 0;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [tableView setEditing:NO animated:NO];
}

#pragma mark UITableViewDelegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tv
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tv
  numberOfRowsInSection:(NSInteger)section
{
    return visibleServerGroupNames.count;
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
    cell.text = [delegate displayNameForServerGroupName:
        [visibleServerGroupNames objectAtIndex:indexPath.row]];

    return cell;
}

- (void)      tableView:(UITableView *)tv
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [delegate
     userDidSelectServerGroupName:
        [visibleServerGroupNames objectAtIndex:indexPath.row]];
}

- (UITableViewCellAccessoryType) tableView:(UITableView *)tv
          accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellAccessoryDisclosureIndicator;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tv
            editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing)
        return UITableViewCellEditingStyleDelete;

    NSString * serverGroupName =
        [visibleServerGroupNames objectAtIndex:indexPath.row];

    // return 'none' style for non-deletable server groups to disable the
    // swipe-to-delete motion for those cells
    return [delegate canServerGroupBeDeleted:serverGroupName] ?
        UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (void)     tableView:(UITableView *)tv
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString * serverGroupName =
            [visibleServerGroupNames objectAtIndex:indexPath.row];

        [serverGroupNames removeObject:serverGroupName];
        [delegate deleteServerGroupWithName:serverGroupName];
        // remove locally last to avoid deallocating prematurely
        [visibleServerGroupNames removeObjectAtIndex:indexPath.row];

        [tableView deleteRowsAtIndexPaths:
            [NSArray arrayWithObject:indexPath]
                    withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark Server manipulation buttons

- (void)addServerGroup
{
    [delegate createServerGroup];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    NSMutableArray * indexPaths = [NSMutableArray array];
    NSMutableArray * visible = [NSMutableArray array];

    for (NSInteger i = 0; i < serverGroupNames.count; ++i) {
        NSString * serverGroupName = [serverGroupNames objectAtIndex:i];
        if ([delegate canServerGroupBeDeleted:serverGroupName])
            [visible addObject:serverGroupName];
        else
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }

    [tableView beginUpdates];
    [tableView setEditing:editing animated:animated];

    if (editing) {
        self.visibleServerGroupNames = visible;
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
        [tableView deleteRowsAtIndexPaths:indexPaths
                         withRowAnimation:UITableViewRowAnimationTop];
    } else {
        self.visibleServerGroupNames = serverGroupNames;
        [self.navigationItem
            setLeftBarButtonItem:addBarButtonItem animated:YES];
        [tableView insertRowsAtIndexPaths:indexPaths
                         withRowAnimation:UITableViewRowAnimationTop];
    }

    [tableView endUpdates];
}

#pragma mark Accessors

- (void) setServerGroupNames:(NSArray *)someServerGroupNames
{
    NSMutableArray * tmp = [someServerGroupNames mutableCopy];
    [serverGroupNames release];
    serverGroupNames = tmp;

    [visibleServerGroupNames release];
    visibleServerGroupNames = [someServerGroupNames mutableCopy];

    [tableView reloadData];
}

- (void) setVisibleServerGroupNames:(NSMutableArray *)anotherArray
{
    NSLog(@"Setting visible server group names.");
    [anotherArray retain];
    [visibleServerGroupNames release];
    visibleServerGroupNames = anotherArray;
}

@end
