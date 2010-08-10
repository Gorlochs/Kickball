    //
//  KBMentionsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBMentionsViewController.h"


@implementation KBMentionsViewController

- (void)viewDidLoad {
    pageViewType = KBPageViewTypeList;
    [super viewDidLoad];
    
    cachingKey = [kKBTwitterMentionsKey retain];
    [self startProgressBar:@"Retrieving your tweets..."];
    [self showStatuses];
    
    [timelineButton setImage:[UIImage imageNamed:@"tabTweets03.png"] forState:UIControlStateNormal];
    [mentionsButton setImage:[UIImage imageNamed:@"tabMentions01.png"] forState:UIControlStateNormal];
    [directMessageButton setImage:[UIImage imageNamed:@"tabDM03.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"tabSearch03.png"] forState:UIControlStateNormal];
	pageNum = 1;
}

- (void) showStatuses {
    NSNumber *startAtId = [NSNumber numberWithInt:0];
    //if (tweets) [tweets release];
    tweets = [[NSMutableArray alloc] initWithArray:[[KBTwitterManager twitterManager] retrieveCachedStatusArrayWithKey:cachingKey]];
    if (tweets != nil && [tweets count] > 0) {
        startAtId = ((KBTweet*)[tweets objectAtIndex:0]).tweetId;
        [theTableView reloadData];
    }
    [twitterEngine getRepliesSinceID:[startAtId longLongValue] startingAtPage:0 count:25];
}

- (void)statusesReceived:(NSArray *)statuses {
	if (statuses) {
        int count = 0;
        if (!tweets) tweets = [[NSMutableArray alloc] init];
        if (pageNum > 1) count = [tweets count];
		for (NSDictionary *dict in statuses) {
			KBTweet *tweet = [[KBTweet alloc] initWithDictionary:dict];
            [tweets insertObject:tweet atIndex:count++];
			[tweet release];
		}
        if (!pageNum) {
            while ([tweets count] > 25) [tweets removeLastObject];
        }
		[theTableView reloadData];
		if (cachingKey) {
			[[KBTwitterManager twitterManager] cacheStatusArray:tweets withKey:cachingKey];
		}
        [[NSUserDefaults standardUserDefaults] synchronize];
	} else {
        requeryWhenTableGetsToBottom = NO;
    }
    [self stopProgressBar];
	[self dataSourceDidFinishLoadingNewData];
}

- (void) executeQuery:(int)pageNumber {
    [self startProgressBar:@"Retrieving more tweets..."];
    [twitterEngine getRepliesSinceID:0 startingAtPage:pageNumber count:25];
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
