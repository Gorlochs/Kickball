#import "AccountController.h"
#import "LoginController.h"
#import "AccountManager.h"
#import "UserAccount.h"
#import "MGTwitterEngineFactory.h"
#import "TwTabController.h"
#include "util.h"

@interface AccountController(Private)
- (void)saveAccountNotification:(NSNotification*)notification;
- (void)showTabController;
- (void)verifySelectedAccount;
- (void)closeAndReleaserTwitter;
@end

@implementation AccountController

@synthesize canAnimate = _canAnimate;
@synthesize accountManager = _manager;
@synthesize _tableAccounts;

+ (void)showAccountController:(UINavigationController*)navigationController
{
    [navigationController popToRootViewControllerAnimated:YES];
}

- (id)init
{
    // Call init method from super class
    if ((self = [super initWithNibName:@"AccountController" bundle:nil]))
    {
        UIBarButtonItem *button = nil;
        
        // Create left and right buttons on navigation controller.
        // Add button.
        button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(clickAdd)];
        self.navigationItem.rightBarButtonItem = button;
        [button release];
        
        // Edit button
        button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(clickEdit)];
        self.navigationItem.leftBarButtonItem = button;
        [button release];
        
        self.navigationItem.title = NSLocalizedString(@"Accounts", @"");
        self.canAnimate = YES;
        
        _tableAccounts = nil;
        _manager = nil;
		
		shouldShowTabControllerOnAutoLogin = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(saveAccountNotification:) 
                                                     name:(NSString*)LoginControllerAccountDidChange 
                                                   object:nil];
    }
    return self;
}

- (id)initWithManager:(AccountManager*)manager
{
    if (self = [self init])
    {
        _manager = [manager retain];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_tableAccounts release];
    [_manager release];
	[loginController release];
    [self closeAndReleaserTwitter];
	
	[_tableAccounts release];
	_tableAccounts = nil;
	
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.canAnimate = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self closeAndReleaserTwitter];
}

- (void)viewDidLoad
{
    if (_tableAccounts)
        [_tableAccounts reloadData];

    if (self.accountManager.loggedUserAccount && shouldShowTabControllerOnAutoLogin)
    {
        self.canAnimate = NO;
		shouldShowTabControllerOnAutoLogin = NO;
        [self showTabController];
    }
}

#pragma mark Actions
// Create LoginController and push it to navigation controller.
- (IBAction)clickAdd
{
//	LoginController *controller = [[LoginController alloc] initWithNibName:@"Login" bundle:nil];
//	[self.navigationController pushViewController:controller animated:YES];
//	[controller release];
	
	if (nil != loginController)
	{
		[loginController release];
		loginController = nil;
	}

    loginController = [[LoginController alloc] initWithNibName:@"Login" bundle:nil];
//    loginController.twitterEngine = (XAuthTwitterEngine*)_twitter;
    [self.navigationController pushViewController:loginController animated:YES];
    
//	loginController = [[LoginController alloc] init];
//	[loginController showOAuthViewInController:self.navigationController];
}

- (IBAction)clickEdit
{
    [_tableAccounts setEditing:!_tableAccounts.editing];
    return;
}

#pragma mark UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSIndexPath *index = [_tableAccounts indexPathForSelectedRow];
    UITableViewCell *cell = [_tableAccounts cellForRowAtIndexPath:index];
    
    UserAccount *account = [self.accountManager accountByUsername:cell.textLabel.text];
    
    if (buttonIndex == 0)
    {
        // Remove selected account
        [self.accountManager removeAccount:account];
    }
    else if (buttonIndex == 1)
    {
        // Edit selected account. Navigate LoginController with account data.
		if (nil != loginController)
		{
			[loginController release];
			loginController = nil;
		}
		
		loginController = [[LoginController alloc] initWithUserAccount:account];
		[loginController showOAuthViewInController:self.navigationController];
//      [self.navigationController pushViewController:login animated:YES];
//      [login release];
    }
    
    [_tableAccounts setEditing:NO];
    [_tableAccounts reloadData];
}

#pragma mark UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.accountManager allAccountUsername] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"AccountCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kCellIdentifier] autorelease];
    
    cell.textLabel.text = [[self.accountManager allAccountUsername] objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.editing)
    {
        NSIndexPath *index = [_tableAccounts indexPathForSelectedRow];
        UITableViewCell *cell = [_tableAccounts cellForRowAtIndexPath:index];
        
        UserAccount *account = [self.accountManager accountByUsername:cell.textLabel.text];

        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = NO;
        
        // Login with user
        [self.accountManager login:account];
        
        [self verifySelectedAccount];
        
        //[self showTabController];
    }
    else
    {
        // Show alert
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle: nil
                                                            delegate: self 
                                                   cancelButtonTitle: NSLocalizedString(@"Cancel", @"")
                                              destructiveButtonTitle: NSLocalizedString(@"Delete", @"")
                                                   otherButtonTitles: NSLocalizedString(@"Change", @""), nil];
        [action showInView:self.view];
        [action release];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert);
}

@end

@implementation AccountController(Private)

- (void)saveAccountNotification:(NSNotification*)notification
{
    NSDictionary *loginData = (NSDictionary*)[notification userInfo];
    
    UserAccount *newAccount = [loginData objectForKey:kNewAccountLoginDataKey];
    UserAccount *oldAccount = [loginData objectForKey:kOldAccountLoginDataKey];
    
    if (newAccount)
    {
        if (oldAccount)
            [self.accountManager replaceAccount:oldAccount with:newAccount];
        else
            [self.accountManager saveAccount:newAccount];
        
        [_tableAccounts reloadData];
    }
}

- (void)showTabController
{
    // Navigate tab controller
    TwTabController *tab = [[TwTabController alloc] init];
    [self.navigationController pushViewController:tab animated:self.canAnimate];
    [tab release];
}

- (void)verifySelectedAccount
{
    [self closeAndReleaserTwitter];
    _twitter = [[MGTwitterEngineFactory createTwitterEngineForCurrentUser:self] retain];
    
    _credentialIdentifier = [_twitter checkUserCredentials];
}

- (void)closeAndReleaserTwitter
{
    if (_twitter) {
        [_twitter closeAllConnections];
        [_twitter release];
        _twitter = nil;
    }
}

#pragma mark MGTwitterEngine delegate methods
- (void)requestSucceeded:(NSString *)connectionIdentifier
{
    if ([connectionIdentifier isEqualToString:_credentialIdentifier])
        [self showTabController];
    _credentialIdentifier = nil;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
    UIAlertView *theAlert = CreateAlertWithError(error);
    [theAlert show];
    [theAlert release];
    
    _credentialIdentifier = nil;
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;
}

@end