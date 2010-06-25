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
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTweetNotification:) name:IFTweetLabelURLNotification object:nil];
    
    cachingKey = kKBTwitterDirectMessagesKey;
    [self startProgressBar:@"Retrieving more tweets..."];
    [self showStatuses];
    
    [timelineButton setImage:[UIImage imageNamed:@"tabTweets03.png"] forState:UIControlStateNormal];
    [mentionsButton setImage:[UIImage imageNamed:@"tabMentions03.png"] forState:UIControlStateNormal];
    [directMessageButton setImage:[UIImage imageNamed:@"tabDM01.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"tabSearch03.png"] forState:UIControlStateNormal];
}

- (void) showStatuses {
    NSNumber *startAtId = [NSNumber numberWithInt:0];
    tweets = [[NSMutableArray alloc] initWithArray:[[KBTwitterManager twitterManager] retrieveCachedStatusArrayWithKey:cachingKey]];
    if (tweets != nil && [tweets count] > 0) {
        startAtId = ((KBTweet*)[tweets objectAtIndex:0]).tweetId;
        [theTableView reloadData];
    }
    isInitialLoad = YES;
    [twitterEngine getDirectMessagesSinceID:[startAtId longLongValue] startingAtPage:0];
}

- (void)directMessagesReceived:(NSArray *)messages {
    DLog("direct messages array: %@", messages);
    DLog("direct messages array count: %d", [messages count]);
	if ([messages count] > 0 || isInitialLoad) {
		twitterArray = [messages retain];
		//DLog(@"status retrieved: %@", statuses);
		NSMutableArray *tempTweetArray = [[NSMutableArray alloc] initWithCapacity:[twitterArray count]];
		for (NSDictionary *dict in twitterArray) {
			KBDirectMessage *message = [[KBDirectMessage alloc] initWithDictionary:dict];
			[tempTweetArray addObject:message];
			[message release];
		}
		// not very pretty, but it gets the job done. if there is a cached array, combine them.
		// the other way to do it would be to just add all the objects (above) by index
		if (pageNum > 1) {
			[tweets addObjectsFromArray:tempTweetArray];
		} else if (!tweets) {
			tweets = [[NSMutableArray alloc] initWithArray:tempTweetArray];
		} else {
			// need to keep all the tweets in the right order
			[tempTweetArray addObjectsFromArray:tweets];
			tweets = nil;
			[tweets release];
			tweets = [[self addAndTrimArray:tempTweetArray] retain];
		}
		[tempTweetArray release];
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
    [twitterEngine getDirectMessagesSinceID:0 startingAtPage:pageNumber];
}

- (void) refreshTable {
    [self showStatuses];
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
