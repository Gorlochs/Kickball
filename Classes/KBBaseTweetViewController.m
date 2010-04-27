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

@implementation KBBaseTweetViewController


- (void)viewDidLoad {
    pageNum = 0;
    [super viewDidLoad];    
}

- (void)handleTweetNotification:(NSNotification *)notification {
	NSLog(@"handleTweetNotification: notification = %@", notification);
    if ([[notification object] rangeOfString:@"@"].location == 0) {
        KBUserTweetsViewController *controller = [[KBUserTweetsViewController alloc] initWithNibName:@"KBUserTweetsViewController" bundle:nil];
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

- (void) showStatuses {
    NSLog(@"implement this!!");
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
        
        CGSize maximumLabelSize = CGSizeMake(250,60);
        CGSize expectedLabelSize = [tweet.tweetText sizeWithFont:[UIFont fontWithName:@"Georgia" size:12.0]
                                               constrainedToSize:maximumLabelSize 
                                                   lineBreakMode:UILineBreakModeTailTruncation];
        
        return expectedLabelSize.height + 30 > 70 ? expectedLabelSize.height + 30 : 70;
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
        cell.tweetText.numberOfLines = 4;
        cell.tweetText.text = tweet.tweetText;
        [cell setDateLabelWithDate:tweet.createDate];
        
        CGSize maximumLabelSize = CGSizeMake(250,60);
        CGSize expectedLabelSize = [cell.tweetText.text sizeWithFont:cell.tweetText.font 
                                                   constrainedToSize:maximumLabelSize 
                                                       lineBreakMode:UILineBreakModeTailTruncation]; 
        
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
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


@end
