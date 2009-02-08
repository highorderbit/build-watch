//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "AddServerViewController.h"

@interface AddServerViewController (Private)
- (void) userDidSave;
- (void) userDidCancel;
@end

@implementation AddServerViewController

@synthesize tableView;
@synthesize serverUrlTextView;
@synthesize delegate;

- (void)dealloc
{
    [tableView release];
    [serverUrlTextView release];
    [delegate release];
    [super dealloc];
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem * connectButtonItem = [[UIBarButtonItem alloc]
        initWithTitle:NSLocalizedString(@"addserver.nav.connect.title", @"")
                style:UIBarButtonItemStyleDone
               target:self
               action:@selector(userDidSave)];
    UIBarButtonItem * cancelButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                             target:self
                             action:@selector(userDidCancel)];

    [self.navigationItem setRightBarButtonItem:connectButtonItem animated:YES];
    [self.navigationItem setLeftBarButtonItem:cancelButtonItem animated:YES];

    [connectButtonItem release];
    [cancelButtonItem release];

    serverUrlTextView.font = [UIFont systemFontOfSize:20.0];
    serverUrlTextView.clearButtonMode = UITextFieldViewModeWhileEditing;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationItem.title = NSLocalizedString(@"addserver.view.title", @"");

    self.navigationItem.rightBarButtonItem.enabled =
        serverUrlTextView.text.length > 0;

    [serverUrlTextView becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.navigationItem.prompt = nil;
}

#pragma mark UITableView functions

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tv
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tv
  numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tv
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell * cell =
        [tv dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell =
            [[[UITableViewCell alloc]
              initWithFrame:CGRectZero reuseIdentifier:CellIdentifier]
             autorelease];
        [cell.contentView addSubview:serverUrlTextView];
        cell.indentationLevel = 1;  // scoot the text view in a bit
    }

    return cell;
}

#pragma mark UITextField delegate functions

- (BOOL)                textField:(UITextField *)field
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string
{
    self.navigationItem.rightBarButtonItem.enabled =
        !(range.location == 0 && range.length == 1);
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self userDidSave];
    return NO;
}

#pragma mark Navigation item button actions

- (void) userDidSave
{
    [serverUrlTextView resignFirstResponder];
    [serverUrlTextView resignFirstResponder];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.prompt =
        NSLocalizedString(@"addserver.connecting.prompt", @"");
    [delegate addServerWithUrl:serverUrlTextView.text];
}

- (void) userDidCancel
{
    [delegate userDidCancel];
}

@end
