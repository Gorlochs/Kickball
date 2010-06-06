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
#import "IFTweetLabel.h"
#import "KBTwitterManagerDelegate.h"
#import "KBUserTweetsViewController.h"
#import "KBTwitterUserListViewController.h"


@interface KBTwitterProfileViewController : KBTwitterViewController <KBTwitterManagerDelegate> {
    IBOutlet UILabel *screenNameLabel;
    IBOutlet UILabel *fullName;
    IBOutlet UILabel *location;
    IBOutlet UILabel *numberOfFollowers;
    IBOutlet UILabel *numberOfFriends;
    IFTweetLabel *description;
    TTImageView *userIcon;
    UIImageView *iconBgImage;
    
    NSString *screenname;
    NSDictionary *userDictionary;
	KBTwitterManager *twitterManager;
    
    KBTwitterUserListViewController *followersController;
    KBTwitterUserListViewController *friendsController;
    KBUserTweetsViewController *recentTweetsController;
}

@property (nonatomic, retain) NSString *screenname;

- (IBAction) viewRecentTweets;
- (IBAction) viewFollowers;
- (IBAction) viewFriends;

@end
