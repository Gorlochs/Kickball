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


@interface KBTwitterProfileViewController : KBTwitterViewController {
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
}

@property (nonatomic, retain) NSString *screenname;

- (IBAction) viewRecentTweets;
- (IBAction) viewFollowers;
- (IBAction) viewFriends;

@end
