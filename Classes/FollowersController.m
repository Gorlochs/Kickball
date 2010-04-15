//Copyright (c) 2009 Imageshack Corp.
//All rights reserved.
//
//Redistribution and use in source and binary forms, with or without
//modification, are permitted provided that the following conditions
//are met:
//1. Redistributions of source code must retain the above copyright
//   notice, this list of conditions and the following disclaimer.
//2. Redistributions in binary form must reproduce the above copyright
//   notice, this list of conditions and the following disclaimer in the
//   documentation and/or other materials provided with the distribution.
//3. The name of the author may not be used to endorse or promote products
//   derived from this software without specific prior written permission.
//
//THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
//IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
//INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
//NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
//THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "FollowersController.h"
#import "LoginController.h"
#import "MGTwitterEngine.h"
#import "MGTwitterEngineFactory.h"
#import "MGTwitterEngine+UserFollowers.h"
#import "ImageLoader.h"
#import "UserInfo.h"
#import "TweetterAppDelegate.h"
#import "TwitEditorController.h"
#import "CustomImageView.h"
#include "util.h"

#define NAME_TAG            1
#define REAL_NAME_TAG       2
#define IMAGE_TAG           3
#define ROW_HEIGHT          60
#define IMAGE_SIDE          48
#define BORDER_WIDTH        5
#define TEXT_OFFSET_X       (BORDER_WIDTH * 2 + IMAGE_SIDE)
#define LABEL_HEIGHT        20
#define LABEL_WIDTH         180
#define TEXT_OFFSET_Y       (BORDER_WIDTH * 2 + LABEL_HEIGHT)

@implementation UserListController

- (void)dealloc
{
	while (_indicatorCount) 
	{
		[self releaseActivityIndicator];
	}
	
    [_activity release];
    
	int connectionsCount = [_twitter numberOfConnections];
	[_twitter closeAllConnections];
	[_twitter removeDelegate];
	[_twitter release];
	while(connectionsCount-- > 0)
		[TweetterAppDelegate decreaseNetworkActivityIndicator];

	[_users release];
	[super dealloc];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
    if (_activity == nil)
        _activity = [[TwActivityIndicator alloc] init];
    
	_loading = [[AccountManager manager] isValidLoggedUser];
	_indicatorCount = 0;
	
	UISegmentedControl *userActionButton = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"New", @"Refresh", nil]] autorelease];
    
    CGRect frame = CGRectMake(235, 7, 80, 30);
    
    [userActionButton setFrame:frame];
    [userActionButton setSegmentedControlStyle:UISegmentedControlStyleBar];
    [userActionButton setImage:[UIImage imageNamed:@"edit.tif"] forSegmentAtIndex:0];
    [userActionButton setImage:[UIImage imageNamed:@"refresh.tif"] forSegmentAtIndex:1];
    [userActionButton addTarget:self action:@selector(changeActionSegment:) forControlEvents:UIControlEventValueChanged];
    [userActionButton setMomentary:YES];
    
    _topBarItem = [[UIBarButtonItem alloc] initWithCustomView:userActionButton];	
	
    _twitter = [[MGTwitterEngineFactory createTwitterEngineForCurrentUser:self] retain];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountChanged:) name:@"AccountChanged" object:nil];
	
	[self performSelector:@selector(reloadAll) withObject:nil afterDelay:0.5f];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	
	self.navigationItem.rightBarButtonItem = _topBarItem;
	
	if(!_users)
		[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)changeActionSegment:(id)sender
{
    UISegmentedControl *seg = (UISegmentedControl*)sender;
    
    if (seg.selectedSegmentIndex == 0)
	{
		TwitEditorController *newMessageView = [[TwitEditorController alloc] init];
		[self.navigationController pushViewController:newMessageView animated:YES];
		[newMessageView release];		
	}
    else
	{
		[self reloadAll];
	}
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (BOOL)noUsers
{
	return !_users || [_users count] == 0;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [self noUsers] ? 1: [_users count];
}

- (UITableViewCell *)tableviewCellWithReuseIdentifier:(NSString *)identifier 
{
	if([identifier isEqualToString:@"UICell"])
	{
		UITableViewCell *uiCell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:identifier] autorelease];
		uiCell.textLabel.textAlignment = UITextAlignmentCenter;
		uiCell.textLabel.font = [UIFont systemFontOfSize:16];
		return uiCell;
	}
    
	if([identifier isEqualToString:@"UserListCell"])
	{
		CGRect rect;
		
		rect = CGRectMake(0.0, 0.0, 320.0, ROW_HEIGHT);
		
		UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:rect reuseIdentifier:identifier] autorelease];
		
		//Userpic view
		rect = CGRectMake(BORDER_WIDTH, (ROW_HEIGHT - IMAGE_SIDE) / 2.0, IMAGE_SIDE, IMAGE_SIDE);
		//UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
        CustomImageView *imageView = [[CustomImageView alloc] initWithFrame:rect];
		imageView.tag = IMAGE_TAG;
		[cell.contentView addSubview:imageView];
		[imageView release];
		
		UILabel *label;
		
		//Username
		rect = CGRectMake(TEXT_OFFSET_X, BORDER_WIDTH, LABEL_WIDTH, LABEL_HEIGHT);
		label = [[UILabel alloc] initWithFrame:rect];
		label.tag = NAME_TAG;
		label.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
		label.highlightedTextColor = [UIColor whiteColor];
		[cell.contentView addSubview:label];
		label.opaque = NO;
		label.backgroundColor = [UIColor clearColor];
		[label release];
		
		//Real Name
		rect = CGRectMake(TEXT_OFFSET_X, TEXT_OFFSET_Y, LABEL_WIDTH, LABEL_HEIGHT);
		label = [[UILabel alloc] initWithFrame:rect];
		label.tag = REAL_NAME_TAG;
		label.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
		label.highlightedTextColor = [UIColor whiteColor];
		[cell.contentView addSubview:label];
		label.opaque = NO;
		label.backgroundColor = [UIColor clearColor];
		[label release];
		
		return cell;
	}
	return nil;
}

- (NSString*)noUsersString
{
	return NSLocalizedString(@"No Followers", @"");
}

- (NSString*)loadingMessagesString
{
	return NSLocalizedString(@"Loading the List of Followers...", @"");
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath 
{
	if([self noUsers])
	{
		//cell.textLabel.text = _loading? [self loadingMessagesString]: [self noUsersString];
        cell.textLabel.text = _loading ? @"" : [self noUsersString];
		return;
	}
    
	if(indexPath.row < [_users count])
	{
		NSDictionary *userData = [_users objectAtIndex:indexPath.row];
		
		//Set userpic
		UIImageView *imageView = (UIImageView *)[cell viewWithTag:IMAGE_TAG];
		//imageView.image = nil;
		//[[ImageLoader sharedLoader] setImageWithURL:[userData objectForKey:@"profile_image_url"] toView:imageView];
        
        //UIImage *avatar = [[ImageLoader sharedLoader] imageWithURL:[userData objectForKey:@"profile_image_url"]];
        //CGSize avatarViewSize = CGSizeMake(48, 48);
        //if(avatar.size.width > avatarViewSize.width || avatar.size.height > avatarViewSize.height)
        //    avatar = imageScaledToSize(avatar, avatarViewSize.width);

        CGSize avatarViewSize = CGSizeMake(48, 48);
        
        imageView.image = loadAndScaleImage([userData objectForKey:@"profile_image_url"], avatarViewSize);
        
		UILabel *label;
		//Set user name
		label = (UILabel *)[cell viewWithTag:NAME_TAG];
		label.text = [userData objectForKey:@"screen_name"];
		
		//Set real user name
		label = (UILabel *)[cell viewWithTag:REAL_NAME_TAG];
		label.text = [userData objectForKey:@"name"];
	} 
	else
	{
		cell.textLabel.text = NSLocalizedString(@"Load More...", @"");
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString *CellIdentifier = ![self noUsers] && indexPath.row < [_users count]? @"UserListCell": @"UICell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [self tableviewCellWithReuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell forIndexPath:indexPath];
	
	cell.contentView.backgroundColor = indexPath.row % 2? [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1]: [UIColor whiteColor];
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row >= [_users count]) return 50;
	
	return ROW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	if([self noUsers])
		return;
	
	if(indexPath.row < [_users count])
	{
		id userInfo = [_users objectAtIndex:indexPath.row];
        if (isNullable(userInfo))
            return;
        
        BOOL isProtected = NO;
        
        id protectedValue = [userInfo objectForKey:@"protected"];
        if (!isNullable(protectedValue))
            isProtected = [protectedValue boolValue];
        
        NSString *userScreenname = [userInfo objectForKey:@"screen_name"];
        
        NSString *currentUserScreenname = [MGTwitterEngine username];
        
        if (!isProtected || [userScreenname isEqualToString:currentUserScreenname])
        {
            UserInfo *infoView = [[UserInfo alloc] initWithUserName:[userInfo objectForKey:@"screen_name"]];
            [self.navigationController pushViewController:infoView animated:YES];
            [infoView release];
        }
        else
        {
            // Show alert view. User data protected
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"User Info", @"") 
                                                            message:NSLocalizedString(@"User data are protected!", @"") 
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
	}
}

- (void)accountChanged:(NSNotification*)notification
{
	[self reloadAll];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	//YFLog(@"%@", viewController);
}

#pragma mark MGTwitterEngineDelegate methods
- (void)requestSucceeded:(NSString *)connectionIdentifier
{
	[TweetterAppDelegate decreaseNetworkActivityIndicator];
	_loading = NO;
    //YFLog(@"Request succeeded for connectionIdentifier = %@", connectionIdentifier);
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
	[TweetterAppDelegate decreaseNetworkActivityIndicator];
	_loading = NO;
    /*YFLog(@"Request failed for connectionIdentifier = %@, error = %@ (%@)", 
          connectionIdentifier, 
          [error localizedDescription], 
          [error userInfo]);*/
	
	[self releaseActivityIndicator];
	
    if ([error code] == 401)
        [AccountController showAccountController:self.navigationController];
	//if(self.tabBarController.selectedViewController == self.navigationController && [error code] == 401)
	//	[LoginController showModal:self.navigationController];
	
	if(_users)
	{
		[_users release];
		_users = nil;
	}
	
	[self.tableView reloadData];
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier;
{
//	[TweetterAppDelegate decreaseNetworkActivityIndicator];
	if(_users)
		[_users release];
	
	_users = [userInfo retain];
	[self.tableView reloadData];
	
	[self releaseActivityIndicator];
}

#pragma mark ===
- (void)loadFollowers
{
    if ([[AccountManager manager] isValidLoggedUser])
	{
		_loading = YES;
		[self retainActivityIndicator];
	}
}

- (void)reloadAll
{
	if(_users)
	{
		[_users release];
		_users = nil;
	}
	
	[self loadFollowers];
}

- (void)retainActivityIndicator
{
	if(++_indicatorCount == 1)
	{
        [_activity.messageLabel setText:[self loadingMessagesString]];
        [_activity show];
	}
    
    if (_activity)
        [_activity.messageLabel setText:[self loadingMessagesString]];
}

- (void)releaseActivityIndicator
{
	if(_indicatorCount > 0)
	{
		if(--_indicatorCount == 0)
		{
            [_activity hide];
		}
	}
}

@end

@implementation FollowersController

- (id)initWithUser:(NSString *)username
{
    if ((self = [super initWithNibName:@"UserMessageList" bundle:nil]))
    {
        _username = [[NSString alloc] initWithString:username];
    }
    return self;
}

- (void)dealloc
{
	[_topBarItem release];
	
    if (_username)
        [_username autorelease];
    [super dealloc];
}

- (NSString*)noUsersString
{
	return NSLocalizedString(@"No Followers", @"");
}

- (NSString*)loadingMessagesString
{
	return NSLocalizedString(@"Loading the List of Followers...", @"");
}

- (void)loadFollowers
{
	[_users release];
	_users = nil;
	
	[self.tableView reloadData];
	
	[super loadFollowers];
	
    if ([[AccountManager manager] isValidLoggedUser])
	{
		[TweetterAppDelegate increaseNetworkActivityIndicator];
		if (_username)
            [_twitter getFollowersForUser:_username lite:YES];
        else
            [_twitter getFollowersIncludingCurrentStatus:YES];
	}
}

@end

@implementation FollowingController

- (id)initWithUser:(NSString *)username
{
    if ((self = [super initWithNibName:@"UserMessageList" bundle:nil]))
    {
        _username = [[NSString alloc] initWithString:username];
    }
    return self;
}

- (void)dealloc
{
    if (_username)
        [_username autorelease];
    [super dealloc];
}

- (NSString*)noUsersString
{
	return NSLocalizedString(@"No Following Users", @"");
}

- (NSString*)loadingMessagesString
{
	return NSLocalizedString(@"Loading the List of Following Users...", @"");
}

- (void)loadFollowers
{
	[_users release];
	_users = nil;
	
	[self.tableView reloadData];
	
	[super loadFollowers];
	
    if ([[AccountManager manager] isValidLoggedUser])
	{
		[TweetterAppDelegate increaseNetworkActivityIndicator];
		[_twitter getRecentlyUpdatedFriendsFor:_username startingAtPage:0];
	}
}

@end
