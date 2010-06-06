//
//  KBTwitterProfileViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTwitterProfileViewController.h"
#import "KBTwitterUserListViewController.h"

@implementation KBTwitterProfileViewController

@synthesize screenname;

- (void)viewDidLoad {
    screenNameLabel.text = @"";
    fullName.text = @"";
    location.text = @"";
    numberOfFriends.text = @"";
    numberOfFollowers.text = @"";
    
    pageType = KBPageTypeOther;
    [super viewDidLoad];
    
    twitterManager = [KBTwitterManager twitterManager];
	twitterManager.delegate = self;
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userRetrieved:) name:kTwitterUserInfoRetrievedNotificationKey object:nil];
    [self startProgressBar:@"Retrieving user information..."];
    [twitterEngine getUserInformationFor:screenname];
}

- (void)userInfoReceived:(NSArray *)userInfo {
    
//    NSLog(@"user inNotification: %@", inNotification);
//    NSLog(@"userInfo: %@", [inNotification userInfo]);
//    NSLog(@"userinfo userinfo: %@", [[inNotification userInfo] objectForKey:@"userInfo"]);
//    NSLog(@"userinfo userinfo object at index 0: %@", [[[inNotification userInfo] objectForKey:@"userInfo"] objectAtIndex:0]);
    userDictionary = [[userInfo objectAtIndex:0] retain];
    NSLog(@"user: %@", userDictionary);
    screenNameLabel.text = [userDictionary objectForKey:@"screen_name"];
    fullName.text = [userDictionary objectForKey:@"name"];
    location.text = [userDictionary objectForKey:@"location"];
    numberOfFriends.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"friends_count"] intValue]];
    numberOfFollowers.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"followers_count"] intValue]];
    
    description = [[IFTweetLabel alloc] initWithFrame:CGRectMake(12, 170, 300, 60)];
    description.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    description.font = [UIFont fontWithName:@"Georgia" size:12.0];
    description.backgroundColor = [UIColor clearColor];
    description.linksEnabled = YES;
    description.numberOfLines = 0;
    //tweetText.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    //tweetText.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.view addSubview:description];
    description.text = [userDictionary objectForKey:@"description"];
    
    CGSize maximumLabelSize = CGSizeMake(300,60);
    CGSize expectedLabelSize = [description.text sizeWithFont:description.font 
                                               constrainedToSize:maximumLabelSize 
                                                   lineBreakMode:UILineBreakModeTailTruncation]; 
    
    //adjust the label the the new height.
    CGRect newFrame = description.frame;
    newFrame.size.height = expectedLabelSize.height;
    description.frame = newFrame;
    
    CGRect frame = CGRectMake(8, 90, 49, 49);
    userIcon = [[TTImageView alloc] initWithFrame:frame];
    userIcon.backgroundColor = [UIColor clearColor];
    userIcon.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
    userIcon.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
    userIcon.urlPath = [userDictionary objectForKey:@"profile_image_url"];
    [self.view addSubview:userIcon];
    
    iconBgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellIconBorder.png"]];
    iconBgImage.frame = CGRectMake(6, 88, 54, 54);
    [self.view addSubview:iconBgImage];
    
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
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    [screenNameLabel release];
    [fullName release];
    [location release];
    [numberOfFollowers release];
    [numberOfFriends release];
    [description release];
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
