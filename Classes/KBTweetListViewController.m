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

- (void)didStartModalTweet {
	_inModalTweetView = YES;
}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
    if (_firstView) return;
    _firstView = true;
	
    twitterManager.delegate = self; //make sure we can keep appending more tweets when user scrolls to bottom
}

-(void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
	_firstView = false;
}

- (void)viewDidLoad {
	_firstView = true;
	[super viewDidLoad];
    twitterManager.delegate = self;
    _inModalTweetView = NO;
    pageNum = 1;
    cachingKey = [kKBTwitterTimelineKey retain];
    pageViewType = KBPageViewTypeList;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartModalTweet) name:@"didStartModalTweet" object:nil];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginCanceled) name:@"loginCanceled" object:nil];
    if ([self.twitterEngine isAuthorized]) {
		[self startProgressBar:@"Retrieving your tweets..."];
		[self showStatuses];
		
	} else {
		[self showLoginView];
    }
}

- (void)userInfoReceived:(NSArray *)userInfo {
    NSDictionary *userDictionary = [userInfo objectAtIndex:0];
	if (userDictionary) {
		NSString *profileImage = [userDictionary objectForKey:@"profile_image_url"];
		if (profileImage) {
			NSString *screenName = [userDictionary objectForKey:@"screen_name"];
			NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"twittername"];
			if (screenName && username && [screenName isEqualToString:username]) { //only use the profile pic for the user!!
				[[NSUserDefaults standardUserDefaults] setObject:profileImage forKey:@"twitUserPhotoURL"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				UIImage *twitterUserPic = [[Utilities sharedInstance] getCachedImage:profileImage];
				if (twitterUserPic) [signedInUserIcon setImage:twitterUserPic forState:UIControlStateNormal];
				[signedInUserIcon setEnabled:YES];
			}
		}
	}
}

- (void) loginCanceled {
    [self switchToFoursquare];
}

- (void) showStatuses {
    if (loginController) [loginController removeFromSupercontroller];
    NSNumber *startAtId = [NSNumber numberWithInt:0];
    if (tweets) [tweets release];
    tweets = [[NSMutableArray alloc] initWithArray:[[KBTwitterManager twitterManager] retrieveCachedStatusArrayWithKey:cachingKey]];
    if (tweets != nil && [tweets count] > 0) {
        startAtId = ((KBTweet*)[tweets objectAtIndex:0]).tweetId;
        [theTableView reloadData];
    }
	
	NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"twittername"];
	if (username) {
		[self.twitterEngine getUserInformationFor:username]; //get the twitter profile pic to save it
    }
	[self.twitterEngine getFollowedTimelineSinceID:[startAtId longLongValue] startingAtPage:0 count:25];
}

- (void)statusesReceived:(NSArray *)statuses {
	DLog(@"statuses: %@", statuses);
    if (_inModalTweetView) {
		[self.navigationController popViewControllerAnimated:YES];
		_inModalTweetView = NO;
    }
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
    }
	requeryWhenTableGetsToBottom = YES;
    [self stopProgressBar];
	[self dataSourceDidFinishLoadingNewData];
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
	DLog(@"Twitter request succeeded 2: %@", connectionIdentifier);
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error {
	DLog(@"Twitter request failed 5: %@ with error:%@", connectionIdentifier, error);
	[self stopProgressBar];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    DLog(@"got memory warning");
    // Relinquish ownership any cached data, images, etc that aren't in use.
    if (loginController) [loginController release];
    loginController = nil;
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	//twitterManager.delegate = nil;
    if (loginController) [loginController release];
    [super dealloc];
}


@end

