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

#import "HomeViewController.h"
#import "MGTwitterEngine.h"
#import "TwitEditorController.h"
#import "TweetterAppDelegate.h"

@implementation HomeViewController

- (void)dealloc 
{
    [_topBarItem release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_topBarItem != nil)
        [_topBarItem release];
    
    UISegmentedControl *userActionButton = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"New", @"Refresh", nil]] autorelease];
    
    CGRect frame = CGRectMake(235, 7, 80, 30);
    
    [userActionButton setFrame:frame];
    [userActionButton setSegmentedControlStyle:UISegmentedControlStyleBar];
    [userActionButton setImage:[UIImage imageNamed:@"edit.tif"] forSegmentAtIndex:0];
    [userActionButton setImage:[UIImage imageNamed:@"refresh.tif"] forSegmentAtIndex:1];
    [userActionButton addTarget:self action:@selector(changeActionSegment:) forControlEvents:UIControlEventValueChanged];
    [userActionButton setMomentary:YES];
    
    _topBarItem = [[UIBarButtonItem alloc] initWithCustomView:userActionButton];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(twittsUpdatedNotificationHandler:) name:@"TwittsUpdated" object:nil];
    
	if(![[AccountManager manager] isValidLoggedUser])
        [AccountController showAccountController:self.parentViewController.navigationController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.parentViewController.navigationItem.title = NSLocalizedString(@"Home",@"");
    self.parentViewController.navigationItem.rightBarButtonItem = _topBarItem;
}

- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
	
	// Refresh a table since base implementation should remove cached data
	[self.tableView reloadData];
}

- (void)twittsUpdatedNotificationHandler:(NSNotification*)note
{
    id object = [note object];
    
    YFLog(@"UPDATE_TWITS");
    if ([object respondsToSelector:@selector(dataSourceClass)])
    {
        Class ds_class = [object dataSourceClass];
        if (ds_class == [self class])
            [self reload];
    }
    else
    {
        [self reload];
    }
}

- (void)newMessage
{
	TwitEditorController *msgView = [[TwitEditorController alloc] init];
    [self.navigationController pushViewController:msgView animated:YES];
	[msgView release];
}

- (void)reload
{
	if(![[AccountManager manager] isValidLoggedUser])
        [AccountController showAccountController:self.navigationController];
	else
		[self reloadAll];
}

- (void)changeActionSegment:(id)sender
{
    UISegmentedControl *seg = (UISegmentedControl*)sender;
    
    if (seg.selectedSegmentIndex == 0)
        [self newMessage];
    else
        [self reload];
}

- (void)accountChanged:(NSNotification*)notification
{
	[self reloadAll];
    
    //UserAccount *account = [[AccountManager manager] loggedUserAccount];
	//self.parentViewController.navigationItem.title = [account username];
}

- (void)loadMessagesStaringAtPage:(int)numPage count:(int)count
{
    YFLog(@"LOAD HOME START WITH %d COUNT %d", numPage, count);
	[super loadMessagesStaringAtPage:numPage count:count];
    
    if ([[AccountManager manager] isValidLoggedUser])
	{
		[TweetterAppDelegate increaseNetworkActivityIndicator];
        
		[_twitter getFollowedTimelineFor:nil since:nil startingAtPage:numPage count:count];
	}
}

- (NSString*)noMessagesString
{
	return NSLocalizedString(@"No Tweets", @"");
}

- (NSString*)loadingMessagesString
{
	return NSLocalizedString(@"Loading Tweets...", @"");
}

@end