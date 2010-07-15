//
//  KBTwitterProfileViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTwitterProfileViewController.h"
#import "KBTwitterUserListViewController.h"
#import "KBCreateTweetViewController.h"
#import "KBTwitterFavsViewController.h"

@implementation KBTwitterProfileViewController

@synthesize screenname;

- (void)viewDidLoad {
    screenNameLabel.text = @"";
    fullName.text = @"";
    location.text = @"Not available";
    numberOfFriends.text = @"";
    numberOfFollowers.text = @"";
    numberOfTweets.text = @"";
    numberOfFavorites.text = @"";
	description.text = @"";
    
    pageType = KBPageTypeOther;
    [super viewDidLoad];
    
    twitterManager = [KBTwitterManager twitterManager];
	twitterManager.delegate = self;
    
    [self startProgressBar:@"Retrieving user information..."];
    [twitterEngine getUserInformationFor:screenname];
}

- (void)userInfoReceived:(NSArray *)userInfo {
    userDictionary = [[userInfo objectAtIndex:0] retain];
    screenNameLabel.text = [userDictionary objectForKey:@"screen_name"];
    fullName.text = [userDictionary objectForKey:@"name"];
    NSString *locationText = [userDictionary objectForKey:@"location"];
    if (![locationText isKindOfClass:[NSNull class]] && ![locationText isEqualToString:@""]) {
      location.text = locationText;
    }
    numberOfFriends.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"friends_count"] intValue]];
    numberOfFollowers.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"followers_count"] intValue]];
    numberOfTweets.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"statuses_count"] intValue]];
    numberOfFavorites.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"favourites_count"] intValue]];
	
    description.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    if (![[userDictionary objectForKey:@"description"] isKindOfClass:[NSNull class]]) {
      description.text = [userDictionary objectForKey:@"description"];
    }
    
    iconBgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitIconBG.png"]];
    iconBgImage.frame = CGRectMake(14, 63, 37, 38);
    [self.view addSubview:iconBgImage];
    
    CGRect frame = CGRectMake(16, 65, 33, 34);
    userIcon = [[TTImageView alloc] initWithFrame:frame];
    userIcon.backgroundColor = [UIColor clearColor];
    userIcon.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
    userIcon.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:3 topRight:3 bottomRight:3 bottomLeft:3] next:[TTContentStyle styleWithNext:nil]];
    userIcon.urlPath = [userDictionary objectForKey:@"profile_image_url"];
    [self.view addSubview:userIcon];
	
  if ([[userDictionary objectForKey:@"following"] isKindOfClass:[NSNull class]]) { //fix for crash
		followButton.hidden = NO;
		unfollowButton.hidden = YES;
	} else if ([[userDictionary objectForKey:@"following"] boolValue]) {
		followButton.hidden = YES;
		unfollowButton.hidden = NO;
	} else {
		followButton.hidden = NO;
		unfollowButton.hidden = YES;
	}

    [self stopProgressBar];
}

#pragma mark -
#pragma mark IBAction methods


- (void) viewRecentTweets {
	KBUserTweetsViewController *recentTweetsController = [[KBUserTweetsViewController alloc] initWithNibName:@"KBUserTweetsViewController" bundle:nil];
    recentTweetsController.userDictionary = [userDictionary retain];
    recentTweetsController.username = [userDictionary objectForKey:@"screen_name"];
	[self.navigationController pushViewController:recentTweetsController animated:YES];
    [recentTweetsController release];
}

- (void) viewFollowers {
	KBTwitterUserListViewController *followersController = [[KBTwitterUserListViewController alloc] initWithNibName:@"KBTwitterUserListViewController" bundle:nil];
    followersController.userDictionary = [userDictionary retain];
    followersController.userType = KBTwitterUserFollower;
	[self.navigationController pushViewController:followersController animated:YES];
    [followersController release];
}

- (IBAction) viewFavorites {
  KBTwitterFavsViewController *favTweets = [[KBTwitterFavsViewController alloc] initWithNibName:@"KBTwitterFavsViewController" bundle:nil];
  favTweets.userDictionary = [userDictionary retain];
  favTweets.username = [userDictionary objectForKey:@"screen_name"];
  [self.navigationController pushViewController:favTweets animated:YES];
  [favTweets release];
}

- (void) viewFriends {
	KBTwitterUserListViewController *friendsController = [[KBTwitterUserListViewController alloc] initWithNibName:@"KBTwitterUserListViewController" bundle:nil];
    friendsController.userDictionary = [userDictionary retain];
    friendsController.userType = KBTwitterUserFriend;
	[self.navigationController pushViewController:friendsController animated:YES];
    [friendsController release];
}

- (void) follow {
	[twitterEngine enableUpdatesFor:screenname];
}

- (void) unfollow {
	[twitterEngine disableUpdatesFor:screenname];
}

- (void) sendDirectMessage {
    KBCreateTweetViewController *tweetController = [[KBCreateTweetViewController alloc] initWithNibName:@"KBCreateTweetViewController" bundle:nil];
	tweetController.directMentionToScreenname = screenname;
	[self.navigationController pushViewController:tweetController animated:YES];
	[tweetController release];
}

- (void) sendTweet {
    KBCreateTweetViewController *tweetController = [[KBCreateTweetViewController alloc] initWithNibName:@"KBCreateTweetViewController" bundle:nil];
	tweetController.replyToScreenName = screenname;
	[self.navigationController pushViewController:tweetController animated:YES];
	[tweetController release];
}

#pragma mark -
#pragma mark memory management

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
//    [screenNameLabel release];
//    [fullName release];
//    [location release];
//    [numberOfFollowers release];
//    [numberOfFriends release];
//    [numberOfFavorites release];
//    [numberOfTweets release];
//    [description release];
    
    if (userIcon) [userIcon release];
    if (iconBgImage) [iconBgImage release];
    
    [screenname release];
    if (userDictionary) [userDictionary release];
    
    [super dealloc];
}


@end
