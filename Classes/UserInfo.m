// Copyright (c) 2009 Imageshack Corp.
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products
//    derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 

#import "UserInfo.h"
#import "MGTwitterEngine.h"
#import "ImageLoader.h"
#import "WebViewController.h"
#import "NewMessageController.h"
#import "UserMessageListController.h"
#import "TweetterAppDelegate.h"
#import "TwitEditorController.h"
#import "CustomImageView.h"
#import "FollowersController.h"
#import "MGTwitterEngineFactory.h"
#import "AccountManager.h"
#include "util.h"

static NSString* kDescriptionCell = @"UserInfoDescriptionCell";
static NSString* kDeviceCell = @"UserInfoDeviceCell";
static NSString* kActionCell = @"UserInfoActionCell";

@interface UserInfo (Private)
- (void)initTableData;
- (UITableViewCell*)createCellForIdentifier:(UITableView*)tableView reuseIdentifier:(NSString*)identifier;
- (void)enableCellAtIndex:(NSInteger)row atSection:(NSInteger)section enabled:(BOOL)enable;
@end

@implementation UserInfo

@synthesize isUserReceivingUpdatesForConnectionID;
@synthesize userInfoConnectionID;
@synthesize infoView;
@synthesize notifySwitch;
@synthesize followButton;
@synthesize followBtn;
@synthesize tableView;

- (id)initWithUserName:(NSString*)uname
{
	self = [super initWithNibName:@"UserInfo" bundle:nil];
	
	if(self)
	{
		_gotInfo = NO;
        _twitter = [[MGTwitterEngineFactory createTwitterEngineForCurrentUser:self] retain];
		_username = [uname copy];
        _following = NO;
        
        _userInfoView = [[UserInfoView alloc] init];
        _userTableSection = [[NSMutableArray alloc] init];
        _userInfoView.buttons = UserInfoButtonFollow;
        _userInfoView.delegate = self;
        _userTableImages = [[NSMutableDictionary alloc] init];
        
        [_userInfoView disableFollowingButton:YES];
        
        UserAccount *account = [[AccountManager manager] loggedUserAccount];
        if ([uname compare:[account username]] == NSOrderedSame)
            [_userInfoView hideFollowingButton:YES];
        
        [self initTableData];
	}
	
	return self;
}

- (void)dealloc 
{
    [_userTableImages release];
    [_userInfoView release];
    [_userTableSection release];
	[followersCount release];
    
	infoView.delegate = nil;
	if(infoView.loading)
	{
		[infoView stopLoading];
		[TweetterAppDelegate decreaseNetworkActivityIndicator];
	}
	int connectionsCount = [_twitter numberOfConnections];
	[_twitter closeAllConnections];
	[_twitter removeDelegate];
	[_twitter release];
	while(connectionsCount-- > 0)
		[TweetterAppDelegate decreaseNetworkActivityIndicator];
	
	[_username release];
	self.isUserReceivingUpdatesForConnectionID = nil;
    self.userInfoConnectionID = nil;
	
	[infoView release];
	infoView = nil;
	[notifySwitch release];
	notifySwitch = nil;
	[followButton release];
	followButton = nil;
	[followBtn release];
	followBtn = nil;
	[tableView release];
	tableView = nil;
    
    [super dealloc];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [_userInfoView disableFollowingButton:YES];
	//sendDirectMessage.hidden = YES;
    _isDirectMessage = NO;
    
	[TweetterAppDelegate increaseNetworkActivityIndicator];
    
    NSString *username = [[[AccountManager manager] loggedUserAccount] username];
    
	self.isUserReceivingUpdatesForConnectionID = [_twitter isUser:_username receivingUpdatesFor:username];

	[TweetterAppDelegate increaseNetworkActivityIndicator];
	
    self.userInfoConnectionID = [_twitter getUserInformationFor:_username];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self enableCellAtIndex:UActionDirectMessageIndex atSection:USAction enabled:_isDirectMessage];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)userFollowPressed
{
    [self follow];
}

#pragma mark Actions

- (IBAction)follow
{
    NSString *ident = nil;
    
    if (_following)
        ident = [_twitter disableUpdatesFor:_username]; // STOP FOLLOWING
    else
        ident = [_twitter enableUpdatesFor:_username];  // FOLLOWING
    
    [_userInfoView disableFollowingButton:YES];
	
	// responce on enable/disable request not always contains valid data
	// so we need in addition to send "get user data" request
	_shouldUpdateUserInfo = YES;
    
    if (self.userInfoConnectionID == nil)
        self.userInfoConnectionID = ident;
}

// Show user followers
- (IBAction)followers
{
    FollowersController *controller = [[FollowersController alloc] initWithUser:_username];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)sendMessage 
{
    NewMessageController *msgView = [[NewMessageController alloc] init];
	[self.navigationController pushViewController:msgView animated:YES];
	[msgView setUser:_username];
	[msgView release];
}

- (IBAction)sendReply 
{
	TwitEditorController *msgView = [[TwitEditorController alloc] init];
	[self.navigationController pushViewController:msgView animated:YES];
	[msgView setReplyToMessage:	[NSDictionary dictionaryWithObject:	[NSDictionary dictionaryWithObject:_username forKey:@"screen_name"]	
															forKey:@"user"]];
	[msgView release];
}

- (IBAction)showTwitts 
{
    UserMessageListController *msgView = [[UserMessageListController alloc] initWithUserName:_username];
	[self.navigationController pushViewController:msgView animated:YES];
	[msgView release];
}

- (IBAction)notifySwitchChanged
{
	[TweetterAppDelegate increaseNetworkActivityIndicator];
	if(notifySwitch.on)
		[_twitter enableNotificationsFor:_username];
	else
		[_twitter disableNotificationsFor:_username];
	
	[TweetterAppDelegate increaseNetworkActivityIndicator];
	[_twitter getUserInformationFor:_username];
}

#pragma mark MGTwitterEngine Delegate
- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
	[TweetterAppDelegate decreaseNetworkActivityIndicator];
	
    YFLog(@"NETWORK_FAILED: %@", connectionIdentifier);
    YFLog(@"%@", error);
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Network Failure", @"")
                                                    message: [error localizedDescription]
												   delegate: self 
                                          cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                          otherButtonTitles: nil];
	[alert show];
	[alert release];
}

- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier
{
    YFLog(@"MISC INFO RECEIVE");
	if(![self.isUserReceivingUpdatesForConnectionID isEqualToString:connectionIdentifier])
		return;

	[TweetterAppDelegate decreaseNetworkActivityIndicator];
	NSDictionary *followData = [miscInfo objectAtIndex:0];
	
	_isDirectMessage = YES;
    
	id friendsObj = [followData objectForKey:@"friends"];
	if(!isNullable(friendsObj))
		_isDirectMessage = [friendsObj boolValue];
    
    [self enableCellAtIndex:UActionDirectMessageIndex atSection:USAction enabled:_isDirectMessage];
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier;
{
    YFLog(@"USER INFO RECEIVE");
    if (![self.userInfoConnectionID isEqualToString:connectionIdentifier])
        return;
    
	[TweetterAppDelegate decreaseNetworkActivityIndicator];
	NSDictionary *userData = [userInfo objectAtIndex:0];

    CGSize avatarViewSize = CGSizeMake(48, 48);
    
    UIImage *avatar = loadAndScaleImage([userData objectForKey:@"profile_image_url"], avatarViewSize);

    // Update UserInfo header
    _userInfoView.avatar = avatar;
    _userInfoView.screenname = [userData objectForKey:@"screen_name"];
	_userInfoView.username = [userData objectForKey:@"name"];
    self.navigationItem.title = _userInfoView.screenname;
    
    _following = NO;
    id following = [userData objectForKey:@"following"];
    if (!isNullable(following))
        _following = [following boolValue];
    
    
    YFLog(@"FOLLOWING: %i", _following);
    _userInfoView.follow = _following;

    [_userInfoView disableFollowingButton:NO];
	
	[followersCount release];
	followersCount = [[userData objectForKey:@"followers_count"] retain];
    
	// Create description html
	BOOL infoEmpty = YES;
	NSString *item;
	NSMutableString* info = [NSMutableString stringWithCapacity:256];
    
	[info appendFormat:@"<html><body style=\"width:%d\">", (int)infoView.frame.size.width - 10];
	
    // Append description string
    item = [userData objectForKey:@"description"];
	if(!isNullable(item) && [item length] > 0)
	{
		infoEmpty = NO;
		[info appendString:item];
		[info appendString:@"<br>"];
	}
	
    // Append url
    item = [userData objectForKey:@"url"];
	if(!isNullable(item))
	{
		infoEmpty = NO;
		[info appendFormat:@"<a href=%@>%@</a>", item, item];
		[info appendString:@"<br>"];
	}
	
    // Append location
    item = [userData objectForKey:@"location"];
	if(!isNullable(item) && [item length] != 0)
	{
		infoEmpty = NO;
		NSScanner *scanner = [NSScanner scannerWithString:item];
		[info appendString:@"Location: "];
		
		NSString *textPart = nil;
		BOOL success = [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:(NSString **)&textPart];
		if (success && [textPart length] > 0)
		{
			// user location contains textual part
			unichar lastCharacter = [textPart characterAtIndex:[textPart length] - 1];
			if (lastCharacter == (unichar)'-')
			{
				textPart = [textPart substringToIndex:[textPart length] - 1];
				[scanner setScanLocation:[scanner scanLocation] - 1];
			}
			
			if (lastCharacter == (unichar)'(')
			{
				textPart = [textPart substringToIndex:[textPart length] - 1];
			}
		}
		else
		{
			textPart = @"";
		}

		// Update head info view
        _userInfoView.location = textPart;
		[info appendString:textPart];
		
		double x = 0.0;
		double y = 0.0;
		if(![scanner isAtEnd])
		{
			[scanner scanDouble:&x];
			success = [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&textPart];
			
			if([scanner isAtEnd])
			{
				if (!success)
					textPart = @"";
				[info appendFormat:@"%f%@", x, textPart];
			}
			else
			{
				if(success && [textPart length] > 0 && [textPart characterAtIndex:[textPart length] - 1] == (unichar)'-')
				{
					textPart = [textPart substringToIndex:[textPart length] - 1];
					[scanner setScanLocation:[scanner scanLocation] - 1];
				}
				
				[scanner scanDouble:&y];
				[info appendFormat:@"<a href=http://maps.google.com/maps?q=%f,%f>%@</a>", x, y, @"Current Location"];
				
				[info appendString:[item substringFromIndex:[scanner scanLocation]]];
				YFLog(@"INFO: %@", info);
			}
		}
		[info appendString:@"<br>"];
	}
	
    // Hide infoView if user data not founded
	if(infoEmpty)
        [info appendString:NSLocalizedString(@"User description is empty.", @"")];
    [info appendString:@"</body></html>"];
    infoView.scalesPageToFit = NO;
    [infoView loadHTMLString:info baseURL:nil];

    // Update notify switch
	if (_following)
	{
		notifySwitch.enabled = YES;
		
		id notifyOn = [userData objectForKey:@"notifications"];
		if(notifyOn && notifyOn != [NSNull null])
		{
			notifySwitch.on = [notifyOn boolValue];
		}
	}
	else
	{
		// Device Update functionality is not available. See Issue #47 for more information
		notifySwitch.on = NO;
		notifySwitch.enabled = NO;
	}
	
	_gotInfo = YES;
    self.userInfoConnectionID = nil;
	
	if (_shouldUpdateUserInfo)
	{
		_shouldUpdateUserInfo = NO;
		self.userInfoConnectionID = [_twitter getUserInformationFor:_username];
	}
	
	[tableView reloadData];
}

#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(!_gotInfo)
		[self.navigationController popViewControllerAnimated:YES];
	else
	{
		_gotInfo = NO;
		[TweetterAppDelegate increaseNetworkActivityIndicator];
		[_twitter getUserInformationFor:_username];
	}
}

#pragma mark WebView Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[TweetterAppDelegate increaseNetworkActivityIndicator];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if([[[request URL] absoluteString] isEqualToString:@"about:blank"])
		return YES;

    TweetterAppDelegate *appDel = (TweetterAppDelegate*)[[UIApplication sharedApplication] delegate];
	if (![appDel startOpenGoogleMapsRequest:request])
	{
		UIViewController *webViewCtrl = [[WebViewController alloc] initWithRequest:request];
		[self.navigationController pushViewController:webViewCtrl animated:YES];
		[webViewCtrl release];
	}
	
	return NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[TweetterAppDelegate decreaseNetworkActivityIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[TweetterAppDelegate decreaseNetworkActivityIndicator];
}

#pragma mark UITableView DataSource
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return [[_userTableSection objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdent = nil;
    
    if (indexPath.section == USDescription)
        cellIdent = kDescriptionCell;
    else if (indexPath.section == USDevice)
        cellIdent = kDeviceCell;
    else if (indexPath.section == USAction)
        cellIdent = kActionCell;
    
    UITableViewCell *cell = [self createCellForIdentifier:aTableView reuseIdentifier:cellIdent];
    
	NSString *cellTitle = [[_userTableSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	if ([cellTitle isEqualToString:NSLocalizedString(@"Followers", @"")] && nil != followersCount)
	{
		cellTitle = [NSString stringWithFormat:@"%@ (%@)",
					[[_userTableSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row], followersCount];
	}
	
    cell.textLabel.text = cellTitle;
    if (indexPath.section == USAction)
        cell.imageView.image = [UIImage imageNamed:[_userTableImages objectForKey:[NSNumber numberWithInt:indexPath.row]]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return [_userTableSection count];
}

#pragma mark UITableView Delegate
- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((indexPath.section == USDescription) ? (infoView.frame.size.height + 1) : 40);
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
    return ((section == 0) ? 60 : 0);
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    return ((section == USDescription) ? _userInfoView : nil);
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == USAction)
    {
        UITableViewCell *cell = [aTableView cellForRowAtIndexPath:indexPath];
        if (cell.selectionStyle == UITableViewCellSelectionStyleNone)
            return;
        
        switch (indexPath.row) 
        {
            // Send Direct Message
            case UActionDirectMessageIndex:
                [self sendMessage];
                break;
            // Send Public Reply
            case UActionReplyIndex:
                [self sendReply];
                break;
            // Show Recent Tweets
            case UActionRecentIndex:
                [self showTwitts];
                break;
            // Show User Followers
            case UActionFollowersIndex:
                [self followers];
                break;
            default:
                break;
        }
    }
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end

@implementation UserInfo (Private)

- (void)initTableData
{
    [_userTableSection addObject:[NSArray arrayWithObject:@""]];
    [_userTableSection addObject:[NSArray arrayWithObjects:NSLocalizedString(@"Device Updates", @""), nil]];
    [_userTableSection addObject:[NSArray arrayWithObjects:
                                                NSLocalizedString(@"Send Direct Message", @""),
                                                NSLocalizedString(@"Send Public Reply", @""),
                                                NSLocalizedString(@"Recent Tweets", @""),
                                                NSLocalizedString(@"Followers", @""),
                                                nil]];
    
    [_userTableImages setObject:@"followers.png" forKey:[NSNumber numberWithInt:UActionFollowersIndex]];
    [_userTableImages setObject:@"recent-tweets.png" forKey:[NSNumber numberWithInt:UActionRecentIndex]];
    [_userTableImages setObject:@"reply.png" forKey:[NSNumber numberWithInt:UActionReplyIndex]];
    [_userTableImages setObject:@"directmsg.png" forKey:[NSNumber numberWithInt:UActionDirectMessageIndex]];
}

- (UITableViewCell*)createCellForIdentifier:(UITableView*)aTableView reuseIdentifier:(NSString*)identifier
{
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:identifier] autorelease];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        if ([identifier isEqual:kDescriptionCell])
        {
            infoView.frame = CGRectMake(10, 0, infoView.frame.size.width, infoView.frame.size.height);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:infoView];
        }
        else if ([identifier isEqual:kDeviceCell])
        {
            notifySwitch.frame = CGRectMake(197, 6, 50, 30);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:notifySwitch];
        }
        else if ([identifier isEqual:kActionCell])
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    return cell;
}

- (void)enableCellAtIndex:(NSInteger)row atSection:(NSInteger)section enabled:(BOOL)enable
{
    NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:section];
    
    UITableViewCell *cell = [(UITableView*)self.view cellForRowAtIndexPath:index];
    if (cell)
    {
        cell.textLabel.enabled = enable;
        cell.selectionStyle = enable ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
    }
}

@end
