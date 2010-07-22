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
	NSMutableArray *newArray = [[KBTwitterManager twitterManager] retrieveCachedStatusArrayWithKey:cachingKey];
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
        if (twitterArray) [twitterArray release];
        twitterArray = [messages retain];
        for (NSDictionary *message in twitterArray) {
		    if (tweets) {
			int x = 4;
				for (KBDirectMessage *cur in tweets) {
				   DLog(@"%@", [cur class]);
					NSNumber *tweetID = [message objectForKey:@"id"];
					if (--x > 0) {
					  continue;
					}
					if ([cur.tweetId respondsToSelector:@selector(longValue)]) {
					  if ([cur.tweetId longValue] == [tweetID longValue]) return; //don't add the same direct messages 
					} else {
					  DLog(@"no longvalue!");
					  return;
					}
				}
			}
        } 
        int count = 0;
        if (!tweets) tweets = [[NSMutableArray alloc] init];
        if (pageNum > 1) count = [tweets count];
		for (NSDictionary *dict in twitterArray) {
			KBDirectMessage *message = [[KBDirectMessage alloc] initWithDictionary:dict];
            [tweets insertObject:message atIndex:count++];
			[message release];
		}
		DLog(@"done inserting tweets");
		for (KBDirectMessage *cur in tweets) {
		  DLog(@"printing %i", cur.tweetId);
		  DLog(@"%i", [cur.tweetId longValue]);
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
//for shawn: this gets called multiple times, creating multiple sets of direct messages.  the first check at directMessages received stops this.
    isInitialLoad = NO;
	DLog(@"asking for page %i", pageNumber);
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
