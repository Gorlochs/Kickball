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
    
	DLog("tweet detail: %@", self.tweet);
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
    //timeLabel.text = self.tweet.createDate;
	
	TTStyledTextLabel* label1 = [[[TTStyledTextLabel alloc] initWithFrame:CGRectMake(6, 125, 300, 100)] autorelease];
	label1.font = [UIFont fontWithName:@"Helvetica" size:14.0];
	label1.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
	label1.text = [TTStyledText textWithURLs:tweet.tweetText lineBreaks:NO];
	label1.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
	label1.backgroundColor = [UIColor clearColor];
	[label1 sizeToFit];
	[self.view addSubview:label1];
	
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
    userProfileImage = [[TTImageView alloc] initWithFrame:frame];
    userProfileImage.backgroundColor = [UIColor clearColor];
    userProfileImage.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
    userProfileImage.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
    userProfileImage.urlPath = tweet.profileImageUrl;
    [self.view addSubview:userProfileImage];
    
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

- (void) createNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusRetrieved:) name:kTwitterStatusRetrievedNotificationKey object:nil];
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

- (void) favorite {
	[twitterEngine markUpdate:[tweet.tweetId longLongValue] asFavorite:!isFavorited];
}

- (void)statusesReceived:(NSArray *)statuses {
  DLog(@"statusesreceived twitter detailview");
	isFavorited = !isFavorited;
	if (isFavorited) {
		[favoriteButton setImage:[UIImage imageNamed:@"btn-favorite02.png"] forState:UIControlStateNormal];
	} else {
		[favoriteButton setImage:[UIImage imageNamed:@"btn-favorite01.png"] forState:UIControlStateNormal];
	}
	DLog("favorite status: %@", statuses);
}

- (void) viewUserProfile {
	KBTwitterProfileViewController *twitterProfileController = [[KBTwitterProfileViewController alloc] initWithNibName:@"KBTwitterProfileViewController" bundle:nil];
    twitterProfileController.screenname = tweet.screenName;
	[self.navigationController pushViewController:twitterProfileController animated:YES];
	[twitterProfileController release];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tweet release];
    [userProfileImage release];
        
    [super dealloc];
}

@end
