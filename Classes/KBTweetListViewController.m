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
    pageNum = 1;
    cachingKey = kKBTwitterTimelineKey;
    pageViewType = KBPageViewTypeList;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginCanceled) name:@"loginCanceled" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideAppropriateTabs) name:@"hideAppropriateTabs" object:nil];
    if ([self.twitterEngine isAuthorized]) {
        //[self createNotificationObservers];
		[self showStatuses];
	} else {
        loginController = [[KBTwitterXAuthLoginController alloc] initWithNibName:@"TwitterLoginView_v2" bundle:nil];
		loginController.rootController = self;
        [self presentModalViewController:loginController animated:YES];
        [loginController release];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    //overriding the removal of notifications
}

- (void) loginCanceled {
    [self switchToFoursquare];
}

- (void) showStatuses {
    [loginController removeFromSupercontroller];
    NSNumber *startAtId = [NSNumber numberWithInt:0];
    tweets = [[NSMutableArray alloc] initWithArray:[[KBTwitterManager twitterManager] retrieveCachedStatusArrayWithKey:cachingKey]];
    if (tweets != nil && [tweets count] > 0) {
        startAtId = ((KBTweet*)[tweets objectAtIndex:0]).tweetId;
        [theTableView reloadData];
    }
    [self startProgressBar:@"Retrieving your tweets..."];
    [self.twitterEngine getFollowedTimelineSinceID:[startAtId longLongValue] startingAtPage:0 count:25];
}

- (void)statusesReceived:(NSArray *)statuses {
	if (statuses) {
		twitterArray = [statuses retain];
		NSMutableArray *tempTweetArray = [[NSMutableArray alloc] initWithCapacity:[twitterArray count]];
		for (NSDictionary *dict in twitterArray) {
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
			if ([tempTweetArray count] > 0) {
				KBMessage *message = [[KBMessage alloc] initWithMember:[NSString stringWithFormat:@"%d New Messages!", [tempTweetArray count]] andMessage:@""];
				[self displayPopupMessageWithFadeout:message];
				[message release];
			}
			// need to keep all the tweets in the right order
			[tempTweetArray addObjectsFromArray:tweets];
			tweets = nil;
			[tweets release];
			tweets = [[self addAndTrimArray:tempTweetArray] retain];
		}
		[theTableView reloadData];
		 
		[tempTweetArray release];
	}
    [self stopProgressBar];
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self dataSourceDidFinishLoadingNewData];
    [[KBTwitterManager twitterManager] cacheStatusArray:tweets withKey:cachingKey];
}

- (void) executeQuery:(int)pageNumber {
    [self startProgressBar:@"Retrieving more tweets..."];
    [self.twitterEngine getFollowedTimelineSinceID:0
                                    startingAtPage:pageNumber 
                                             count:25];
}

- (void) refreshTable {
    [self showStatuses];
}

#pragma mark -
#pragma mark MGTwitterEngineDelegate methods

- (void)requestSucceeded:(NSString *)connectionIdentifier {
	NSLog(@"Twitter request succeeded: %@", connectionIdentifier);
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error {
	NSLog(@"Twitter request failed: %@ with error:%@", connectionIdentifier, error);
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
    loginController = nil;
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    loginController = nil;
}


- (void)dealloc {
    [loginController release];
    [super dealloc];
}


@end

