//
//  KBTwitterDetailViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/20/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTwitterDetailViewController.h"
#import "KickballAPI.h"
#import "KBCreateTweetViewController.h"
#import "KBTwitterProfileViewController.h"
#import "KBTwitterUserListViewController.h"
#import "KBTwitterFavsViewController.h"
#import "KBTwitterSearchViewController.h"
#import "KBDirectMessage.h"


@implementation KBTwitterDetailViewController

@synthesize tweet, tweets;

- (void)viewDidLoad {
    pageType = KBPageTypeOther;
    [super viewDidLoad];
	[self startProgressBar:@"Retrieving Info"];
    numberOfFollowers.text = @"";
    numberOfFriends.text = @"";
    numberOfFavorites.text = @"";
    numberOfTweets.text = @"";
    userDictionary = nil;
    [timelineButton setImage:[UIImage imageNamed:@"tabTweets03.png"] forState:UIControlStateNormal];
    [mentionsButton setImage:[UIImage imageNamed:@"tabMentions03.png"] forState:UIControlStateNormal];
    [directMessageButton setImage:[UIImage imageNamed:@"tabDM03.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"tabSearch03.png"] forState:UIControlStateNormal];
    NSLog(@"tweet: %@", tweet);
    screenName.text = tweet.screenName;
    fullName.text = tweet.fullName;
	twitterClient.text = @"";
	if (tweet.clientName) {
		twitterClient.text = tweet.clientName;
	}
	
	if ([tweet isKindOfClass:[KBDirectMessage class]]) {
		[replyToTweetButton setImage:[UIImage imageNamed:@"btn-directMsg01.png"] forState:UIControlStateNormal];
		[replyToTweetButton setImage:[UIImage imageNamed:@"btn-directMsg02.png"] forState:UIControlStateHighlighted];
		retweetButton.enabled = NO;
		favoriteButton.enabled = NO;
	}
	
	TTStyledTextLabel* label1 = [[TTStyledTextLabel alloc] initWithFrame:CGRectMake(6, 125, 300, 100)];
	label1.font = [UIFont fontWithName:@"Helvetica" size:14.0];
	label1.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
	label1.text = [TTStyledText textWithURLs:tweet.tweetText lineBreaks:NO];
	label1.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
	label1.backgroundColor = [UIColor clearColor];	
	[label1 sizeToFit];
	[label1 setNeedsLayout];
	[self.view addSubview:label1];
    [label1 release];
	
    CGRect frame = CGRectMake(17, 67, 33, 34);
    TTImageView *userProfileImage = [[TTImageView alloc] initWithFrame:frame];
    userProfileImage.backgroundColor = [UIColor clearColor];
    userProfileImage.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
    userProfileImage.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
    userProfileImage.urlPath = tweet.profileImageUrl;
    [self.view addSubview:userProfileImage];
    [userProfileImage release];
    
    timeLabel.text = [[KickballAPI kickballApi] convertDateToTimeUnitString:tweet.createDate];
	isFavorited = tweet.isFavorited;
	if (isFavorited) {
		[favoriteButton setImage:[UIImage imageNamed:@"btn-favorite02.png"] forState:UIControlStateNormal];
	} else {
		[favoriteButton setImage:[UIImage imageNamed:@"btn-favorite01.png"] forState:UIControlStateNormal];
	}
    twitterManager = [KBTwitterManager twitterManager];
	twitterManager.delegate = self;
	
    [twitterEngine getUserInformationFor:tweet.screenName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTweetNotification:) name:IFTweetLabelURLNotification object:nil];
    _isObservingNotifications = true;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_isObservingNotifications) {
		_isObservingNotifications = true;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTweetNotification:) name:IFTweetLabelURLNotification object:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _isObservingNotifications = false;
}

- (IBAction) viewRecentTweets {
    if (![userDictionary objectForKey:@"screen_name"]) return;
	KBUserTweetsViewController *recentTweetsController = [[KBUserTweetsViewController alloc] initWithNibName:@"KBUserTweetsViewController" bundle:nil];
    recentTweetsController.userDictionary = userDictionary;
    recentTweetsController.username = [userDictionary objectForKey:@"screen_name"];
	[self checkMemoryUsage];
	[self.navigationController pushViewController:recentTweetsController animated:YES];
    [recentTweetsController release];
}

- (IBAction) viewFavorites {
    if (![userDictionary objectForKey:@"screen_name"]) return;
    if ([numberOfFavorites.text isEqualToString:@""] || [numberOfFavorites.text isEqualToString:@"0"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"This user has no favorites." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
	KBTwitterFavsViewController *favTweets = [[KBTwitterFavsViewController alloc] initWithNibName:@"KBTwitterFavsViewController" bundle:nil];
    favTweets.userDictionary = userDictionary;
	favTweets.username = [userDictionary objectForKey:@"screen_name"];
	[self checkMemoryUsage];
	[self.navigationController pushViewController:favTweets animated:YES];
	[favTweets release];
}

- (IBAction) viewFollowers {
    if (![userDictionary objectForKey:@"screen_name"]) return;
	KBTwitterUserListViewController *followersController = [[KBTwitterUserListViewController alloc] initWithNibName:@"KBTwitterUserListViewController" bundle:nil];
    followersController.userDictionary = userDictionary;
    followersController.userType = KBTwitterUserFollower;
	[self checkMemoryUsage];
	[self.navigationController pushViewController:followersController animated:YES];
    [followersController release];
}

- (IBAction) viewFriends {
    if (![userDictionary objectForKey:@"screen_name"]) return;
	KBTwitterUserListViewController *friendsController = [[KBTwitterUserListViewController alloc] initWithNibName:@"KBTwitterUserListViewController" bundle:nil];
    friendsController.userDictionary = userDictionary;
    friendsController.userType = KBTwitterUserFriend;
	[self checkMemoryUsage];
	[self.navigationController pushViewController:friendsController animated:YES];
    [friendsController release];
}

- (void)userInfoReceived:(NSArray *)userInfo {
    userDictionary = [[userInfo objectAtIndex:0] copy];
    numberOfFriends.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"friends_count"] intValue]];
    numberOfFollowers.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"followers_count"] intValue]];
    numberOfTweets.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"statuses_count"] intValue]];
    numberOfFavorites.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"favourites_count"] intValue]];
    [self stopProgressBar];
}

- (void) retweet {
	KBCreateTweetViewController *createRetweetViewController = [[KBCreateTweetViewController alloc] initWithNibName:@"KBCreateTweetViewController" bundle:nil];
    createRetweetViewController.replyToStatusId = tweet.tweetId;
    createRetweetViewController.replyToScreenName = tweet.screenName;
    createRetweetViewController.retweetTweetText = tweet.tweetText;
	[self.navigationController pushViewController:createRetweetViewController animated:YES];
	[createRetweetViewController release];
}

- (void) reply {
	KBCreateTweetViewController *createReplyViewController = [[KBCreateTweetViewController alloc] initWithNibName:@"KBCreateTweetViewController" bundle:nil];
    createReplyViewController.replyToStatusId = tweet.tweetId;
	if ([tweet isKindOfClass:[KBDirectMessage class]]) {
		createReplyViewController.directMentionToScreenname = tweet.screenName;
	} else {
		createReplyViewController.replyToScreenName = tweet.screenName;
	}
	[self.navigationController pushViewController:createReplyViewController animated:YES];
	[createReplyViewController release];
}

- (void)saveTweets {
    for (KBTweet *cur in (NSArray*)tweets) { //prep to cache the new tweet favorite status
        if (cur.tweetId == tweet.tweetId) {
            cur.isFavorited = tweet.isFavorited;  
        }
    }
    [[KBTwitterManager twitterManager] cacheStatusArray:tweets withKey:kKBTwitterTimelineKey];
	if (isFavorited) {
		[favoriteButton setImage:[UIImage imageNamed:@"btn-favorite02.png"] forState:UIControlStateNormal];
	} else {
		[favoriteButton setImage:[UIImage imageNamed:@"btn-favorite01.png"] forState:UIControlStateNormal];
	}
}

- (void)handleTweetNotification:(NSNotification *)notification {
	DLog(@"handleTweetNotification: notification = %@", notification);
    NSMutableString *nObject = [[NSMutableString alloc] initWithString:[notification object]];
	NSArray *strippedChars = [NSArray arrayWithObjects:@":",@";",@"!",@",",@"?",@"\"",@"'",@".",nil];
	for (NSString *badChar in strippedChars) {
		[nObject replaceOccurrencesOfString:badChar withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [nObject length])];
	}
    if ([[notification object] rangeOfString:@"@"].location == 0) {
        KBUserTweetsViewController *userTweetsController = [[KBUserTweetsViewController alloc] initWithNibName:@"KBUserTweetsViewController" bundle:nil];
        userTweetsController.username = nObject;
		[self checkMemoryUsage];
        [self.navigationController pushViewController:userTweetsController animated:YES];
		[userTweetsController release];
    } else if ([[notification object] rangeOfString:@"#"].location == 0) {
        [[KBTwitterManager twitterManager] setSearchTerm:nil];
        KBTwitterSearchViewController *searchController = [[KBTwitterSearchViewController alloc] initWithNibName:@"KBTwitterSearchViewController" bundle:nil];
        //NSMutableString *search = [[NSMutableString alloc] initWithString:[notification object]];
        searchController.searchTerms = nObject;
		[self checkMemoryUsage];
        [self.navigationController pushViewController:searchController animated:YES];
		[searchController release];
    } else {
		DLog(@"pushing webview");
        // TODO: push properly styled web view
        [self openWebView:[notification object]];
    }
    [nObject release];
}


- (void) favorite {
	isFavorited = !isFavorited;
	[twitterEngine markUpdate:[tweet.tweetId longLongValue] asFavorite:isFavorited];
	tweet.isFavorited = isFavorited;
	[self saveTweets]; //the server only responds 50-75% of the time when you favorite, and responds incorrectly in some cases.  this will bring the probability of success to 95%
}

- (void)statusesReceived:(NSArray *)statuses {
	for (NSDictionary *tweetDict in statuses) {
		tweet.isFavorited = isFavorited = [[tweetDict objectForKey:@"favorited"] boolValue];
	}
	[self stopProgressBar];
	[self saveTweets];
}

- (void) viewOtherUserProfile {
	KBTwitterProfileViewController *twitterProfileController = [[KBTwitterProfileViewController alloc] initWithNibName:@"KBTwitterProfileViewController" bundle:nil];
    twitterProfileController.screenname = tweet.screenName;
	[self checkMemoryUsage];
	[self.navigationController pushViewController:twitterProfileController animated:YES];
	[twitterProfileController release];
}

- (void)dealloc {
	//twitterManager.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[userDictionary release];
    [tweet release];
    [tweets release];  
    [super dealloc];
}

@end
