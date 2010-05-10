//
//  KBTwitterSearchViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTwitterSearchViewController.h"
#import "KBSearchResult.h"
#import "KBTweetTableCell.h"

@implementation KBTwitterSearchViewController

@synthesize searchTerms;

- (void)viewDidLoad {
    pageViewType = KBPageViewTypeList;
    [super viewDidLoad];
    noResultsView.hidden = NO;
    
    if ([[KBTwitterManager twitterManager] searchResults]) {
        tweets = [[NSMutableArray alloc] initWithArray:[[KBTwitterManager twitterManager] searchResults]];
        searchTerms = [KBTwitterManager twitterManager].searchTerm;
        [theTableView reloadData];
        noResultsView.hidden = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchRetrieved:) name:kTwitterSearchRetrievedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTweetNotification:) name:IFTweetLabelURLNotification object:nil];
    [self showStatuses];
    
    [timelineButton setImage:[UIImage imageNamed:@"tabTweets03.png"] forState:UIControlStateNormal];
    [mentionsButton setImage:[UIImage imageNamed:@"tabMentions03.png"] forState:UIControlStateNormal];
    [directMessageButton setImage:[UIImage imageNamed:@"tabDM03.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"tabSearch01.png"] forState:UIControlStateNormal];
}

//- (void) viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//}

- (void) showStatuses {
    if (searchTerms) {
        [self startProgressBar:@"Retrieving your tweets..."];
        theSearchBar.text = searchTerms;
        [self executeQuery:0];
    }
}

- (void)searchRetrieved:(NSNotification *)inNotification {
    NSLog(@"inside searchRetrieved: %@", inNotification);
    if (inNotification) {
        if ([inNotification userInfo]) {
            NSDictionary *userInfo = [inNotification userInfo];
            if ([userInfo objectForKey:@"searchResults"]) {
                statuses = [[[[userInfo objectForKey:@"searchResults"] objectAtIndex:0] objectForKey:@"results"] retain];
                tweets = [[NSMutableArray alloc] initWithCapacity:[statuses count]];
                if ([statuses count] > 1) {
                    for (NSDictionary *dict in statuses) {
                        KBSearchResult *result = [[KBSearchResult alloc] initWithDictionary:dict];
                        [tweets addObject:result];
                        [result release];
                    }
                    [theTableView reloadData];
                    
                    [KBTwitterManager twitterManager].searchResults = nil;
                    [KBTwitterManager twitterManager].searchResults = [[NSArray alloc] initWithArray:tweets];
                    
                    noResultsView.hidden = YES;
                } else {
                    noResultsView.hidden = NO;
                }
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
    [KBTwitterManager twitterManager].searchTerm = searchBar.text;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    KBTweetTableCell *cell = (KBTweetTableCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[KBTweetTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    KBSearchResult *tweet = [tweets objectAtIndex:indexPath.row];
    
    cell.userIcon.urlPath = tweet.profileImageUrl;
    cell.userName.text = tweet.screenName;
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
}

- (void) executeQuery:(int)pageNumber {
    [twitterEngine getSearchResultsForQuery:searchTerms sinceID:0 startingAtPage:pageNumber count:25];
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
    [searchTerms release];
    [theSearchBar release];
    [super dealloc];
}


@end
