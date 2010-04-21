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
    
    IBOutlet UILabel *screenName;
    IBOutlet UILabel *fullName;
    IBOutlet UILabel *timeLabel;
    IBOutlet UIButton *retweetButton;
    IBOutlet UIButton *replyButton;
    IBOutlet UIButton *forwardButton;
    
    IFTweetLabel *mainTextLabel;
    TTImageView *userProfileImage;
}

@property (nonatomic, retain) KBTweet *tweet;

- (IBAction) retweet;
- (IBAction) reply;
- (IBAction) viewUserProfile;

@end
