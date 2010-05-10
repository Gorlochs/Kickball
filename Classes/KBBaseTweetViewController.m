    //
//  KBBaseTweetViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBBaseTweetViewController.h"
#import "KBUserTweetsViewController.h"
#import "KBTwitterSearchViewController.h"
#import "KBTwitterDetailViewController.h"
#import "KBCreateTweetViewController.h"
#import "UIAlertView+Helper.h"

#define MAX_LABEL_HEIGHT 68.0


@implementation KBBaseTweetViewController

- (void)viewDidLoad {
    pageNum = 0;
    [super viewDidLoad];    
}

- (void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusRetrieved:) name:kTwitterStatusRetrievedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTweetNotification:) name:IFTweetLabelURLNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showStatuses) name:kTwitterLoginNotificationKey object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleTweetNotification:(NSNotification *)notification {
	//NSLog(@"handleTweetNotification: notification = %@", notification);
    if ([[notification object] rangeOfString:@"@"].location == 0) {
        KBUserTweetsViewController *controller = [[KBUserTweetsViewController alloc] initWithNibName:@"KBUserTweetsViewController" bundle:nil];
        controller.username = [notification object];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    } else if ([[notification object] rangeOfString:@"#"].location == 0) {
        KBTwitterSearchViewController *controller = [[KBTwitterSearchViewController alloc] initWithNibName:@"KBTweetListViewController" bundle:nil];
        controller.searchTerms = [notification object];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    } else {
        // TODO: push properly styled web view
        [self openWebView:[notification object]];
    }
}

- (void) showStatuses {
    NSLog(@"implement this!!");
}

- (void) openTweetModalView {
    KBCreateTweetViewController *tweetController = [[KBCreateTweetViewController alloc] initWithNibName:@"KBCreateTweetViewController" bundle:nil];
    [self presentModalViewController:tweetController animated:YES];
    [tweetController release];
}

- (void)requestSucceeded:(NSString *)connectionIdentifier
{
	NSLog(@"Twitter request succeeded: %@", connectionIdentifier);
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
	NSLog(@"Twitter request failed: %@ with error:%@", connectionIdentifier, error);
    
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
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return section == 0 ? [tweets count] : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return 44;
    } else {
        KBTweet *tweet = [tweets objectAtIndex:indexPath.row];
        
        CGSize maximumLabelSize = CGSizeMake(250, MAX_LABEL_HEIGHT);
        CGSize expectedLabelSize = [tweet.tweetText sizeWithFont:[UIFont fontWithName:@"Georgia" size:12.0]
                                               constrainedToSize:maximumLabelSize 
                                                   lineBreakMode:UILineBreakModeWordWrap];
        
        return expectedLabelSize.height + 30.0 > MAX_LABEL_HEIGHT ? expectedLabelSize.height + 30.0 : MAX_LABEL_HEIGHT;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    KBTweetTableCell *cell = (KBTweetTableCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[KBTweetTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (indexPath.section == 0) {
        // Configure the cell...
        //cell.textLabel.text = [[statuses objectAtIndex:indexPath.row] objectForKey:@"text"];
        KBTweet *tweet = [tweets objectAtIndex:indexPath.row];
        
        cell.userIcon.urlPath = tweet.profileImageUrl;
        cell.userName.text = tweet.screenName;
        cell.tweetText.numberOfLines = 0;
        cell.tweetText.text = tweet.tweetText;
        [cell setDateLabelWithDate:tweet.createDate];
        
        CGSize maximumLabelSize = CGSizeMake(250, MAX_LABEL_HEIGHT);
        CGSize expectedLabelSize = [cell.tweetText.text sizeWithFont:cell.tweetText.font 
                                                   constrainedToSize:maximumLabelSize 
                                                       lineBreakMode:UILineBreakModeWordWrap]; 
        
        //adjust the label the the new height.
        CGRect newFrame = cell.tweetText.frame;
        newFrame.size.height = expectedLabelSize.height;
        cell.tweetText.frame = newFrame;
        
        return cell;
    } else {
        return moreCell;
    }
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        KBTwitterDetailViewController *detailViewController = [[KBTwitterDetailViewController alloc] initWithNibName:@"KBTwitterDetailViewController" bundle:nil];
        detailViewController.tweet = [tweets objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
    } else {
        [self executeQuery:++pageNum];
    }
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
    statuses = nil;
    moreCell = nil;
    noResultsView = nil;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tweets release];
    [cachingKey release];
    [statuses release];
    [moreCell release];
    [noResultsView release];
    [super dealloc];
}


@end
