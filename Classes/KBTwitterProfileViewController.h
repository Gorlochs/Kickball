//
//  KBTwitterProfileViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "KBTwitterViewController.h"
#import "KBTwitterManagerDelegate.h"
#import "KBUserTweetsViewController.h"


@interface KBTwitterProfileViewController : KBTwitterViewController <KBTwitterManagerDelegate> {
    IBOutlet UILabel *screenNameLabel;
    IBOutlet UILabel *fullName;
    IBOutlet UILabel *location;
    IBOutlet UILabel *numberOfFollowers;
    IBOutlet UILabel *numberOfFriends;
    IBOutlet UILabel *numberOfFavorites;
    IBOutlet UILabel *numberOfTweets;
	IBOutlet UITextView *description;
	
	IBOutlet UIButton *followButton;
	IBOutlet UIButton *unfollowButton;
	IBOutlet UIButton *replyButton;
	IBOutlet UIButton *dmButton;
	
    TTImageView *userIcon;
    UIImageView *iconBgImage;
    
    NSString *screenname;
    NSDictionary *userDictionary;
	BOOL _didUnfollowUser;
}

@property (nonatomic, retain) NSString *screenname;

- (void)hideOwnUserButtons;
- (IBAction) viewFavorites;
- (IBAction) viewRecentTweets;
- (IBAction) viewFollowers;
- (IBAction) viewFriends;
- (IBAction) follow;
- (IBAction) unfollow;
- (IBAction) sendDirectMessage;
- (IBAction) sendTweet;

@end
