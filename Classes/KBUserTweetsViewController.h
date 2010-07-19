//
//  KBUserTweetsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/20/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBTweetListViewController.h"


@interface KBUserTweetsViewController : KBTweetListViewController {
    NSDictionary *userDictionary;
    NSString *username;
    IBOutlet UILabel *screenNameLabel;
    IBOutlet UILabel *fullName;
    IBOutlet UILabel *location;
    BOOL _tweetsFirstView;
}

@property (nonatomic, retain) NSDictionary *userDictionary;
@property (nonatomic, retain) NSString *username;

- (IBAction) sendDirectMessage;
- (IBAction) sendTweet;

@end
