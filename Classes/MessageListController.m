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

#import "MessageListController.h"
#import "LoginController.h"
#import "MGTwitterEngine.h"
#import "ImageLoader.h"
#import "TweetterAppDelegate.h"
#import "CustomImageView.h"
#import "MGTwitterEngineFactory.h"
#import "util.h"
#import "TweetViewController.h"
#import "AccountManager.h"
#import "TwitterMessageObject.h"
#import "TwMessageCell.h"
#import "KBTwitterManager.h"

#define ROW_HEIGHT          70
NSString *const kTwitterErrorPrefix = @"Twitter: ";
NSString *const kTwitterSecureErrorMessage = @"Secure Connection Failed";
NSString *const kTwitterOperationErrorMessage = @"Operation Could Not Be Completed";
const NSInteger kRetriesNumber = 3;

@interface MessageListController(TwitterMessageObjectManagament)
- (void)clearMessagesCache;
- (void)initTwitterMessageObjectCache;
- (void)releaseTwitterMessageObjectCache;
- (TwitterMessageObject*)mapTwitterMessageObject:(NSDictionary*)message;
- (TwitterMessageObject*)cacheMessageObjectAsDictionary:(NSDictionary*)message;
- (TwitterMessageObject*)cacheMessageObject:(TwitterMessageObject*)message;
- (TwitterMessageObject*)lookupTwitterMessageObject:(NSDictionary*)message;
- (TwitterMessageObject*)lookupTwitterMessageObjectById:(NSString*)messageId;
- (TwitterMessageObject*)twitterMessageObjectByDictionary:(NSDictionary*)message;
@end

@interface MessageListController(ThumbnailLoader)
- (void)loadThumbnailsForMessageObject:(TwitterMessageObject*)message;
- (void)loadThumbnailsThread:(NSDictionary*)data;
@end

@implementation MessageListController

- (void)dealloc
{
    ISLog(@"DEALLOC MESSAGE_LIST_CONTROLLER");
    
    [self releaseTwitterMessageObjectCache];
	while (_indicatorCount) 
	{
		[self releaseActivityIndicator];
	}
	
	int connectionsCount = [_twitter numberOfConnections];
	[_twitter closeAllConnections];
	[_twitter removeDelegate];
	[_twitter release];
	while(connectionsCount-- > 0)
		[TweetterAppDelegate decreaseNetworkActivityIndicator];

	[_messages release];
	
    if (_yFrogImages)
        [_yFrogImages release];
	
	if(_errorDesc)
		[_errorDesc release];
	
	[super dealloc];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
    [self initTwitterMessageObjectCache];
	_errorDesc = nil;
	_lastMessage = NO;
	_loading = [[AccountManager manager] isValidLoggedUser];
	_indicatorCount = 0;
	
    _twitter = [[KBTwitterManager twitterManager] twitterEngine];
//    _twitter = [[MGTwitterEngineFactory createTwitterEngineForCurrentUser:self] retain];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountChanged:) name:@"AccountChanged" object:nil];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessful) name:kTwitterLoginNotificationKey object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusRetrieved:) name:kTwitterStatusRetrievedNotificationKey object:nil];
//    
//    if ([self.twitterEngine isAuthorized])
//	{
//		//UIAlertViewQuick(@"Cached xAuth token found!", @"This app was previously authorized for a Twitter account.", @"OK");
//		[self loginSuccessful];
//	} else {
//        //UIAlertViewQuick(@"Not logged in yet!", @"You'll need to log in.", @"OK");
//        XAuthTwitterEngineViewController *loginController = [[XAuthTwitterEngineViewController alloc] initWithNibName:@"XAuthTwitterEngineDemoViewController" bundle:nil];
//        [self presentModalViewController:loginController animated:YES];
//        [loginController release];
//    }
    
	[self performSelector:@selector(reloadAll) withObject:nil afterDelay:0.5f];
}

//- (void) loginSuccessful {
//    NSLog(@"************ LOGGED IN *************");
//    
//    [twitterEngine getFollowedTimelineSinceID:0 startingAtPage:0 count:25];
//    //    [twitterEngine getUserTimelineFor:nil sinceID:0 startingAtPage:0 count:25];
//}
//
//- (void) statusRetrieved:(NSNotification *)inNotification {
//    if (inNotification) {
//        if ([inNotification userInfo]) {
//            NSDictionary *userInfo = [inNotification userInfo];
//            if ([userInfo objectForKey:@"statuses"]) {
//                _messages = [[userInfo objectForKey:@"statuses"] retain];
//                NSLog(@"status retrieved: %@", statuses);
//                [theTableView reloadData];
//            }
//        }
//    }
//}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	
	if(!_messages)
		[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_processIndicator)
        [_processIndicator hide];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_loading && _processIndicator) {
        [_processIndicator show];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning 
{
	ISLog(@"MEMORY WARNING");
	
	[self releaseTwitterMessageObjectCache];
	[self initTwitterMessageObjectCache];
	[self clearMessagesCache];
	
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (BOOL)noMessages
{
	return !_messages || [_messages count] == 0;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [self noMessages] ? 1:
		_lastMessage? [_messages count]: [_messages count] + 1;
}

- (UITableViewCell *)tableviewCellWithReuseIdentifier:(NSString *)identifier 
{
	if([identifier isEqualToString:@"UICell"])
	{
		UITableViewCell *uiCell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:identifier] autorelease];
        UILabel *label = [uiCell textLabel];
        
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont systemFontOfSize:16];
		return uiCell;
	}
    
	if([identifier isEqualToString:@"TwittListCell"])
	{
        UITableViewCell *cell = [[[TwMessageCell alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, ROW_HEIGHT) reuseIdentifier:identifier] autorelease];
		return cell;
	}
	
	return nil;
}

- (NSString*)noMessagesString
{
	return @"";
}

- (NSString*)loadingMessagesString
{
	return @"";
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath 
{
    UILabel *cellLabel = [cell textLabel];
    
	if([self noMessages])
	{
		if(_errorDesc)
			cellLabel.text = _errorDesc;
		else
            cellLabel.text = _loading ? @"" : [self noMessagesString];
		return;
	}

	if(indexPath.row < [_messages count])
	{
        NSDictionary *messageData = [_messages objectAtIndex:indexPath.row];

        TwitterMessageObject *object = [self twitterMessageObjectByDictionary:messageData];
        [((TwMessageCell*)cell) setTwitterMessageObject:object];
    }
	else
	{
        cellLabel.text = NSLocalizedString(@"Load More...", @"");
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString *CellIdentifier = ![self noMessages] && indexPath.row < [_messages count]? @"TwittListCell": @"UICell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [self tableviewCellWithReuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell forIndexPath:indexPath];
	
	cell.contentView.backgroundColor = indexPath.row % 2 ? [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1]: [UIColor whiteColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row >= [_messages count]) return 50;
	
	UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
	return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	if([self noMessages])
		return;
		
	if(indexPath.row < [_messages count])
	{
		NSMutableDictionary *messageData = [NSMutableDictionary dictionaryWithDictionary:[_messages objectAtIndex:indexPath.row]];
		id userInfo = [messageData objectForKey:@"sender"];
		if(userInfo && [messageData objectForKey:@"user"] == nil)
		{
			[messageData setObject:userInfo forKey:@"user"];
			[messageData setObject:[NSNumber numberWithBool:YES] forKey:@"DirectMessage"];
		}
        
        TweetViewController *tweetView = [[TweetViewController alloc] initWithStore:self messageIndex:indexPath.row];
        [tweetView setDataSourceClass:[self class]];
        [self.navigationController pushViewController:tweetView animated:YES];
        [tweetView release];
	}
	else
	{
		[self loadMessagesStaringAtPage:++_pagenum count:MESSAGES_PER_PAGE];
	}
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark TweetViewDelegate
- (int)messageCount
{
    return [_messages count];
}

- (NSDictionary *)messageData:(int)index
{
    NSMutableDictionary *messageData = [NSMutableDictionary dictionaryWithDictionary:[_messages objectAtIndex:index]];
    
    id userInfo = [messageData objectForKey:@"sender"];
    if(userInfo && [messageData objectForKey:@"user"] == nil)
    {
        [messageData setObject:userInfo forKey:@"user"];
        [messageData setObject:[NSNumber numberWithBool:YES] forKey:@"DirectMessage"];
    }
    
    return messageData;
}

- (void)accountChanged:(NSNotification*)notification
{
	[self reloadAll];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}

#pragma mark MGTwitterEngineDelegate methods
- (void)requestSucceeded:(NSString *)connectionIdentifier
{
    ISLog(@"Success");
	[TweetterAppDelegate decreaseNetworkActivityIndicator];
	_loading = NO;
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
    ISLog(@"Failed");
		
	if(self.navigationItem.leftBarButtonItem)
			self.navigationItem.leftBarButtonItem.enabled = YES;
	[TweetterAppDelegate decreaseNetworkActivityIndicator];
	_loading = NO;
	_errorDesc = [[[error localizedDescription] capitalizedString] retain];
	
	[self releaseActivityIndicator];
	
    if ([error code] == 401)
        [AccountController showAccountController:self.navigationController];
		
	if(_messages)
	{
		[_messages release];
		_messages = nil;
	}
	
	NSString *errorMessage = [[error localizedDescription] capitalizedString];
	if ([errorMessage rangeOfString:kTwitterSecureErrorMessage options:NSCaseInsensitiveSearch].location != NSNotFound ||
				[errorMessage rangeOfString:kTwitterOperationErrorMessage options:NSCaseInsensitiveSearch].location != NSNotFound)
	{
		_errorDesc = [[NSString stringWithFormat:@"%@%@", kTwitterErrorPrefix, [[error localizedDescription] capitalizedString]] retain];
		
		if (retryCounter < kRetriesNumber)
		{
			retryCounter++;
			[self performSelector:@selector(reloadAll) withObject:nil afterDelay:0.5f];
			return;
		}
	}
	    
	retryCounter = 0;
	[self.tableView reloadData];
}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier
{
    ISLog(@"Receive status");
    YFLog(@"%@", statuses);
    /*
	if([statuses count] < MESSAGES_PER_PAGE)
	{
		_lastMessage = YES;
		if(_messages)
			[self.tableView deleteRowsAtIndexPaths:
					[NSArray arrayWithObject: [NSIndexPath indexPathForRow:[_messages count] inSection:0]]
				withRowAnimation:UITableViewRowAnimationTop];
	}
	*/
    
	if(!_messages)
	{
		if([statuses count] > 0)
            _messages = [statuses retain];
        
		[self.tableView reloadData];
	}
	else
	{
		NSArray *messages = _messages;
        
		_messages = [[messages arrayByAddingObjectsFromArray:statuses] retain];
        
		NSMutableArray *indices = [NSMutableArray arrayWithCapacity:[statuses count]];
		for(int i = [messages count]; i < [_messages count]; ++i)
			[indices addObject:[NSIndexPath indexPathForRow:i inSection:0]];
			
		@try
		{
			[self.tableView insertRowsAtIndexPaths:indices withRowAnimation:UITableViewRowAnimationTop];
		}
		@catch (NSException * e) 
		{
			YFLog(@"Tweet List Error!!!\nNumber of rows: %d\n_messages: %@\nstatuses: %@\nIndices: %@\n",
				[self tableView:self.tableView numberOfRowsInSection:0],
				_messages, statuses, indices);
		}
		
		[messages release];
	}
    
	[self releaseActivityIndicator];
	
	if(self.navigationItem.leftBarButtonItem)
		self.navigationItem.leftBarButtonItem.enabled = YES;
}

NSInteger dateReverseSort(id num1, id num2, void *context)
{
	NSDate *d1 = [num1 objectForKey:@"created_at"];
	NSDate *d2 = [num2 objectForKey:@"created_at"];
	return [d2 compare:d1];
}

- (void)directMessagesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier;
{
    ISLog(@"Receive Direct message");
    /*
	if([statuses count] < MESSAGES_PER_PAGE)
	{
		_lastMessage = YES;
		if(_messages && [_messages count] > 0 && [self.tableView numberOfRowsInSection:0] > [_messages count])
			[self.tableView deleteRowsAtIndexPaths:
					[NSArray arrayWithObject: [NSIndexPath indexPathForRow:[_messages count] inSection:0]]
				withRowAnimation:UITableViewRowAnimationTop];
	}
	*/
	if(!_messages)
	{
		if([statuses count] > 0)
			_messages = [statuses retain];
		[self.tableView reloadData];
	}
	else
	{
		NSArray *messages = _messages;
		
		[statuses setValue:[NSNumber numberWithBool:YES] forKey:@"NewItem"];
		_messages = [[[messages arrayByAddingObjectsFromArray:statuses] sortedArrayUsingFunction:dateReverseSort context:nil] retain];
		NSMutableArray *indices = [NSMutableArray arrayWithCapacity:[statuses count]];
		for(int i = 0; i < [_messages count]; ++i)
		{
			if([[_messages objectAtIndex:i] valueForKey:@"NewItem"])
			{
				[indices addObject:[NSIndexPath indexPathForRow:i inSection:0]];
			}
		}
		
		@try 
		{
			[self.tableView insertRowsAtIndexPaths:indices withRowAnimation:UITableViewRowAnimationTop];
		}
		@catch (NSException * e) 
		{
			YFLog(@"Direct Messages Error!!!\nNumber of rows: %d\n_messages: %@\nstatuses: %@\nIndices: %@\n",
				[self tableView:self.tableView numberOfRowsInSection:0],
				_messages, statuses, indices);
		}
		@finally 
		{
			[_messages setValue:nil forKey:@"NewItem"];
		}
		
		[messages release];
	}
    
	[self releaseActivityIndicator];
	
	if(self.navigationItem.leftBarButtonItem)
		self.navigationItem.leftBarButtonItem.enabled = YES;
}

#pragma mark ===
- (void)loadMessagesStaringAtPage:(int)numPage count:(int)count
{
    ISLog(@"Start load message");

    if ([[AccountManager manager] isValidLoggedUser])
	{
		if(_errorDesc)
		{
			[_errorDesc release];
			_errorDesc = nil;
		}
		_loading = YES;
		[self retainActivityIndicator];
		if(self.navigationItem.leftBarButtonItem)
			self.navigationItem.leftBarButtonItem.enabled = NO;
		if([self noMessages])
			[self.tableView reloadData];
	}
}

- (void)reloadAll
{
    ISLog(@"Reload data");
    
	_lastMessage = NO;
	_pagenum = 1;

    [self clearMessagesCache];
	
	[self loadMessagesStaringAtPage:_pagenum count:MESSAGES_PER_PAGE];
}

- (void)retainActivityIndicator
{
    _indicatorCount++;
    
    if (_processIndicator == nil)
        _processIndicator = [[TwActivityIndicator alloc] init];
    
    [_processIndicator.messageLabel setText:[self loadingMessagesString]];
    
    if ([self.navigationController.topViewController class] == NSClassFromString(@"TwTabController") ||
        [self.navigationController.topViewController class] == [self class])
    {
        if (_indicatorCount == 1)
        {
            [_processIndicator show];
        }
    }
    else
    {
        [_processIndicator hide];
    }
}

- (void)releaseActivityIndicator
{
	if(_indicatorCount > 0)
	{
		if(--_indicatorCount == 0)
		{
            if (_processIndicator)
                [_processIndicator hide];
		}
	}
}

@end

@implementation MessageListController(TwitterMessageObjectManagament)

- (void)clearMessagesCache
{
	if(_messages)
	{
		[_messages release];
		_messages = nil;
	}	
}

- (void)initTwitterMessageObjectCache
{
    if (_messageObjects == nil)
        _messageObjects = [[NSMutableDictionary alloc] init];
}

- (void)releaseTwitterMessageObjectCache
{
    [_messageObjects release];
	_messageObjects = nil;
}

- (TwitterMessageObject*)mapTwitterMessageObject:(NSDictionary*)message
{
    NSDictionary *userData = [message objectForKey:@"user"];
    if (!userData)
        userData = [message objectForKey:@"sender"];

    CGSize avatarViewSize = CGSizeMake(48, 48);
    TwitterMessageObject *messageObject = [[TwitterMessageObject alloc] init];
    
    NSString *text = [message objectForKey:@"text"];
    
    messageObject.messageId             = [[message objectForKey:@"id"] stringValue];
    messageObject.screenname            = [userData objectForKey:@"screen_name"];
    messageObject.message               = DecodeEntities(text);
    messageObject.creationDate          = [message objectForKey:@"created_at"];
    messageObject.creationFormattedDate = FormatNSDate(messageObject.creationDate);
    messageObject.avatarUrl             = [userData objectForKey:@"profile_image_url"];
    messageObject.avatar                = loadAndScaleImage(messageObject.avatarUrl, avatarViewSize);
    messageObject.yfrogLinks            = yFrogLinksArrayFromText(text);
    
    BOOL isFavorite = NO;
    
    id fav = [message objectForKey:@"favorited"];
    if (fav && fav != (id)[NSNull null])
        isFavorite = [fav boolValue];
    
    messageObject.isFavorite = isFavorite;
    
    [self loadThumbnailsForMessageObject:messageObject];
    
    return [messageObject autorelease];
}

- (TwitterMessageObject*)cacheMessageObjectAsDictionary:(NSDictionary*)message
{
    if (_messageObjects == nil)
        return nil;
    
    TwitterMessageObject *object = [self lookupTwitterMessageObject:message];
    if (object == nil)
    {
        object = [self mapTwitterMessageObject:message];
        if (object)
            [_messageObjects setObject:object forKey:object.messageId];
    }
    return object;
}

- (TwitterMessageObject*)cacheMessageObject:(TwitterMessageObject*)message
{
    if (_messageObjects == nil)
        return nil;
    if ([self lookupTwitterMessageObjectById:message.messageId] == nil)
    {
        [_messageObjects setObject:message forKey:message.messageId];
    }
    return message;
}

- (TwitterMessageObject*)lookupTwitterMessageObject:(NSDictionary*)message
{
    if (message == nil)
        return nil;
    
    return [self lookupTwitterMessageObjectById:[[message objectForKey:@"id"] stringValue]];
}

- (TwitterMessageObject*)lookupTwitterMessageObjectById:(NSString*)messageId
{
    if (_messageObjects == nil || messageId == nil)
        return nil;
    
    return [_messageObjects objectForKey:messageId];
}

- (TwitterMessageObject*)twitterMessageObjectByDictionary:(NSDictionary*)message
{
    TwitterMessageObject *object = [self lookupTwitterMessageObject:message];
    if (object == nil)
        object = [self cacheMessageObjectAsDictionary:message];
    
    BOOL isFavorite = NO;
    
    id fav = [message objectForKey:@"favorited"];
    if (fav && fav != (id)[NSNull null])
        isFavorite = [fav boolValue];
    
    object.isFavorite = isFavorite;
    
    return object;
}

@end

@implementation MessageListController(ThumbnailLoader)
- (void)loadThumbnailsForMessageObject:(TwitterMessageObject*)message
{
    if (message.yfrogLinks)
    {
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        
        NSString *copyId = [message.messageId copy];
        [data setObject:copyId forKey:@"id"];
        [data setObject:message.yfrogLinks forKey:@"links"];
        
        [self performSelectorInBackground:@selector(loadThumbnailsThread:) withObject:data];
        [copyId release];
    }
}

- (void)loadThumbnailsThread:(NSDictionary*)data
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *messageId = [data objectForKey:@"id"];
    NSArray *links = [data objectForKey:@"links"];
    
    CGSize thumbSize = CGSizeMake(kImageGridThumbnailWidth, kImageGridThumbnailHeight);
    
    NSMutableArray *images = [NSMutableArray array]; //[[NSMutableArray alloc] init];

    for (NSString *link in links)
    {
        if (link)
        {
            @try 
            {
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:link]];
                if (!imageData)
                    continue;
                
                UIImage *image = [UIImage imageWithData:imageData];
                
                if (image)
                {
                    if(image.size.width > thumbSize.width || image.size.height > thumbSize.height)
                        image = imageScaledToSizeThreadSafe(image, thumbSize.width);
                    
                    [images addObject:image];
                }
            }
            @catch (...) {
            }
        }
    }
    
    NSMutableDictionary *resultData = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [resultData setObject:messageId forKey:@"id"];
    [resultData setObject:images forKey:@"images"];
    
    [self performSelectorOnMainThread:@selector(thumbnailWasLoaded:) withObject:resultData waitUntilDone:NO];
    
    [pool release];
}

- (void)thumbnailWasLoaded:(NSDictionary*)result
{
    if (result)
    {
        NSArray *images = [result objectForKey:@"images"];
        NSString *messageId = [result objectForKey:@"id"];
        
        if (messageId && images)
        {
            TwitterMessageObject *object = [self lookupTwitterMessageObjectById:messageId];

            if (object)
                object.yfrogThumbnails = images;
            //[images release];
        }
        [result release];
        
        [self.tableView reloadData];
    }
}

@end
