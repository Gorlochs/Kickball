    //
//  KBBaseTweetViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBBaseTweetViewController.h"
#import "KBCreateTweetViewController.h"
#import "UIAlertView+Helper.h"
#import "KBUserTweetsViewController.h"
#import "KBTwitterSearchViewController.h"
#import "KBTwitterDetailViewController.h"
#import "KBTwitterProfileViewController.h"
#import "KickballAPI.h"

@implementation KBBaseTweetViewController

- (void)viewDidLoad {
    pageNum = 0;
    [super viewDidLoad];
	twitterManager = [KBTwitterManager twitterManager];
	twitterManager.delegate = self;
	
	// TODO: find a better way to do this
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTweetNotification:) name:IFTweetLabelURLNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (NSMutableArray*) addAndTrimArray:(NSMutableArray*)arrayToAdd {
    NSRange theRange;
    theRange.location = 0;
    theRange.length = [arrayToAdd count] < 25 ? [arrayToAdd count] : 25;
    return [[[NSMutableArray alloc] initWithArray:[arrayToAdd subarrayWithRange:theRange]] autorelease];
}

- (void)handleTweetNotification:(NSNotification *)notification {
	DLog(@"handleTweetNotification: notification = %@", notification);
    if ([[notification object] rangeOfString:@"@"].location == 0) {
        userTweetsController = [[KBUserTweetsViewController alloc] initWithNibName:@"KBUserTweetsViewController" bundle:nil];
        userTweetsController.username = [notification object];
        [self.navigationController pushViewController:userTweetsController animated:YES];
    } else if ([[notification object] rangeOfString:@"#"].location == 0) {
        searchController = [[KBTwitterSearchViewController alloc] initWithNibName:@"KBTwitterSearchViewController" bundle:nil];
        searchController.searchTerms = [notification object];
        [self.navigationController pushViewController:searchController animated:YES];
    } else {
        // TODO: push properly styled web view
        [self openWebView:[notification object]];
    }
}

- (void) showStatuses {
    DLog(@"implement this!!");
}

- (void)requestSucceeded:(NSString *)connectionIdentifier
{
	DLog(@"Twitter request succeeded: %@", connectionIdentifier);
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
	DLog(@"Twitter request failed: %@ with error:%@", connectionIdentifier, error);
    [self stopProgressBar];
	if ([[error domain] isEqualToString: @"HTTP"])
	{
		switch ([error code]) {
				
			case 401:
			{
				// Unauthorized. The user's credentials failed to verify.
				UIAlertViewQuick(@"Oops!", @"Your username and password could not be verified. Double check that you entered them correctly and try again.", @"OK");	
				break;				
			}
				
			case 502:
			{
				// Bad gateway: twitter is down or being upgraded.
				UIAlertViewQuick(@"Fail whale!", @"Looks like Twitter is down or being updated. Please wait a few seconds and try again.", @"OK");	
				break;				
			}
				
			case 503:
			{
				// Service unavailable
				UIAlertViewQuick(@"Hold your taps!", @"Looks like Twitter is overloaded. Please wait a few seconds and try again.", @"OK");	
				break;								
			}
				
			default:
			{
				NSString *errorMessage = [[NSString alloc] initWithFormat: @"%d %@", [error	code], [error localizedDescription]];
				UIAlertViewQuick(@"Twitter error!", errorMessage, @"OK");	
				[errorMessage release];
				break;				
			}
		}
		
	}
	else 
	{
		switch ([error code]) {
				
			case -1009:
			{
				UIAlertViewQuick(@"You're offline!", @"Sorry, it looks like you lost your Internet connection. Please reconnect and try again.", @"OK");					
				break;				
			}
				
			case -1200:
			{
				UIAlertViewQuick(@"Secure connection failed", @"I couldn't connect to Twitter. This is most likely a temporary issue, please try again.", @"OK");					
				break;								
			}
				
			default:
			{				
				NSString *errorMessage = [[NSString alloc] initWithFormat:@"%@ xx %d: %@", [error domain], [error code], [error localizedDescription]];
				UIAlertViewQuick(@"Network Error!", errorMessage , @"OK");
				[errorMessage release];
			}
		}
	}
	
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [tweets count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	KBTweet *tweet = [tweets objectAtIndex:indexPath.row];
	
	CGSize maximumLabelSize = CGSizeMake(250, MAX_LABEL_HEIGHT);
	CGSize expectedLabelSize = [tweet.tweetText sizeWithFont:[UIFont fontWithName:@"Georgia" size:12.0]
										   constrainedToSize:maximumLabelSize 
											   lineBreakMode:UILineBreakModeWordWrap];
	
	return expectedLabelSize.height + 48.0; // > MAX_LABEL_HEIGHT ? expectedLabelSize.height + 30.0 : MAX_LABEL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    KBTweetTableCell320 *cell = (KBTweetTableCell320*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[[KBTweetTableCell320 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
    
        KBTweet *tweet = [tweets objectAtIndex:indexPath.row];
        
        cell.userIcon.urlPath = tweet.profileImageUrl;
        cell.userName.text = tweet.screenName;
        //cell.tweetText.numberOfLines = 0;
		//cell.tweetText.text = tweet.tweetText;
        cell.tweetText.text = [TTStyledText textWithURLs:tweet.tweetText lineBreaks:NO]; //tweet.tweetText;
        //[cell setDateLabelWithDate:tweet.createDate];
        [cell setDateLabelWithText:[[KickballAPI kickballApi] convertDateToTimeUnitString:tweet.createDate]];
		/*
        CGSize maximumLabelSize = CGSizeMake(250, MAX_LABEL_HEIGHT);
        CGSize expectedLabelSize = [cell.tweetText.text sizeWithFont:cell.tweetText.font 
                                                   constrainedToSize:maximumLabelSize 
                                                       lineBreakMode:UILineBreakModeWordWrap]; 
        
        //adjust the label the the new height.
        CGRect newFrame = cell.tweetText.frame;
        newFrame.size.height = expectedLabelSize.height;
        cell.tweetText.frame = newFrame;
        */
		[cell.tweetText sizeToFit];
		//[cell.tweetText setNeedsLayout];
		[cell.tweetText setNeedsDisplay];
        return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [theTableView deselectRowAtIndexPath:indexPath animated:YES];
        detailViewController = [[KBTwitterDetailViewController alloc] initWithNibName:@"KBTwitterDetailViewController" bundle:nil];
        detailViewController.tweet = [tweets objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:detailViewController animated:YES];
    } else {
        [self executeQuery:++pageNum];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == [tweets count] - 1) {
		[self executeQuery:++pageNum];
	}
}

- (void) viewUserProfile:(NSString*)userName {
	twitterProfileController = [[KBTwitterProfileViewController alloc] initWithNibName:@"KBTwitterProfileViewController" bundle:nil];
    twitterProfileController.screenname = userName;
	[self.navigationController pushViewController:twitterProfileController animated:YES];
}

#pragma mark -
#pragma mark table refresh methods

- (void) executeQuery:(int)pageNumber {
    
}

#pragma mark -
#pragma mark memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    tweets = nil;
    cachingKey = nil;
    twitterArray = nil;
    noResultsView = nil;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tweets release];
    [cachingKey release];
    [twitterArray release];
    [noResultsView release];
    [detailViewController release];
    [userTweetsController release];
    [searchController release];
	[twitterProfileController release];
    [super dealloc];
}


@end
