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
#import "KickballAPI.h"

@implementation KBTwitterSearchViewController

@synthesize searchTerms;

- (void)viewDidLoad {
    pageType = KBPageTypeFriends;
    pageViewType = KBPageViewTypeList;
    [super viewDidLoad];
    pageNum = 1;
    noResultsView.hidden = NO;
    
    if ([[KBTwitterManager twitterManager] searchTerm]) {
        searchTerms = [KBTwitterManager twitterManager].searchTerm;
        if (theTableView) [theTableView reloadData];
        noResultsView.hidden = YES;
    }
    
    [self showStatuses];
    
    [timelineButton setImage:[UIImage imageNamed:@"tabTweets03.png"] forState:UIControlStateNormal];
    [mentionsButton setImage:[UIImage imageNamed:@"tabMentions03.png"] forState:UIControlStateNormal];
    [directMessageButton setImage:[UIImage imageNamed:@"tabDM03.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"tabSearch01.png"] forState:UIControlStateNormal];
}
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  twitterManager.delegate = self;
}
- (void) showStatuses {
    if (searchTerms) {
        theSearchBar.text = searchTerms;
        [self executeQuery:1];
    }
}

- (void)searchResultsReceived:(NSArray *)searchResults {
	if (searchResults) {
		localTwitterArray = [[[searchResults objectAtIndex:0] objectForKey:@"results"] copy];
		if ([localTwitterArray count] > 1) {
			NSMutableArray *tempTweetArray = [[NSMutableArray alloc] initWithCapacity:[localTwitterArray count]];
			for (NSDictionary *dict in localTwitterArray) {
				KBSearchResult *tweet = [[KBSearchResult alloc] initWithDictionary:dict];
				[tempTweetArray addObject:tweet];
				[tweet release];
			}
			
			if (pageNum > 1) {
				[tweets addObjectsFromArray:tempTweetArray];
			} else if (!tweets) {
				tweets = [[NSMutableArray alloc] initWithArray:tempTweetArray];
			} else {
				// need to keep all the tweets in the right order
				[tempTweetArray addObjectsFromArray:tweets];
				[tweets release];
				tweets = nil;
				tweets = [[self addAndTrimArray:tempTweetArray] retain];
			}
			[tempTweetArray release];
			[theTableView reloadData];
			
			//[KBTwitterManager twitterManager].theSearchResults = nil;
			//[KBTwitterManager twitterManager].theSearchResults = [NSArray arrayWithArray:tweets];
			
			noResultsView.hidden = YES;
		} else {
            if (!tweets) noResultsView.hidden = NO;
		}
	} else {
        requeryWhenTableGetsToBottom = NO;
    }
    [self stopProgressBar];
    [self dataSourceDidFinishLoadingNewData];
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
	cell.dateLabel.text = [[KickballAPI kickballApi] convertDateToTimeUnitString:tweet.createDate];
	
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
    [self startProgressBar:@"Retrieving more tweets..."];
    [twitterEngine getSearchResultsForQuery:theSearchBar.text sinceID:0 startingAtPage:pageNumber count:25];
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (tweets) [tweets release];
    tweets = nil;
    pageNum = 0;
    searchTerms = theSearchBar.text;
    [theSearchBar resignFirstResponder];
    [self showStatuses];
    [KBTwitterManager twitterManager].searchTerm = theSearchBar.text;
    return YES;
}

#pragma mark -
#pragma mark memory management methods

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

-(void)dealloc{
	[localTwitterArray release];
    [searchTerms release];
	[super dealloc];
}

@end
