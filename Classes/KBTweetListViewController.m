//
//  KBTweetListViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/16/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTweetListViewController.h"
#import "Three20/Three20.h"
#import "UIAlertView+Helper.h"
#import "XAuthTwitterEngineViewController.h"
#import "KBTwitterSearchViewController.h"
#import "KBUserTweetsViewController.h"
#import "KBTwitterDetailViewController.h"

@implementation KBTweetListViewController


#pragma mark -
#pragma mark View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
 
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createNotificationObservers];
    
    if ([self.twitterEngine isAuthorized]) {
		[self showStatuses];
	} else {
        XAuthTwitterEngineViewController *loginController = [[XAuthTwitterEngineViewController alloc] initWithNibName:@"XAuthTwitterEngineDemoViewController" bundle:nil];
        [self presentModalViewController:loginController animated:YES];
        [loginController release];
    }
}

- (void) createNotificationObservers {
    NSLog(@"########## this should only show up for the KBTweetListViewController view ########");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusRetrieved:) name:kTwitterStatusRetrievedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTweetNotification:) name:IFTweetLabelURLNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showStatuses) name:kTwitterLoginNotificationKey object:nil];
}

- (void) showStatuses {
    [twitterEngine getFollowedTimelineSinceID:0 startingAtPage:0 count:25];
}

- (void) statusRetrieved:(NSNotification *)inNotification {
    NSLog(@"notification: %@", inNotification);
    if (inNotification) {
        if ([inNotification userInfo]) {
            NSDictionary *userInfo = [inNotification userInfo];
            if ([userInfo objectForKey:@"statuses"]) {
                statuses = [[userInfo objectForKey:@"statuses"] retain];
                //NSLog(@"status retrieved: %@", statuses);
                tweets = [[NSMutableArray alloc] initWithCapacity:[statuses count]];
                for (NSDictionary *dict in statuses) {
                    [tweets addObject:[[KBTweet alloc] initWithDictionary:dict]];
                }
                [theTableView reloadData];
            }
        }
    }
	[self dataSourceDidFinishLoadingNewData];
}

- (void)handleTweetNotification:(NSNotification *)notification {
	NSLog(@"handleTweetNotification: notification = %@", notification);
    if ([[notification object] rangeOfString:@"@"].location == 0) {
        KBUserTweetsViewController *controller = [[KBUserTweetsViewController alloc] initWithNibName:@"KBTweetListViewController" bundle:nil];
        controller.username = [notification object];
        [self.navigationController pushViewController:controller animated:YES];
    } else if ([[notification object] rangeOfString:@"#"].location == 0) {
        // TODO: push hashtag search view (http://search.twitter.com/search.atom?q=%23haiku)
        KBTwitterSearchViewController *controller = [[KBTwitterSearchViewController alloc] initWithNibName:@"KBTweetListViewController" bundle:nil];
        controller.searchTerms = [notification object];
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        // TODO: push properly styled web view
        [self openWebView:[notification object]];
    }
}

#pragma mark -
#pragma mark MGTwitterEngineDelegate methods

- (void)requestSucceeded:(NSString *)connectionIdentifier
{
	NSLog(@"Twitter request succeeded: %@", connectionIdentifier);
	
	UIAlertViewQuick(@"Tweet sent!", @"The tweet was successfully sent. Everything works!", @"OK");
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
	NSLog(@"Twitter request failed: %@ with error:%@", connectionIdentifier, error);
    
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [statuses count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    KBTweetTableCell *cell = (KBTweetTableCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[KBTweetTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    //cell.textLabel.text = [[statuses objectAtIndex:indexPath.row] objectForKey:@"text"];
    KBTweet *tweet = [tweets objectAtIndex:indexPath.row];
    
    cell.userIcon.urlPath = tweet.profileImageUrl;
    cell.userName.text = tweet.screenName;
   // cell.tweetText.text = [TTStyledText textFromXHTML:tweet.tweetText lineBreaks:YES URLs:YES];
    cell.tweetText.text = tweet.tweetText;
    
    CGSize maximumLabelSize = CGSizeMake(250,60);
    CGSize expectedLabelSize = [cell.tweetText.text sizeWithFont:cell.tweetText.font 
                                           constrainedToSize:maximumLabelSize 
                                               lineBreakMode:UILineBreakModeTailTruncation]; 

    //adjust the label the the new height.
    CGRect newFrame = cell.tweetText.frame;
    newFrame.size.height = expectedLabelSize.height;
    cell.tweetText.frame = newFrame;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	KBTwitterDetailViewController *detailViewController = [[KBTwitterDetailViewController alloc] initWithNibName:@"KBTwitterDetailViewController" bundle:nil];
    detailViewController.tweet = [tweets objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}

#pragma mark -
#pragma mark table refresh methods

- (void) refreshTable {
    [self showStatuses];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [statuses release];
    [super dealloc];
}


@end

