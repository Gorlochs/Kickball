    //
//  KBDirectMentionsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBDirectMessagesViewController.h"
#import"KBDirectMessage.h"

@implementation KBDirectMessagesViewController

- (void)viewDidLoad {
    pageViewType = KBPageViewTypeList;
    [super viewDidLoad];
    cachingKey = [kKBTwitterDirectMessagesKey retain];
    [self startProgressBar:@"Retrieving more tweets..."];
    [self showStatuses];
    
    [timelineButton setImage:[UIImage imageNamed:@"tabTweets03.png"] forState:UIControlStateNormal];
    [mentionsButton setImage:[UIImage imageNamed:@"tabMentions03.png"] forState:UIControlStateNormal];
    [directMessageButton setImage:[UIImage imageNamed:@"tabDM01.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"tabSearch03.png"] forState:UIControlStateNormal];
	pageNum = 1;
}

- (void) showStatuses {
    NSNumber *startAtId = [NSNumber numberWithInt:0];
    if (tweets) [tweets release];
	tweets = nil;
	NSArray *newArray = [[KBTwitterManager twitterManager] retrieveCachedStatusArrayWithKey:cachingKey];
	DLog(@"tweet array: %@", newArray);
    if (newArray != nil && [newArray count] > 0) {
		tweets = [[NSMutableArray alloc] initWithArray:newArray];
        startAtId = ((KBTweet*)[tweets objectAtIndex:0]).tweetId;
        [theTableView reloadData];
    }
    isInitialLoad = YES;
    [twitterEngine getDirectMessagesSinceID:[startAtId longLongValue] startingAtPage:0];
}

- (void)directMessagesReceived:(NSArray *)messages {
	if ([messages count] > 0 || isInitialLoad) {
        int count = 0;
        if (!tweets) tweets = [[NSMutableArray alloc] initWithCapacity:1];
        if (pageNum > 1) count = [tweets count];
		for (NSDictionary *dict in messages) {
			KBDirectMessage *message = [[KBDirectMessage alloc] initWithDictionary:dict];
            [tweets insertObject:message atIndex:count++];
			[message release];
		}
        if (!pageNum) {
            while ([tweets count] > 25) [tweets removeLastObject];
        }
		[theTableView reloadData];
	} else {
        requeryWhenTableGetsToBottom = NO;
    }
    [self stopProgressBar];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dataSourceDidFinishLoadingNewData];
    [[KBTwitterManager twitterManager] cacheStatusArray:tweets withKey:cachingKey];
}

- (void) executeQuery:(int)pageNumber {
    isInitialLoad = NO;
	if ([tweets count]>0) {
		KBDirectMessage* someObject = [tweets objectAtIndex:0];
		id idObject = (KBDirectMessage*)someObject.tweetId;
		[twitterEngine getDirectMessagesSinceID:([tweets count] > 0 ? [idObject longLongValue] : 0) startingAtPage:pageNumber];
	}else {
		requeryWhenTableGetsToBottom = NO;
	}

}

- (void) refreshTable {
    [self showStatuses];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	KBDirectMessage *tweet = [tweets objectAtIndex:indexPath.row];
	
	CGSize maximumLabelSize = CGSizeMake(250, MAX_LABEL_HEIGHT);
	CGSize expectedLabelSize = [tweet.tweetText sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0]
										   constrainedToSize:maximumLabelSize 
											   lineBreakMode:UILineBreakModeWordWrap];
	
	return expectedLabelSize.height + 48.0; // > MAX_LABEL_HEIGHT ? expectedLabelSize.height + 30.0 : MAX_LABEL_HEIGHT;
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
