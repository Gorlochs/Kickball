//
//  KBTwitterSearchViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTwitterSearchViewController.h"
#import "KBSearchResult.h"


@implementation KBTwitterSearchViewController

@synthesize searchTerms;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchRetrieved:) name:kTwitterSearchRetrievedNotificationKey object:nil];
    
    [timelineButton setImage:[UIImage imageNamed:@"tabTweets03.png"] forState:UIControlStateNormal];
    [mentionsButton setImage:[UIImage imageNamed:@"tabMentions03.png"] forState:UIControlStateNormal];
    [directMessageButton setImage:[UIImage imageNamed:@"tabDM03.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"tabSearch01.png"] forState:UIControlStateNormal];
}

- (void) showStatuses {
    if (searchTerms) {
        [self startProgressBar:@"Retrieving your tweets..."];
        theSearchBar.text = searchTerms;
        [twitterEngine getSearchResultsForQuery:searchTerms sinceID:0 startingAtPage:0 count:25];
    }
}

- (void)searchRetrieved:(NSNotification *)inNotification {
    NSLog(@"inside searchRetrieved");
    if (inNotification) {
        if ([inNotification userInfo]) {
            NSDictionary *userInfo = [inNotification userInfo];
            if ([userInfo objectForKey:@"searchResults"]) {
                statuses = [[userInfo objectForKey:@"searchResults"] retain];
                tweets = [[NSMutableArray alloc] initWithCapacity:[statuses count]];
                //int i = 0;
                for (NSDictionary *dict in statuses) {
                    //if (i++ < [statuses count]) {
                        [tweets addObject:[[KBSearchResult alloc] initWithDictionary:dict]];
                    //}
                }
                // FIXME: remove last dictionary object
                [theTableView reloadData];
            }
        }
    }
    [self stopProgressBar];
    [self dataSourceDidFinishLoadingNewData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    searchTerms = searchBar.text;
    [searchBar resignFirstResponder];
    [self showStatuses];
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
    KBSearchResult *tweet = [tweets objectAtIndex:indexPath.row];
    
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
    [super dealloc];
}


@end
