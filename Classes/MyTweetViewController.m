//
//  MyTweetViewController.m
//  Tweetero
//
//  Created by Sergey Shkrabak on 9/10/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import "MyTweetViewController.h"
#import "MGTwitterEngine.h"
#import "TweetterAppDelegate.h"
#import "TwitEditorController.h"

@implementation MyTweetViewController

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    UISegmentedControl *userActionButton = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"New", @"Refresh", nil]] autorelease];
    
    CGRect frame = CGRectMake(235, 7, 80, 30);
    
    [userActionButton setFrame:frame];
    [userActionButton setSegmentedControlStyle:UISegmentedControlStyleBar];
    [userActionButton setImage:[UIImage imageNamed:@"edit.tif"] forSegmentAtIndex:0];
    [userActionButton setImage:[UIImage imageNamed:@"refresh.tif"] forSegmentAtIndex:1];
    [userActionButton addTarget:self action:@selector(changeActionSegment:) forControlEvents:UIControlEventValueChanged];
    [userActionButton setMomentary:YES];
    
    _topBarItem = [[UIBarButtonItem alloc] initWithCustomView:userActionButton];	
	
	self.navigationItem.title = @"MyTweets";
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(twittsUpdatedNotificationHandler:) name:@"TwittsUpdated" object:nil];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	self.navigationItem.rightBarButtonItem = _topBarItem;		
	[self reloadAll];
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

- (void)dealloc 
{
	[_topBarItem release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)loadMessagesStaringAtPage:(int)numPage count:(int)count
{
	[super loadMessagesStaringAtPage:numPage count:count];
    if ([[AccountManager manager] isValidLoggedUser])
	{
		[TweetterAppDelegate increaseNetworkActivityIndicator];
		[_twitter getUserTimelineFor:nil since:nil startingAtPage:numPage count:count];
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

- (void)reload
{
    [self reloadAll];
}

- (void)twittsUpdatedNotificationHandler:(NSNotification*)note
{
    id object = [note object];
    
    if ([object respondsToSelector:@selector(dataSourceClass)])
    {
        Class ds_class = [object dataSourceClass];
        if (ds_class == [self class])
            [self reload];
    }
}

@end
