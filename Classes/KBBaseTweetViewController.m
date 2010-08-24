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
    requeryWhenTableGetsToBottom = YES;
    [super viewDidLoad];
	twitterManager = [KBTwitterManager twitterManager];
	stuckToBottom = 0;
	theTableView.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.0];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(twitterViewLoadFailure) name:@"twitterViewLoadFailure" object:nil];	
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)twitterViewLoadFailure {
	[self.navigationController popViewControllerAnimated:NO];
}

- (NSMutableArray*) addAndTrimArray:(NSMutableArray*)arrayToAdd {
    NSRange theRange;
    theRange.location = 0;
    theRange.length = [arrayToAdd count] < 25 ? [arrayToAdd count] : 25;
    return [[[NSMutableArray alloc] initWithArray:[arrayToAdd subarrayWithRange:theRange]] autorelease];
}

// FIXME: if this isn't supposed to be called, then all the notification observers need to be removed from all the classes
- (void)handleTweetNotification:(NSNotification *)notification {
    DLog(@"--------------------------this should never be called, because links were removed from most views--------------------");
	DLog(@"handleTweetNotification: notification = %@", notification);
}

- (void) showStatuses {
    DLog(@"implement this!!");
}

- (void)requestSucceeded:(NSString *)connectionIdentifier
{
	DLog(@"Twitter request succeeded 1: %@", connectionIdentifier);
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
	//warning, this is not the main requestFailed method for twitter, and doesn't normally get called
	DLog(@"actual Twitter request failed 4: %@ with error:%@", connectionIdentifier, error);
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(stopProgressBar) userInfo:nil repeats:NO];
	if ([[error domain] isEqualToString: @"HTTP"])
	{
		switch ([error code]) {
				
			case 401:
			{
				// Unauthorized. The user's credentials failed to verify.
				UIAlertViewQuick(@"Oops!", @"Your username and password could not be verified. Double check that you entered them correctly and try again.", @"OK");	
				break;				
			}
				
			case 404:
			{
				// Page doesn't exist. e.g., a nonexistant username was searched on
				UIAlertViewQuick(@"Page Does Not Exist", @"The Twitter information that you are looking for does not exist.", @"OK");	
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
	CGSize expectedLabelSize = [tweet.tweetText sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0]
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
		cell.tweetText.text = tweet.tweetText; // [TTStyledText textWithURLs:tweet.tweetText lineBreaks:NO]; //tweet.tweetText;
        [cell setDateLabelWithText:[[KickballAPI kickballApi] convertDateToTimeUnitString:tweet.createDate]];
		
        CGSize maximumLabelSize = CGSizeMake(250, MAX_LABEL_HEIGHT);
        CGSize expectedLabelSize = [cell.tweetText.text sizeWithFont:cell.tweetText.font 
                                                   constrainedToSize:maximumLabelSize 
                                                       lineBreakMode:UILineBreakModeWordWrap]; 
        
        //adjust the label the the new height.
        CGRect newFrame = cell.tweetText.frame;
        newFrame.size.height = expectedLabelSize.height;
        cell.tweetText.frame = newFrame;

        return cell;
}

#pragma mark -
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [theTableView deselectRowAtIndexPath:indexPath animated:YES];
        KBTwitterDetailViewController *detailViewController = [[KBTwitterDetailViewController alloc] initWithNibName:@"KBTwitterDetailViewController" bundle:nil];
        detailViewController.tweet = [tweets objectAtIndex:indexPath.row];
        detailViewController.tweets = tweets;
        [self.navigationController pushViewController:detailViewController animated:YES];
		[detailViewController release];
    } else {
        [self executeQuery:++pageNum];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if ((indexPath.row == [tweets count] - 1) || (stuckToBottom >= [tweets count] - 1)) {
        if (requeryWhenTableGetsToBottom) {
            [self executeQuery:++pageNum];
        } else {
            DLog("********************* REACHED NO MORE RESULTS!!!!! **********************");
        }
		requeryWhenTableGetsToBottom = !requeryWhenTableGetsToBottom;
	} else if (indexPath.row >= [tweets count] - 3) {
		//this is ugly, but it works well.  allows user to grab more tweets when they went offline and then online again
		if (stuckToBottom >= indexPath.row) {
		  stuckToBottom++;
		  requeryWhenTableGetsToBottom = YES; //we didn't get the server response because we were offline, try again
		} else stuckToBottom = indexPath.row;
	}
}

- (void) viewOtherUserProfile:(NSString*)userName {
	KBTwitterProfileViewController *twitterProfileController = [[KBTwitterProfileViewController alloc] initWithNibName:@"KBTwitterProfileViewController" bundle:nil];
    twitterProfileController.screenname = userName;
	[self checkMemoryUsage];
	[self.navigationController pushViewController:twitterProfileController animated:YES];
	[twitterProfileController release];
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
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [tweets release];
    if (cachingKey) [cachingKey release];
    [super dealloc];
}


@end
