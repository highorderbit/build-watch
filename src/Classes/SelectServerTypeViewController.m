//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "SelectServerTypeViewController.h"
#import "UITableViewCell+BuildWatchAdditions.h"

static const NSInteger NUM_ROWS = 4;
enum ServerTypeRows
{
    kAutoSelectRow,
    kCruiseControlJavaRow,
    kCruiseControlNetRow,
    kCruiseControlRbRow
};

@interface SelectServerTypeViewController (Private)
+ (UIColor *) serverTypeTextColor;
+ (UIColor *) selectedServerTypeTextColor;
@end

@implementation SelectServerTypeViewController

@synthesize tableView;
@synthesize selectedServerType;
@synthesize delegate;

- (void)dealloc
{
    [tableView release];
    [serverTypes release];
    [delegate release];
    [super dealloc];
}

- (void) viewDidLoad
{
    serverTypes =
        [[NSArray alloc] initWithObjects:[NSNull null],
         @"CcjavaServer", @"CcjavaServer", @"CcrbServer", nil];
    selectedServerType = kAutoSelectRow;

    self.navigationItem.title =
        NSLocalizedString(@"servertype.view.title", @"");
}

- (void) viewWillDisappear:(BOOL)animated
{
    NSString * serverTypeName = [serverTypes objectAtIndex:selectedServerType];
    NSLog(@"User selected server type: '%@'.", serverTypeName);

    if ([serverTypeName isEqual:[NSNull null]])
        serverTypeName = nil;

    [delegate userDidSelectServerTypeName:serverTypeName];
}

#pragma mark UITableViewDataSource protocol implementation

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tv
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tv
  numberOfRowsInSection:(NSInteger)section
{
    return NUM_ROWS;
}

- (UITableViewCell *) tableView:(UITableView *)tv
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * reuseIdentifier = @"ServerTypeTableViewCell";

    UITableViewCell * cell =
        [tv dequeueReusableCellWithIdentifier:reuseIdentifier];

    if (cell == nil)
        cell = [UITableViewCell standardTableViewCell:reuseIdentifier];

    switch (indexPath.row) {
        case kAutoSelectRow:
            cell.text = NSLocalizedString(@"servertype.autodetect.label", @"");
            break;
        case kCruiseControlJavaRow:
            cell.text = NSLocalizedString(@"servertype.ccjava.label", @"");
            break;
        case kCruiseControlNetRow:
            cell.text = NSLocalizedString(@"servertype.ccnet.label", @"");
            break;
        case kCruiseControlRbRow:
            cell.text = NSLocalizedString(@"servertype.ccrb.label", @"");
            break;
    }

    cell.textColor =
        indexPath.row == selectedServerType ?
        [[self class] selectedServerTypeTextColor] :
        [[self class] serverTypeTextColor];

    return cell;
}

#pragma mark UITableViewDelegate protocol implementation

- (NSIndexPath *) tableView:(UITableView *)tv
   willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // deselect the current cell by removing the checkmark and resetting
    // its text color
    NSIndexPath * curSelection =
        [NSIndexPath indexPathForRow:selectedServerType inSection:0];
    UITableViewCell * curCell = [tableView cellForRowAtIndexPath:curSelection];
    curCell.accessoryType = UITableViewCellAccessoryNone;
    curCell.textColor = [[self class] serverTypeTextColor];

    // select the new cell by adding the checkmark and setting the text color
    UITableViewCell * newCell = [tableView cellForRowAtIndexPath:indexPath];
    newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    newCell.textColor = [[self class] selectedServerTypeTextColor];

    selectedServerType = indexPath.row;

    return indexPath;
}

- (void)          tableView:(UITableView *)tv
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellAccessoryType) tableView:(UITableView *)tableView
          accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    return selectedServerType == indexPath.row ?
        UITableViewCellAccessoryCheckmark :
        UITableViewCellAccessoryNone;
}

#pragma mark Helper methods

+ (UIColor *) serverTypeTextColor
{
    return [UIColor blackColor];
}

+ (UIColor *) selectedServerTypeTextColor
{
    return [UIColor colorWithRed:0.165
                           green:0.227
                            blue:0.400
                           alpha:1.0];
}

@end
