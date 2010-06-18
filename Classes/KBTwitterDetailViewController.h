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


@interface KBTwitterDetailViewController : KBTwitterViewController <KBTwitterManagerDelegate> {
    KBTweet *tweet;
    
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
    TTImageView *userProfileImage;
    NSDictionary *userDictionary;
	
	KBTwitterManager *twitterManager;
	BOOL isFavorited;
}

@property (nonatomic, retain) KBTweet *tweet;

- (IBAction) retweet;
- (IBAction) reply;
- (IBAction) favorite;
- (IBAction) viewUserProfile;

@end
