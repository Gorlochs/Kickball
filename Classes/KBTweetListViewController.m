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
    cachingKey = kKBTwitterTimelineKey;
    
    if ([self.twitterEngine isAuthorized]) {
        [self createNotificationObservers];
		[self showStatuses];
	} else {
        loginController = [[XAuthTwitterEngineViewController alloc] initWithNibName:@"XAuthTwitterEngineDemoViewController" bundle:nil];
        [self presentModalViewController:loginController animated:YES];
        [loginController release];
    }
}

- (void) createNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusRetrieved:) name:kTwitterStatusRetrievedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTweetNotification:) name:IFTweetLabelURLNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showStatuses) name:kTwitterLoginNotificationKey object:nil];
}

- (void) showStatuses {
    [loginController removeFromSupercontroller];
    NSNumber *startAtId = [NSNumber numberWithInt:0];
    tweets = [[NSMutableArray alloc] initWithArray:[[KBTwitterManager twitterManager] retrieveCachedStatusArrayWithKey:cachingKey]];
    if (tweets != nil && [tweets count] > 0) {
        startAtId = ((KBTweet*)[tweets objectAtIndex:0]).tweetId;
//        NSLog(@"cached tweets: %@", tweets);
//        NSLog(@"max id: %qu", [startAtId longLongValue]);
        [theTableView reloadData];
    }
    [self startProgressBar:@"Retrieving your tweets..."];
    [self.twitterEngine getFollowedTimelineSinceID:[startAtId longLongValue] startingAtPage:0 count:25];
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
                    [tempTweetArray addObject:[[KBTweet alloc] initWithDictionary:dict]];
                }
                // not very pretty, but it gets the job done. if there is a cached array, combine them.
                // the other way to do it would be to just add all the objects (above) by index
                if (!tweets) {
                    tweets = [[NSMutableArray alloc] initWithArray:tempTweetArray];
                } else {
                    // need to keep all the tweets in the right order
                    [tempTweetArray addObjectsFromArray:tweets];
                    tweets = nil;
                    [tweets release];
                    tweets = [[NSMutableArray alloc] initWithArray:tempTweetArray];
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

#pragma mark -
#pragma mark MGTwitterEngineDelegate methods

- (void)requestSucceeded:(NSString *)connectionIdentifier
{
	NSLog(@"Twitter request succeeded: %@", connectionIdentifier);
	
	UIAlertViewQuick(@"Tweet sent!", @"The tweet was successfully sent. Everything works!", @"OK");
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
	NSLog(@"Twitter request failed: %@ with error:%@", connectionIdentifier, error);
    
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [statuses release];
    [statusObjects release];
    [tweets release];
    [super dealloc];
}


@end

