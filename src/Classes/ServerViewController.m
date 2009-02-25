//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ServerViewController.h"
#import "BuildWatchAppDelegate.h"
#import "ProjectsViewController.h"
#import "ServerTableViewCell.h"
#import "UIColor+BuildWatchColors.h"

@interface ServerViewController (Private)

- (void) setVisibleServerGroupNames;

@end

@implementation ServerViewController

@synthesize tableView;
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
        visibleServerGroupNames.count > 0;

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
    return visibleServerGroupNames.count;
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
        [visibleServerGroupNames objectAtIndex:indexPath.row];
    
    cell.nameLabel.text =
        [delegate displayNameForServerGroupName:serverGroupName];
    
    cell.webAddressLabel.text =
        [delegate webAddressForServerGroupName:serverGroupName];
    
    int numBroken =
        [delegate numBrokenForServerGroupName:serverGroupName];
    cell.brokenBuildsLabel.text =
        [NSString stringWithFormat:@"%@ broken",
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

- (void)      tableView:(UITableView *)tv
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * server = [visibleServerGroupNames objectAtIndex:indexPath.row];

    if (tv.editing)
        [delegate editServerGroupName:server];
    else
        [delegate userDidSelectServerGroupName:server];
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
        // remove locally last to avoid premature deallocation
        [visibleServerGroupNames removeObjectAtIndex:indexPath.row];

        [tableView deleteRowsAtIndexPaths:
            [NSArray arrayWithObject:indexPath]
                    withRowAnimation:UITableViewRowAnimationFade];
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
        [[visibleServerGroupNames
         objectAtIndex:fromIndexPath.row] retain];
    NSObject * currentObject =
        [[visibleServerGroupNames
         objectAtIndex:toIndexPath.row] retain];

    // put the object in the right place among visible objects
    [visibleServerGroupNames removeObjectAtIndex:fromIndexPath.row];
    [visibleServerGroupNames insertObject:objectToMove atIndex:toIndexPath.row];

    // figure out where to put it within all objects
    NSUInteger source = [serverGroupNames indexOfObject:objectToMove];
    NSAssert1(source != NSNotFound,
        @"Unable to find object to move: '%@'.", objectToMove);
    NSUInteger dest = [serverGroupNames indexOfObject:currentObject];
    NSAssert1(source != NSNotFound,
        @"Unable to find current object: '%@'.", currentObject);

    [serverGroupNames removeObjectAtIndex:source];
    [serverGroupNames insertObject:objectToMove atIndex:dest];

    [delegate userDidSetServerGroupSortOrder:visibleServerGroupNames];

    [objectToMove release];
    [currentObject release];
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

    NSMutableArray * indexPaths = [NSMutableArray array];

    for (NSInteger i = 0; i < serverGroupNames.count; ++i) {
        NSString * serverGroupName = [serverGroupNames objectAtIndex:i];
        if (![delegate canServerGroupBeDeleted:serverGroupName])
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    [tableView setEditing:editing animated:animated];
    
    [tableView beginUpdates];

    [self setVisibleServerGroupNames];
    
    if (editing) {
        [self.navigationItem setLeftBarButtonItem:nil animated:NO];
        [tableView deleteRowsAtIndexPaths:indexPaths
                         withRowAnimation:UITableViewRowAnimationTop];
    } else {
        [self.navigationItem
            setLeftBarButtonItem:addBarButtonItem animated:NO];
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

    [self setVisibleServerGroupNames];

    [tableView reloadData];
}

- (void) setVisibleServerGroupNames
{
    [visibleServerGroupNames release];
    
    if (self.editing) {
        visibleServerGroupNames = [NSMutableArray array];
        
        for (NSInteger i = 0; i < serverGroupNames.count; ++i) {
            NSString * serverGroupName = [serverGroupNames objectAtIndex:i];
            if ([delegate canServerGroupBeDeleted:serverGroupName])
                [visibleServerGroupNames addObject:serverGroupName];
        }
    } else
        visibleServerGroupNames = serverGroupNames;
    
    [visibleServerGroupNames retain];
}

@end
