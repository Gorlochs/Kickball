//
//  TweetViewController.m
//  Tweetero
//
//  Created by Sergey Shkrabak on 9/12/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import "TweetViewController.h"
#import "ImageLoader.h"
#import "TwitEditorController.h"
#import "NewMessageController.h"
#import "WebViewController.h"
#import "ImageViewController.h"
#import "UserInfo.h"
#import "TweetterAppDelegate.h"
#import "CustomImageView.h"
#import "UserInfoView.h"
#include "util.h"
#import "LoginController.h"
#import "MGTwitterEngine.h"
#import <MediaPlayer/MediaPlayer.h>
#import "TweetPlayer.h"
#import "MGTwitterEngineFactory.h"

/*
    - forward for all
 
    Direct Messages
        for All:
        - delete
        - reply
 
    Home & Mentions
        for owner:
        - delete
        - favorite
        
        for guests
        - reply
        - favorite
 */
@interface TweetViewController (Private)
- (void)createHeadView;
- (void)createFooterView;
- (void)updateViewTitle;
- (void)activeCurrentMessage;
- (void)updateSegmentButtonState;
- (UITableViewCell*)createCellWithSection:(UITableView*)tableView sectionIndex:(int)section forIndex:(NSInteger)index;
- (NSString*)formatDate:(NSDate*)date;
- (void)implementOperationIfPossible;
- (void)copyImagesToYFrog;
- (NSString*)makeHTMLMessage;
- (void)updateFavoriteIcon;
- (void)enableFavoriteButton:(BOOL)enable;
- (void)updateActionState;
@end

@implementation TweetViewController (Private)

- (void)createHeadView
{
    _headView = [[UserInfoView alloc] init];
    _headView.delegate = self;
    _headView.buttons = UserInfoButtonDetail;
}

- (void)createFooterView
{
    if (_footerView)
        [_footerView release];
    _footerView = [[UIView alloc] init];
    
    UILabel *infoLabel = [[[UILabel alloc] init] autorelease];
    infoLabel.frame = CGRectMake(15, 0, 200, 40);
    infoLabel.numberOfLines = 2;
    infoLabel.tag = 1;
    infoLabel.font = [UIFont systemFontOfSize:13.];
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.textColor = [UIColor grayColor];
    [_footerView addSubview:infoLabel];
}

- (void)updateViewTitle
{
    self.title = [NSString stringWithFormat:NSLocalizedString(@"%i of %i", @""), _currentMessageIndex + 1, _count];
}

- (void)activeCurrentMessage
{
    if (_store)
    {
        if (_message)
            [_message release];
        
        _message = [[_store messageData:_currentMessageIndex] retain];
        
        YFLog(@"CURRENT INDEX: %i", _currentMessageIndex);
        YFLog(@"%@", _message);
        
        if (_imagesLinks)
            [_imagesLinks release];
        if (_connectionsDelegates)
            [_connectionsDelegates release];
        
        _imagesLinks = [[NSMutableDictionary alloc] initWithCapacity:1];
		_connectionsDelegates = [[NSMutableArray alloc] initWithCapacity:1];
        [_webView loadHTMLString:[self makeHTMLMessage] baseURL:nil];
        
        // Check for direct message
        NSNumber *isDirectMessage = [_message objectForKey:@"DirectMessage"];
		_isDirectMessage = isDirectMessage && [isDirectMessage boolValue];
        
        // Update user data
        NSDictionary *userData = [_message objectForKey:@"user"];
        
        CGSize avatarViewSize = CGSizeMake(48, 48);
        
        UIImage *avatarImage = loadAndScaleImage([userData objectForKey:@"profile_image_url"], avatarViewSize);
        
        NSString *screenname = [userData objectForKey:@"screen_name"];
        
        _isCurrentUserMessage = [TweetterAppDelegate isCurrentUserName:screenname];
        
        _headView.avatar = avatarImage;
        _headView.username = [userData objectForKey:@"name"];
        _headView.screenname = [NSString stringWithFormat:@"@%@", [screenname lowercaseString]];
        _headView.location = [userData objectForKey:@"location"];
        
        if (_footerView)
            [(UILabel*)[_footerView viewWithTag:1] setText:nil];
        
        // Reload content table
        [contentTable reloadData];
        
        isFavorited = NO;
        id favObj = [_message objectForKey:@"favorited"];
        if (favObj)
            isFavorited = [favObj boolValue];
        
        [self updateFavoriteIcon];
        [self updateActionState];
    }
}

- (void)updateSegmentButtonState
{
    [tweetNavigate setEnabled:(_currentMessageIndex != 0) forSegmentAtIndex:kPrevTwitSegmentIndex];
    [tweetNavigate setEnabled:(_currentMessageIndex != (_count - 1)) forSegmentAtIndex:kNextTwitSegmentIndex];
}

- (UITableViewCell*)createCellWithSection:(UITableView*)tableView sectionIndex:(int)section forIndex:(NSInteger)index;
{
    static NSString *MessageCellIdentifier = @"TweetViewMessageCell";
    static NSString *ActionCellIdentifier = @"TweetViewActionCell";
    
    NSString *cellIdent = (section == kMessageTableSection ? MessageCellIdentifier : ActionCellIdentifier);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    
    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellIdent] autorelease];
        
        if (section == kMessageTableSection)
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;            
            [cell.contentView addSubview:_webView];
        }
        else if (section == kActionTableSection)
        {
            CGRect frame = [cell frame];
            
            frame.size.width -= 20;
            _actionSegment.frame = frame;
            [cell.contentView addSubview:_actionSegment];
        }
    }
    
    if (section == kMessageTableSection)
    {
        // Create label for date
        NSDate *theDate = [_message objectForKey:@"created_at"];
        NSString *msgSource = [_message objectForKey:@"source"];
        
        if (!isNullable(theDate) && !isNullable(msgSource))
        {
            NSString *formatedDate = [self formatDate:theDate];
            NSString *link = getLinkWithTag(msgSource);
            if (link)
                msgSource = link;
            
            if (_footerView)
            {
                UILabel *infoLabel = (UILabel*)[_footerView viewWithTag:1];
                infoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@\nfrom %@", @""), formatedDate, msgSource];
            }
        }
    }
    
    return cell;
}

- (NSString*)formatDate:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    
	NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *nowComponents = [calendar components:unitFlags fromDate:[NSDate date]];
	NSDateComponents *yesterdayComponents = [calendar components:unitFlags fromDate:[NSDate dateWithTimeIntervalSinceNow:-60*60*24]];
	NSDateComponents *createdAtComponents = [calendar components:unitFlags fromDate:date];
	NSString *formatedDate = nil;
    
	if([nowComponents year] == [createdAtComponents year] &&
       [nowComponents month] == [createdAtComponents month] &&
       [nowComponents day] == [createdAtComponents day])
	{
		[dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		formatedDate = [dateFormatter stringFromDate:date];
	}
	else if([yesterdayComponents year] == [createdAtComponents year] &&
            [yesterdayComponents month] == [createdAtComponents month] &&
            [yesterdayComponents day] == [createdAtComponents day])
	{
		[dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		formatedDate = [NSString stringWithFormat:@"Yesterday, %@", [dateFormatter stringFromDate:date]];
	}
	else
	{
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		formatedDate = [dateFormatter stringFromDate:date];
	}
    return formatedDate;
}

- (void)implementOperationIfPossible
{
	if([_connectionsDelegates count])
		return;
	if(_suspendedOperation == TVNoMVOperations)
		return;
    
    
	if(self._progressSheet)
	{
		[self._progressSheet dismissWithClickedButtonIndex:0 animated:YES];
		self._progressSheet = nil;
	}
	
	NSString* body = nil;
	if(_suspendedOperation == TVForward || _suspendedOperation == TVRetwit)
	{
		body = [_message objectForKey:@"text"];
        if (!isNullable(body))
        {
            NSEnumerator *en = [[_imagesLinks allKeys] objectEnumerator];
            NSString *link;
            NSString* yFrogLink = nil;
            while(link = [en nextObject])
                if((yFrogLink = [_imagesLinks objectForKey:link]) && ![yFrogLink isEqual:[NSNull null]])
                    body = [body stringByReplacingOccurrencesOfString:link withString:yFrogLink];
        }
	}
	
	if(_suspendedOperation == TVForward)
	{
        NSString *subject = NSLocalizedString(@"Mail Subject: Forwarding of a twit", @"");

        Class mailClass = NSClassFromString(@"MFMailComposeViewController");
        if ([mailClass canSendMail])
        {
            MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
            NSString *mailBody = [NSString stringWithFormat:@"<%@>", body];
            
            mail.mailComposeDelegate = self;
            [mail setMessageBody:mailBody isHTML:NO];
            [mail setSubject:subject];
            
            [self presentModalViewController:mail animated:YES];
            [mail release];
        }
        else
        {
            BOOL success = NO;
            
            NSString *mailto = [NSString stringWithFormat:@"mailto:?&subject=%@&body=%%26lt%%3B%@%%26gt%%3B", 
                                                [subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], 
                                                [body stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
            
            success = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailto]];
            if(!success)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Failed!", @"") 
                                                                message: NSLocalizedString(@"Failed to send a mail.", @"")
                                                               delegate: nil 
                                                      cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                                      otherButtonTitles: nil];
                [alert show];	
                [alert release];
            }
		}
	}	
	else if(_suspendedOperation == TVRetwit)
	{
		TwitEditorController *msgView = [[TwitEditorController alloc] init];
		[self.navigationController pushViewController:msgView animated:YES];
		[msgView setRetwit:body whose:[[_message objectForKey:@"user"] objectForKey:@"screen_name"]];
		[msgView release];
	}
	_suspendedOperation = TVNoMVOperations;
}

- (void)copyImagesToYFrog
{
	NSEnumerator *enumerator = [_imagesLinks keyEnumerator];
	id obj;
	BOOL canOperate = YES;
	while (obj = [enumerator nextObject]) 
	{
		if([_imagesLinks objectForKey:obj] == [NSNull null])
		{
			canOperate = NO;
			ImageDownoader * downloader = [[ImageDownoader alloc] init];
			[_connectionsDelegates addObject:downloader];
			[downloader getImageFromURL:obj imageType:nonYFrog delegate:self];
			[downloader release];
		}
	}
	if(canOperate)
		[self implementOperationIfPossible];
	else
		self._progressSheet = ShowActionSheet(NSLocalizedString(@"Copying images to yFrog server...", @""), self, NSLocalizedString(@"Cancel", @""), self.view);
}

- (NSString*)makeHTMLMessage
{
	NSString *text = [_message objectForKey:@"text"];
	
    if (isNullable(text))
        return nil;
    
	NSArray *lines = [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	NSString *line;
	NSInteger theWebViewWidth = (int)_webView.frame.size.width - 10;
	_newLineCounter = [lines count];
	NSMutableArray *filteredLines = [[NSMutableArray alloc] initWithCapacity:_newLineCounter];
	NSEnumerator *en = [lines objectEnumerator];
	while(line = [en nextObject])
	{
		NSArray *words = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		NSEnumerator *en = [words objectEnumerator];
		NSString *word;
		NSMutableArray *filteredWords = [[NSMutableArray alloc] initWithCapacity:[words count]];
		while(word = [en nextObject])
		{
			if([word hasPrefix:@"http://"] || [word hasPrefix:@"https://"] || [word hasPrefix:@"www."])
			{
				if([word hasPrefix:@"www."])
					word = [@"http://" stringByAppendingString:word];
                
				NSString *yFrogURL = ValidateYFrogLink(word);
                
				if(yFrogURL == nil)
				{
					if([word hasSuffix:@".jpg"] ||
                       [word hasSuffix:@".bmp"] ||
                       [word hasSuffix:@".jpeg"] ||
                       [word hasSuffix:@".tif"] ||
                       [word hasSuffix:@".tiff"] ||
                       [word hasSuffix:@".png"] ||
                       [word hasSuffix:@".gif"]
                       )
					{
						[_imagesLinks setObject:[NSNull null] forKey:word];
					}
					word = [NSString  stringWithFormat:@" <a href=%@>%@</a> ", word, word];
				}
				else
				{
					[_imagesLinks setObject:word forKey:word];
                    if (isVideoLink(yFrogURL))
                    {
                        NSString *videoSrc = [yFrogURL stringByAppendingString:@":iphone"];
                        word = [NSString stringWithFormat:@"<br><video poster=\"%@.th.jpg\" src=\"%@\" width=\"%d\"></video>", yFrogURL, videoSrc, theWebViewWidth];
                    }
                    else
                    {
                        word = [NSString  stringWithFormat:@"<br><a href=%@><img src=%@.th.jpg></a><br>", yFrogURL, yFrogURL];
                    }
					_newLineCounter += 6;
				}
			}
			else if([word hasPrefix:@"@"] && [word length] > 1)
			{
				word = [NSString  stringWithFormat:@" <a href=user://%@>%@</a> ", [word substringFromIndex:1], word];
			}
			
			[filteredWords addObject:word];
		}
		
		[filteredLines addObject:[filteredWords componentsJoinedByString:@" "]];
		[filteredWords release];
	}
	
	NSString *htmlTemplate = @"<html><body style=\"width:%d; overflow:visible; padding:0; margin:0\"><big>%@</big></body></html>";
	NSString *html = [NSString stringWithFormat:htmlTemplate, theWebViewWidth, [filteredLines componentsJoinedByString:@"<br>"]];
	[filteredLines release];
	return html;
}

- (void)updateFavoriteIcon
{
    UIImage *icon = (isFavorited ? [UIImage imageNamed:@"unfavorite.png"] : [UIImage imageNamed:@"favorite.png"]);
    if (icon && _actionSegment)
        [_actionSegment setImage:icon forSegmentAtIndex:1];
}

- (void)enableFavoriteButton:(BOOL)enable
{
    [_actionSegment setEnabled:enable forSegmentAtIndex:1];
}

- (void)updateActionState
{
    if (_isDirectMessage)
    {
        [_actionSegment setEnabled:YES forSegmentAtIndex:0]; // Reply
        [_actionSegment setEnabled:NO forSegmentAtIndex:1];  // Favorite
        [_actionSegment setEnabled:YES forSegmentAtIndex:2]; // Forward (send via email)
        [_actionSegment setEnabled:YES forSegmentAtIndex:3]; // Delete
    }
    else
    {
        [_actionSegment setEnabled:!_isCurrentUserMessage forSegmentAtIndex:0]; // Reply
        [_actionSegment setEnabled:YES forSegmentAtIndex:1];  // Favorite
        [_actionSegment setEnabled:YES forSegmentAtIndex:2]; // Forward (send via email)
        [_actionSegment setEnabled:_isCurrentUserMessage forSegmentAtIndex:3]; // Delete
    }
}

@end

@implementation TweetViewController

@synthesize _progressSheet;
@synthesize connectionIdentifier = _connectionIdentifier;
@synthesize dataSourceClass = _dataSourceClass;

@synthesize tweetNavigate;
@synthesize _actionSegment;
@synthesize contentTable;

- (id)initWithStore:(id <TweetViewDelegate>)store messageIndex:(int)index
{
    if (self = [super initWithNibName:@"TweetView" bundle:nil])
    {
        _store = [(id)store retain];
        _headView = nil;
        _count = [_store messageCount];
        _currentMessageIndex = (index >= _count || index < 0) ? 0 : index;
        //_twitter = [[MGTwitterEngine alloc] initWithDelegate:self];
        _twitter = [[MGTwitterEngineFactory createTwitterEngineForCurrentUser:self] retain];
        _defaultTintColor = [tweetNavigate.tintColor retain];
		_imagesLinks = nil;
		_connectionsDelegates = nil;
		_suspendedOperation =  TVNoMVOperations;
		
        _webView = [[UIWebView alloc] init];
		_webView.frame = CGRectMake(10, 5, 280, 235);
		_webView.backgroundColor = [UIColor clearColor];
		_webView.scalesPageToFit = NO;		
        _webView.delegate = self;
        
        [_twitter setUsesSecureConnection:NO];
        [self createHeadView];
        [self createFooterView];
        [self activeCurrentMessage];
    }
    return self;    
}

- (id)initWithStore:(id <TweetViewDelegate>)store
{
    return [self initWithStore:store messageIndex:0];
}

- (void)dealloc
{
    YFLog(@"DEALLOC TweetViewController");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.connectionIdentifier = nil;
    _webView.delegate = nil;
    if (_webView.loading)
    {
        [_webView stopLoading];
        [TweetterAppDelegate decreaseNetworkActivityIndicator];
    }
	
	[_webView release];
    
	int connectionsCount = [_twitter numberOfConnections];
	[_twitter closeAllConnections];
	[_twitter removeDelegate];
	[_twitter release];
	while (connectionsCount-- > 0)
		[TweetterAppDelegate decreaseNetworkActivityIndicator];
    
    [_defaultTintColor release];
    if (_headView)
        [_headView release];
    if (_footerView)
        [_footerView release];
    [(id)_store release];
    [_message release];
    if (_imagesLinks)
        [_imagesLinks release];
    if (_connectionsDelegates)
        [_connectionsDelegates release];
	
	[tweetNavigate release];
	tweetNavigate = nil;
	[_actionSegment release];
	_actionSegment = nil;
	[contentTable release];
	contentTable = nil;
	
    [super dealloc];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    /*
	for (id view in _webView.subviews) 
	{
		if ([view respondsToSelector:@selector(setAllowsRubberBanding:)]) 
			[view performSelector:@selector(setAllowsRubberBanding:) withObject:NO]; 
	}
    */
    tweetNavigate.frame = CGRectMake(0, 0, 80, 30);
    UIBarButtonItem *navigateBarItem = [[[UIBarButtonItem alloc] initWithCustomView:tweetNavigate] autorelease];
    self.navigationItem.rightBarButtonItem = navigateBarItem;
    
    [self updateViewTitle];
    [self updateSegmentButtonState];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController.view setNeedsLayout];
    TweetterAppDelegate *app = (TweetterAppDelegate*)[UIApplication sharedApplication].delegate;
    YFLog(@"TweetViewController: app.window.frame: %@", NSStringFromCGRect(app.window.frame));
    YFLog(@"TweetViewController: self.view.frame: %@", NSStringFromCGRect(self.view.frame));
    [self.view.superview setFrame:CGRectMake(0, 64, 320, 416)];
    [self.view.superview setNeedsLayout];
    [self.navigationController.view setNeedsLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (self.navigationController.navigationBar.barStyle == UIBarStyleBlackTranslucent ||
        self.navigationController.navigationBar.barStyle == UIBarStyleBlackOpaque) 
    {
		tweetNavigate.tintColor = [UIColor darkGrayColor];
    }
	else
    {
		tweetNavigate.tintColor = _defaultTintColor;
    }
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self updateFavoriteIcon];
    [self updateActionState];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Actions
// UISegmentControl action. Navigate for tweet messages.
- (IBAction)tweetNavigate:(id)sender
{
    int index = [sender selectedSegmentIndex];
    
    switch (index)
    {
        // Press up button. Move to previouse message.
        case kPrevTwitSegmentIndex:
            if (_currentMessageIndex > 0)
                _currentMessageIndex--;
            break;
            
        // Press down button. Move to next message.
        case kNextTwitSegmentIndex:
            if (_currentMessageIndex < (_count - 1))
                _currentMessageIndex++;
            break;
    }
    [self activeCurrentMessage];
    [self updateViewTitle];
    [self updateSegmentButtonState];
}

- (IBAction)actionSegmentClick:(id)sender
{
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    
    switch (segment.selectedSegmentIndex)
    {
        case kReplySegmentIndex:
            [self replyTwit];
            break;
        case kFavoriteSegmentIndex:
            if (!_isDirectMessage)
                [self favoriteTwit];
            break;
        case kForwardSegmentIndex:
            [self forwardTwit];
            break;
        case kDeleteSegmentIndex:
            [self deleteTwit];
            break;
    }    
}

- (IBAction)replyTwit
{
	if (_isDirectMessage)
	{
		NewMessageController *msgView = [[NewMessageController alloc] init];
		[self.navigationController pushViewController:msgView animated:YES];
		[msgView setUser:[[_message objectForKey:@"sender"] objectForKey:@"screen_name"]];
		[msgView release];
	}
	else
	{
		TwitEditorController *msgView = [[TwitEditorController alloc] init];
		[self.navigationController pushViewController:msgView animated:YES];
		[msgView setReplyToMessage:_message];
		[msgView release];
	}
}

- (IBAction)favoriteTwit
{
    NSNumber *num = [_message objectForKey:@"id"];
    
    [TweetterAppDelegate increaseNetworkActivityIndicator];
    self.connectionIdentifier = [_twitter markUpdate:[num stringValue] asFavorite:!isFavorited];
    [self enableFavoriteButton:NO];
}

- (IBAction)forwardTwit
{
    _suspendedOperation = TVForward;
    [self copyImagesToYFrog];
}

- (IBAction)deleteTwit
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Do you wish to delete this tweet?", @"") 
                                                    message: NSLocalizedString(@"This operation cannot be undone", @"")
												   delegate: self 
                                          cancelButtonTitle: NSLocalizedString(@"Cancel", @"") 
                                          otherButtonTitles: NSLocalizedString(@"OK", @""), nil];
	[alert show];
	[alert release];
}

-(void)movieFinishedCallback:(NSNotification*)aNotification
{
    /*
    MPMoviePlayerController* theMovie = [aNotification object];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMoviePlayerPlaybackDidFinishNotification
                                                  object: theMovie];
    // Release the movie instance created in playMovieAtURL:
    [theMovie release];
     */
}

- (void)playMovie:(NSString*)movieURL
{
    /*
	MPMoviePlayerController* theMovie = [[TweetPlayer alloc] initWithContentURL:
                                         [NSURL URLWithString:[movieURL stringByAppendingString:@":iphone"]]];
	theMovie.scalingMode = MPMovieScalingModeAspectFit;
	theMovie.movieControlMode = MPMovieControlModeDefault;
    
	// Register for the playback finished notification.
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(movieFinishedCallback:)
                                                 name: MPMoviePlayerPlaybackDidFinishNotification
                                               object: theMovie];
    
	// Movie playback is asynchronous, so this method returns immediately.
	[theMovie play];
     */
}

#pragma mark ImageDownoader Delegate
- (void)receivedImage:(UIImage*)image sender:(ImageDownoader*)sender
{
	[_connectionsDelegates removeObject:sender];
	if(image)
	{
		ImageUploader * uploader = [[ImageUploader alloc] init];
		[_connectionsDelegates addObject:uploader];
		[uploader postData:UIImageJPEGRepresentation(image, 1.0f) delegate:self userData:sender.origURL];
		[uploader release];
	}
	[self implementOperationIfPossible];
}

#pragma mark ImageUploader Delegate
- (void)uploadedImage:(NSString*)yFrogURL sender:(ImageUploader*)sender
{
	[_connectionsDelegates removeObject:sender];
	if(yFrogURL)
		[_imagesLinks setObject:yFrogURL forKey:sender.userData];
	[self implementOperationIfPossible];
}

- (void)uploadedDataSize:(NSInteger)size
{
}

- (void)uploadedProccess:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten
{
}

#pragma mark UserInfoView Delegate
- (void)userDetailPressed
{
    UserInfo *infoView = [[UserInfo alloc] initWithUserName:[[_message objectForKey:@"user"] objectForKey:@"screen_name"]];
	[self.navigationController pushViewController:infoView animated:YES];
	[infoView release];
}

#pragma mark MFMailComposeViewController Delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark UIWebView Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	// starting the load, show the activity indicator in the status bar
	[TweetterAppDelegate increaseNetworkActivityIndicator];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if([[[request URL] absoluteString] isEqualToString:@"about:blank"])
		return YES;
    
	NSString *url = [[request URL] absoluteString];
	NSString *yFrogURL = ValidateYFrogLink(url);
	if(yFrogURL)
	{
		if(isVideoLink(yFrogURL))
		{
			[self playMovie:yFrogURL];
		}
		else
		{
			ImageViewController *imgViewCtrl = [[ImageViewController alloc] initWithYFrogURL:yFrogURL];
			imgViewCtrl.originalMessage = _message;
			[self.navigationController pushViewController:imgViewCtrl animated:YES];
			[imgViewCtrl release];
		}
	}
	else if([url hasPrefix:@"user://"])
	{
		NSString *user = [[url substringFromIndex:7] stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
		UserInfo *infoView = [[UserInfo alloc] initWithUserName:user];
		[self.navigationController pushViewController:infoView animated:YES];
		[infoView release];
	}
    else if ([[[request URL] host] isEqualToString:@"maps.google.com"])
    {
		TweetterAppDelegate *appDel = (TweetterAppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDel startOpenGoogleMapsRequest:request];
    }
	else
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
    YFLog(@"WebViewDidFinishLoad: Orientation is %d",[UIDevice currentDevice].orientation);
}

#pragma mark UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	_suspendedOperation = TVNoMVOperations;
	id obj;
	NSEnumerator *enumerator = [_connectionsDelegates objectEnumerator];
	while (obj = [enumerator nextObject]) 
		[obj cancel];
}

#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(buttonIndex > 0)
	{
		[TweetterAppDelegate increaseNetworkActivityIndicator];
        
        NSString *messageId = [[_message objectForKey:@"id"] stringValue];
        
        YFLog(@"Delete twit: Message ID = %@", messageId);
        if (_isDirectMessage)
            [_twitter deleteDirectMessage:messageId];
        else
            [_twitter deleteUpdate:messageId];

        _suspendedOperation = TVDelete;
	}
}

#pragma mark UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kViewTableSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kViewTableRowsAtSections;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self createCellWithSection:tableView sectionIndex:indexPath.section forIndex:indexPath.row];
    
    return cell;
}

#pragma mark UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((indexPath.section == kMessageTableSection) ? 250 : 40);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return ((section == kMessageTableSection) ? 60 : 0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return ((section == kMessageTableSection) ? 40 : 0);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return ((section == kMessageTableSection) ? _headView : nil);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return ((section == kMessageTableSection) ? _footerView : nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark MGTweeterEngine Delegate
- (void)requestSucceeded:(NSString *)connectionIdentifier
{
    YFLog(@"MGTwitterEngine Request SUCCEEDED");
    
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TwittsUpdated" object:self];
	[TweetterAppDelegate decreaseNetworkActivityIndicator];
    
    if (_suspendedOperation == TVDelete)
    {
        [self.navigationController popViewControllerAnimated:YES];
        _suspendedOperation = TVNoMVOperations;
    }
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
    YFLog(@"MGTwitterEngine Request FAILED");
    YFLog(@"%@", error);

    [self enableFavoriteButton:YES];//DEBUG
    
	[TweetterAppDelegate decreaseNetworkActivityIndicator];
    if ([error code] == 401)
    {
        [AccountController showAccountController:self.navigationController];
    }
    else
    {
        NSString *msg = nil;
        if ([error code] == 404) {
            msg = NSLocalizedString(@"404_Not_Found", @"");
        } else if ([error code] == 400) {
            msg = NSLocalizedString(@"400_Bad_Request", @"");
        } else {
            msg = [error description];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Error!" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }

}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier
{
    YFLog(@"STATUS RECEIVED");
    isFavorited = !isFavorited;
    [self updateFavoriteIcon];
    [self enableFavoriteButton:YES];
}

- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)connectionIdentifier
{
    YFLog(@"DIRECT MESSAGES RECEIVED");
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier
{
    YFLog(@"USER INFO RECEIVED");
}

- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier
{
    YFLog(@"MISC INFO RECEIVED");
}

@end
