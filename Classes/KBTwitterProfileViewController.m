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


@implementation KBTwitterProfileViewController

@synthesize screenname;

- (void)viewDidLoad {
    screenNameLabel.text = @"";
    fullName.text = @"";
    location.text = @"";
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
    
    DLog(@"userInfo: %@", userInfo);
    userDictionary = [[userInfo objectAtIndex:0] retain];
    screenNameLabel.text = [userDictionary objectForKey:@"screen_name"];
    fullName.text = [userDictionary objectForKey:@"name"];
    location.text = [userDictionary objectForKey:@"location"];
    numberOfFriends.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"friends_count"] intValue]];
    numberOfFollowers.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"followers_count"] intValue]];
    numberOfTweets.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"statuses_count"] intValue]];
    numberOfFavorites.text = [NSString stringWithFormat:@"%d", [[[userDictionary objectForKey:@"status"] objectForKey:@"favorited"] intValue]];
    
    description.font = [UIFont fontWithName:@"Georgia" size:12.0];
    description.text = [userDictionary objectForKey:@"description"];
    
    CGRect frame = CGRectMake(13, 65, 39, 39);
    userIcon = [[TTImageView alloc] initWithFrame:frame];
    userIcon.backgroundColor = [UIColor clearColor];
    userIcon.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
    userIcon.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
    userIcon.urlPath = [userDictionary objectForKey:@"profile_image_url"];
    [self.view addSubview:userIcon];
    
    iconBgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellIconBorder.png"]];
    iconBgImage.frame = CGRectMake(11, 63, 43, 43);
    [self.view addSubview:iconBgImage];
	
	if ([[userDictionary objectForKey:@"following"] boolValue]) {
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
	recentTweetsController = [[KBUserTweetsViewController alloc] initWithNibName:@"KBUserTweetsViewController" bundle:nil];
    recentTweetsController.userDictionary = userDictionary;
    recentTweetsController.username = [userDictionary objectForKey:@"screen_name"];
	[self.navigationController pushViewController:recentTweetsController animated:YES];
}

- (void) viewFollowers {
	followersController = [[KBTwitterUserListViewController alloc] initWithNibName:@"KBTwitterUserListViewController" bundle:nil];
    followersController.userDictionary = userDictionary;
    followersController.userType = KBTwitterUserFollower;
	[self.navigationController pushViewController:followersController animated:YES];
}

- (void) viewFriends {
	friendsController = [[KBTwitterUserListViewController alloc] initWithNibName:@"KBTwitterUserListViewController" bundle:nil];
    friendsController.userDictionary = userDictionary;
    friendsController.userType = KBTwitterUserFriend;
	[self.navigationController pushViewController:friendsController animated:YES];
}

- (void) follow {
	[twitterEngine enableUpdatesFor:screenname];
}

- (void) unfollow {
	[twitterEngine disableUpdatesFor:screenname];
}

- (void) sendDirectMessage {
    tweetController = [[KBCreateTweetViewController alloc] initWithNibName:@"KBCreateTweetViewController" bundle:nil];
	tweetController.directMentionToScreenname = screenname;
    [self presentModalViewController:tweetController animated:YES];
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
    
    [userIcon release];
    [iconBgImage release];
    
    [screenname release];
    [userDictionary release];
    [twitterManager release];
    
    [recentTweetsController release];
    [friendsController release];
    [followersController release];
    [super dealloc];
}


@end
