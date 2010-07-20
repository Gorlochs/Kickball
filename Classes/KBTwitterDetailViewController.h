//
//  KBTwitterDetailViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/20/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "KBTwitterViewController.h"
#import "IFTweetLabel.h"
#import "KBTweet.h"


@interface KBTwitterDetailViewController : KBTwitterViewController {
    KBTweet *tweet;
    NSMutableArray *tweets; //for re-caching the tweets when the user favorites one
    IBOutlet UILabel *screenName;
    IBOutlet UILabel *fullName;
    IBOutlet UILabel *timeLabel;
    IBOutlet UIButton *retweetButton;
    IBOutlet UIButton *replyButton;
    IBOutlet UIButton *forwardButton;
	IBOutlet UILabel *twitterClient;
	IBOutlet UIButton *favoriteButton;
    IBOutlet UILabel *numberOfFollowers;
    IBOutlet UILabel *numberOfFriends;
    IBOutlet UILabel *numberOfFavorites;
    IBOutlet UILabel *numberOfTweets;
    
    //IFTweetLabel *mainTextLabel;
    NSDictionary *userDictionary;
	
	BOOL isFavorited;
    BOOL _isObservingNotifications;
}

@property (nonatomic, retain) KBTweet *tweet;
@property (nonatomic, retain) NSMutableArray *tweets;

- (IBAction) retweet;
- (IBAction) reply;
- (IBAction) favorite;
- (IBAction) viewUserProfile;
- (IBAction) viewRecentTweets;
- (IBAction) viewFollowers;
- (IBAction) viewFriends;
- (IBAction) viewFavorites;

@end
