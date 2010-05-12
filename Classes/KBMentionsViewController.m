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
    
    cachingKey = kKBTwitterMentionsKey;
    [self showStatuses];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusRetrieved:) name:kTwitterStatusRetrievedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTweetNotification:) name:IFTweetLabelURLNotification object:nil];
    
    [timelineButton setImage:[UIImage imageNamed:@"tabTweets03.png"] forState:UIControlStateNormal];
    [mentionsButton setImage:[UIImage imageNamed:@"tabMentions01.png"] forState:UIControlStateNormal];
    [directMessageButton setImage:[UIImage imageNamed:@"tabDM03.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"tabSearch03.png"] forState:UIControlStateNormal];
}

- (void) showStatuses {
    [self startProgressBar:@"Retrieving your tweets..."];
    NSNumber *startAtId = [NSNumber numberWithInt:0];
    tweets = [[NSMutableArray alloc] initWithArray:[[KBTwitterManager twitterManager] retrieveCachedStatusArrayWithKey:cachingKey]];
    if (tweets != nil && [tweets count] > 0) {
        startAtId = ((KBTweet*)[tweets objectAtIndex:0]).tweetId;
        [theTableView reloadData];
    }
    [twitterEngine getRepliesSinceID:[startAtId longLongValue] startingAtPage:0 count:25];
}

- (void) statusRetrieved:(NSNotification *)inNotification {
    NSLog(@"notification: %@", inNotification);
    if (inNotification) {
        if ([inNotification userInfo]) {
            NSDictionary *userInfo = [inNotification userInfo];
            if ([userInfo objectForKey:@"statuses"]) {
                statuses = [[userInfo objectForKey:@"statuses"] retain];
                //NSLog(@"status retrieved: %@", statuses);
                NSMutableArray *tempTweetArray = [[NSMutableArray alloc] initWithCapacity:[statuses count]];
                for (NSDictionary *dict in statuses) {
                    KBTweet *tweet = [[KBTweet alloc] initWithDictionary:dict];
                    [tempTweetArray addObject:tweet];
                    [tweet release];
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
                    tweets = [self addAndTrimArray:tempTweetArray];
                }
                [tempTweetArray release];
                [theTableView reloadData];
            }
        }
    }
    [self stopProgressBar];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[self dataSourceDidFinishLoadingNewData];
    [[KBTwitterManager twitterManager] cacheStatusArray:tweets withKey:cachingKey];
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
