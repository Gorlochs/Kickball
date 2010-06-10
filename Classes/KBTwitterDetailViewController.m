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


@implementation KBTwitterDetailViewController

@synthesize tweet;

- (void)viewDidLoad {
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messagesRetrieved:) name:kTwitterDMRetrievedNotificationKey object:nil];
    
    self.hideFooter = YES;
    pageType = KBPageTypeOther;
    
    [super viewDidLoad];
    
    [timelineButton setImage:[UIImage imageNamed:@"tabTweets03.png"] forState:UIControlStateNormal];
    [mentionsButton setImage:[UIImage imageNamed:@"tabMentions03.png"] forState:UIControlStateNormal];
    [directMessageButton setImage:[UIImage imageNamed:@"tabDM03.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"tabSearch03.png"] forState:UIControlStateNormal];
    
    screenName.text = tweet.screenName;
    fullName.text = tweet.fullName;
    //timeLabel.text = self.tweet.createDate;
    
	
	TTStyledTextLabel* label1 = [[[TTStyledTextLabel alloc] initWithFrame:CGRectMake(20, 105, 270, 100)] autorelease];
	label1.font = [UIFont fontWithName:@"Georgia" size:14.0];
	label1.text = [TTStyledText textWithURLs:tweet.tweetText lineBreaks:NO];
	label1.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
	label1.backgroundColor = [UIColor clearColor];
	[label1 sizeToFit];
	[self.view addSubview:label1];
	
	/*
    mainTextLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake(20, 105, 270, 100)];
    mainTextLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    mainTextLabel.font = [UIFont fontWithName:@"Georgia" size:13.0];
    mainTextLabel.backgroundColor = [UIColor clearColor];
    mainTextLabel.linksEnabled = YES;
    mainTextLabel.numberOfLines = 0;
    //tweetText.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    //tweetText.shadowOffset = CGSizeMake(1.0, 1.0);
    mainTextLabel.text = tweet.tweetText;
    [self.view addSubview:mainTextLabel];
     
	 */
    CGRect frame = CGRectMake(11, 53, 49, 49);
    userProfileImage = [[TTImageView alloc] initWithFrame:frame];
    userProfileImage.backgroundColor = [UIColor clearColor];
    userProfileImage.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
    userProfileImage.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
    userProfileImage.urlPath = tweet.profileImageUrl;
    [self.view addSubview:userProfileImage];
    
    timeLabel.text = [[KickballAPI kickballApi] convertDateToTimeUnitString:tweet.createDate];
}

- (void) createNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusRetrieved:) name:kTwitterStatusRetrievedNotificationKey object:nil];
}

- (void) retweet {
    //[twitterEngine sendRetweet:[tweet.tweetId longLongValue]];
	KBCreateTweetViewController *createRetweetViewController = [[KBCreateTweetViewController alloc] initWithNibName:@"KBCreateTweetViewController" bundle:nil];
    createRetweetViewController.replyToStatusId = tweet.tweetId;
    createRetweetViewController.replyToScreenName = tweet.screenName;
    createRetweetViewController.retweetTweetText = tweet.tweetText;
	[self presentModalViewController:createRetweetViewController animated:YES];
	[createRetweetViewController release];
}

- (void) reply {
	KBCreateTweetViewController *createReplyViewController = [[KBCreateTweetViewController alloc] initWithNibName:@"KBCreateTweetViewController" bundle:nil];
    createReplyViewController.replyToStatusId = tweet.tweetId;
    createReplyViewController.replyToScreenName = tweet.screenName;
	[self presentModalViewController:createReplyViewController animated:YES];
	[createReplyViewController release];
}

- (void) viewUserProfile {
	KBTwitterProfileViewController *witterProfileController = [[KBTwitterProfileViewController alloc] initWithNibName:@"KBTwitterProfileViewController" bundle:nil];
    twitterProfileController.screenname = tweet.screenName;
	[self.navigationController pushViewController:twitterProfileController animated:YES];
	[twitterProfileController release];
}

- (void) statusRetrieved:(NSNotification *)inNotification {
    DLog(@"********** RETWEET SUCCESSFUL!!!! **********");
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tweet release];
//    [screenName release];
//    [fullName release];
//    [timeLabel release];
//    [retweetButton release];
//    [replyButton release];
//    [forwardButton release];
    
    //[mainTextLabel release];
    [userProfileImage release];
    
    
    [super dealloc];
}

@end
