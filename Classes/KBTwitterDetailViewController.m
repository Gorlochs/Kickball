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


@implementation KBTwitterDetailViewController

@synthesize tweet;
@synthesize tweets;

- (IBAction) viewRecentTweets {
	KBUserTweetsViewController *recentTweetsController = [[KBUserTweetsViewController alloc] initWithNibName:@"KBUserTweetsViewController" bundle:nil];
    recentTweetsController.userDictionary = [userDictionary retain];
    recentTweetsController.username = [userDictionary objectForKey:@"screen_name"];
	[self.navigationController pushViewController:recentTweetsController animated:YES];
    [recentTweetsController release];
}

- (IBAction) viewFavorites {
  KBTwitterFavsViewController *favTweets = [[KBTwitterFavsViewController alloc] initWithNibName:@"KBTwitterFavsViewController" bundle:nil];
  favTweets.userDictionary = [userDictionary retain];
  favTweets.username = [userDictionary objectForKey:@"screen_name"];
  [self.navigationController pushViewController:favTweets animated:YES];
  [favTweets release];
}

- (IBAction) viewFollowers {
	KBTwitterUserListViewController *followersController = [[KBTwitterUserListViewController alloc] initWithNibName:@"KBTwitterUserListViewController" bundle:nil];
    followersController.userDictionary = [userDictionary retain];
    followersController.userType = KBTwitterUserFollower;
	[self.navigationController pushViewController:followersController animated:YES];
    [followersController release];
}

- (IBAction) viewFriends {
	KBTwitterUserListViewController *friendsController = [[KBTwitterUserListViewController alloc] initWithNibName:@"KBTwitterUserListViewController" bundle:nil];
    friendsController.userDictionary = [userDictionary retain];
    friendsController.userType = KBTwitterUserFriend;
	[self.navigationController pushViewController:friendsController animated:YES];
    [friendsController release];
}

- (void)userInfoReceived:(NSArray *)userInfo {
    userDictionary = [[userInfo objectAtIndex:0] retain];
    numberOfFriends.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"friends_count"] intValue]];
    numberOfFollowers.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"followers_count"] intValue]];
    numberOfTweets.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"statuses_count"] intValue]];
    numberOfFavorites.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"favourites_count"] intValue]];
    [self stopProgressBar];
}

- (void)viewDidLoad {
    DLog(@"--------------------------------------------------------- loaded twitter detail");
    pageType = KBPageTypeOther;
    
    [super viewDidLoad];

    numberOfFollowers.text = @"";
    numberOfFriends.text = @"";
    numberOfFavorites.text = @"";
    numberOfTweets.text = @"";
    
    [timelineButton setImage:[UIImage imageNamed:@"tabTweets03.png"] forState:UIControlStateNormal];
    [mentionsButton setImage:[UIImage imageNamed:@"tabMentions03.png"] forState:UIControlStateNormal];
    [directMessageButton setImage:[UIImage imageNamed:@"tabDM03.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"tabSearch03.png"] forState:UIControlStateNormal];
    
    screenName.text = tweet.screenName;
    fullName.text = tweet.fullName;
	
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
	
	/*
    mainTextLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake(20, 105, 270, 100)];
    mainTextLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    mainTextLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    mainTextLabel.backgroundColor = [UIColor clearColor];
    mainTextLabel.linksEnabled = YES;
    mainTextLabel.numberOfLines = 0;
    //tweetText.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    //tweetText.shadowOffset = CGSizeMake(1.0, 1.0);
    mainTextLabel.text = tweet.tweetText;
    [self.view addSubview:mainTextLabel];
     
	 */
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
    createReplyViewController.replyToScreenName = tweet.screenName;
	[self.navigationController pushViewController:createReplyViewController animated:YES];
	[createReplyViewController release];
}

- (void)saveTweets {
    for (KBTweet *cur in (NSArray*)tweets) { //prep to cache the new tweet favorite status
        if (cur.tweetId == tweet.tweetId) {
            cur.isFavorited = tweet.isFavorited;  
        }
    }
    //NSMutableArray *tempTweetArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray*)tweets count]];
    //[tempTweetArray addObjectsFromArray:(NSArray*)tweets];
    //[[KBTwitterManager twitterManager] cacheStatusArray:tempTweetArray withKey:kKBTwitterTimelineKey];
    //[tempTweetArray release];
    [[KBTwitterManager twitterManager] cacheStatusArray:tweets withKey:kKBTwitterTimelineKey];
	if (isFavorited) {
		[favoriteButton setImage:[UIImage imageNamed:@"btn-favorite02.png"] forState:UIControlStateNormal];
	} else {
		[favoriteButton setImage:[UIImage imageNamed:@"btn-favorite01.png"] forState:UIControlStateNormal];
	}
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
  [self saveTweets];
}

- (void) viewUserProfile {
	KBTwitterProfileViewController *twitterProfileController = [[KBTwitterProfileViewController alloc] initWithNibName:@"KBTwitterProfileViewController" bundle:nil];
    twitterProfileController.screenname = tweet.screenName;
	[self.navigationController pushViewController:twitterProfileController animated:YES];
	[twitterProfileController release];
}

- (void)dealloc {
    [tweet release];
    [tweets release];  
    [super dealloc];
}

@end
