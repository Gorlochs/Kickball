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
#import "Utilities.h"

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
	[self startProgressBar:@""];
    
    twitterManager = [KBTwitterManager twitterManager];
	twitterManager.delegate = self;
    
    [twitterEngine getUserInformationFor:screenname];


    [self hideOwnUserButtons];	
}

- (void)hideOwnUserButtons {
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"twittername"];
    if ([screenname isEqualToString:username]) {
		[followButton setHidden:YES];
		[unfollowButton setHidden:YES];
	}
}

- (void)userInfoReceived:(NSArray *)userInfo {
    userDictionary = [[userInfo objectAtIndex:0] retain];
    screenNameLabel.text = [Utilities safeString:[userDictionary objectForKey:@"screen_name"]];
    fullName.text = [Utilities safeString:[userDictionary objectForKey:@"name"]];
    NSString *locationText = [Utilities safeString:[userDictionary objectForKey:@"location"]];
    if (![locationText isEqualToString:@""]) location.text = locationText;
    numberOfFriends.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"friends_count"] intValue]];
    numberOfFollowers.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"followers_count"] intValue]];
    numberOfTweets.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"statuses_count"] intValue]];
    numberOfFavorites.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"favourites_count"] intValue]];
	
    description.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    description.text = [Utilities safeString:[userDictionary objectForKey:@"description"]];
    
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
	} else if ([[userDictionary objectForKey:@"following"] boolValue]) { //TWITTER BUG: when you unfollow someone, the server returns true whether it is really true or not!!!
		if (!_didUnfollowUser) {
			followButton.hidden = YES;
			unfollowButton.hidden = NO;
		}
	} else {
		followButton.hidden = NO;
		unfollowButton.hidden = YES;
	}
    [self hideOwnUserButtons];
    [self stopProgressBar];
	_didUnfollowUser = NO;
}

#pragma mark -
#pragma mark IBAction methods


- (void) viewRecentTweets {
    if (![userDictionary objectForKey:@"screen_name"]) return;
	KBUserTweetsViewController *recentTweetsController = [[KBUserTweetsViewController alloc] initWithNibName:@"KBUserTweetsViewController" bundle:nil];
    recentTweetsController.userDictionary = userDictionary;
    recentTweetsController.username = [userDictionary objectForKey:@"screen_name"];
	[self.navigationController pushViewController:recentTweetsController animated:YES];
    [recentTweetsController release];
}

- (void) viewFollowers {
    if (![userDictionary objectForKey:@"screen_name"]) return;
	KBTwitterUserListViewController *followersController = [[KBTwitterUserListViewController alloc] initWithNibName:@"KBTwitterUserListViewController" bundle:nil];
    followersController.userDictionary = userDictionary;
    followersController.userType = KBTwitterUserFollower;
	[self.navigationController pushViewController:followersController animated:YES];
    [followersController release];
}

- (IBAction) viewFavorites {
    if ([numberOfFavorites.text isEqualToString:@""] || [numberOfFavorites.text isEqualToString:@"0"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"This user has no favorites." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    KBTwitterFavsViewController *favTweets = [[KBTwitterFavsViewController alloc] initWithNibName:@"KBTwitterFavsViewController" bundle:nil];
    favTweets.userDictionary = userDictionary;
    favTweets.username = [userDictionary objectForKey:@"screen_name"];
    [self.navigationController pushViewController:favTweets animated:YES];
    [favTweets release];
}

- (void) viewFriends {
    if (![userDictionary objectForKey:@"screen_name"]) return;
	KBTwitterUserListViewController *friendsController = [[KBTwitterUserListViewController alloc] initWithNibName:@"KBTwitterUserListViewController" bundle:nil];
    friendsController.userDictionary = userDictionary;
    friendsController.userType = KBTwitterUserFriend;
	[self.navigationController pushViewController:friendsController animated:YES];
    [friendsController release];
}

- (void) follow {
	_didUnfollowUser = NO;
    unfollowButton.hidden = NO;
    followButton.hidden = YES;
	[twitterEngine enableUpdatesFor:screenname];
}

- (void) unfollow {
    _didUnfollowUser = YES;
    followButton.hidden = NO;
    unfollowButton.hidden = YES;
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
    if (userIcon) [userIcon release];
    if (iconBgImage) [iconBgImage release];
    
    [screenname release];
    if (userDictionary) [userDictionary release];
    
    [super dealloc];
}


@end
