//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ServerViewController.h"
#import "BuildWatchAppDelegate.h"
#import "ProjectsViewController.h"
#import "ServerTableViewCell.h"
#import "UIColor+BuildWatchColors.h"

@implementation ServerViewController

@synthesize tableView;
@synthesize delegate;

- (void) dealloc
{
    [tableView release];
    [serverGroupNames release];
    [delegate release];
    [addBarButtonItem release];
    [super dealloc];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title =
        NSLocalizedString(@"servergroups.view.title", @"");

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
        serverGroupNames.count > 0;

    [delegate userDidDeselectServerGroupName];

    // ensure we are displaying the freshest data
    [tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
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
    return serverGroupNames.count;
}

- (UITableViewCell *) tableView:(UITableView *)tv
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ServerTableViewCell";

    ServerTableViewCell * cell =
        (ServerTableViewCell *)
        [tv dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        NSArray * nib =
            [[NSBundle mainBundle] loadNibNamed:@"ServerTableViewCell"
                                          owner:self
                                        options:nil];
        cell = (ServerTableViewCell *) [nib objectAtIndex:0];
        cell.hidesAccessoryWhenEditing = NO;
    }

    NSString * serverGroupName =
        [serverGroupNames objectAtIndex:indexPath.row];
    
    cell.nameLabel.text =
        [delegate displayNameForServerGroupName:serverGroupName];
    
    cell.webAddressLabel.text =
        [delegate webAddressForServerGroupName:serverGroupName];
    
    int numBroken =
        [delegate numBrokenForServerGroupName:serverGroupName];
    cell.brokenBuildsLabel.text =
        [NSString
         stringWithFormat:
         NSLocalizedString(@"servergroups.broken.format.string", @""),
         [NSNumber numberWithInt:numBroken]];
    [cell setBrokenBuildTextColor:
        numBroken == 0 ?
        [UIColor buildWatchGreenColor] : [UIColor buildWatchRedColor]];
    
    return cell;
}

- (CGFloat)   tableView:(UITableView *)tv
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (NSIndexPath *) tableView:(UITableView *)tv
willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * server = [serverGroupNames objectAtIndex:indexPath.row];
    
    return tv.editing && ![delegate canServerGroupBeDeleted:server] ?
        nil : indexPath;
}

- (void)      tableView:(UITableView *)tv
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * server = [serverGroupNames objectAtIndex:indexPath.row];

    if (!tv.editing)
        [delegate userDidSelectServerGroupName:server];
    else if([delegate canServerGroupBeDeleted:server])
        [delegate editServerGroupName:server];
}

- (UITableViewCellAccessoryType) tableView:(UITableView *)tv
          accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSString * serverGroupName =
        [serverGroupNames objectAtIndex:indexPath.row];
    
    return [delegate canServerGroupBeDeleted:serverGroupName] || !self.editing ?
        UITableViewCellAccessoryDisclosureIndicator :
        UITableViewCellAccessoryNone;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tv
            editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * serverGroupName =
        [serverGroupNames objectAtIndex:indexPath.row];

    return [delegate canServerGroupBeDeleted:serverGroupName] ?
        UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (void)     tableView:(UITableView *)tv
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString * serverGroupKey =
            [serverGroupNames objectAtIndex:indexPath.row];

        [serverGroupNames removeObject:serverGroupKey];
        [delegate deleteServerGroupWithKey:serverGroupKey];

        [tableView deleteRowsAtIndexPaths:
            [NSArray arrayWithObject:indexPath]
                    withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView reloadData];
    }
}

- (BOOL)        tableView:(UITableView *)tv
    canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSIndexPath *)                  tableView:(UITableView *)tv
    targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath 
                         toProposedIndexPath:(NSIndexPath *)destinationIndexPath
{
    // Allow the proposed destination.
    return destinationIndexPath;
}

- (void)     tableView:(UITableView *)tv
    moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
           toIndexPath:(NSIndexPath *)toIndexPath
{
    NSObject * objectToMove =
        [[serverGroupNames objectAtIndex:fromIndexPath.row] retain];
    [serverGroupNames removeObjectAtIndex:fromIndexPath.row];
    [serverGroupNames insertObject:objectToMove atIndex:toIndexPath.row];

    [delegate userDidSetServerGroupSortOrder:serverGroupNames];

    [objectToMove release];
}

#pragma mark Server manipulation buttons

- (void)addServerGroup
{
    [delegate createServerGroup];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    NSLog(@"Setting editing state to %@ on %@.",
        [NSNumber numberWithBool:editing], self);
    
    [super setEditing:editing animated:animated];
    
    [tableView setEditing:editing animated:animated];
    
    [tableView beginUpdates];
    
    if (editing)
        [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    else
        [self.navigationItem
            setLeftBarButtonItem:addBarButtonItem animated:NO];

    [tableView endUpdates];
}

#pragma mark Accessors

- (void) setServerGroupNames:(NSArray *)someServerGroupNames
{
    NSMutableArray * tmp = [someServerGroupNames mutableCopy];
    [serverGroupNames release];
    serverGroupNames = tmp;

    [tableView reloadData];
}

@end
