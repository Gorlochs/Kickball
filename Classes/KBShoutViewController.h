//
//  KBShoutViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 1/7/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractPushNotificationViewController.h"

@interface KBShoutViewController : AbstractPushNotificationViewController <UITextViewDelegate> {
    IBOutlet UITextView *theTextView;
    NSString *venueId;
    IBOutlet UIView *checkinView;
    IBOutlet UIView *nonCheckinView;
    IBOutlet UILabel *characterCountLabel;
    BOOL isCheckin;
}

@property (nonatomic, retain) NSString *venueId;
@property (nonatomic) BOOL isCheckin;

- (IBAction) shout;
- (IBAction) shoutAndTweet;
- (IBAction) shoutAndCheckin;
- (IBAction) shoutAndTweetAndCheckin;
- (IBAction) cancelView;
- (void) closeUpShop;

@end
