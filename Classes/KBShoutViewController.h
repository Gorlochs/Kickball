//
//  KBShoutViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 1/7/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractPushNotificationViewController.h"
#import "XAuthTwitterEngine.h"
#import "MGTwitterEngineDelegate.h"


@interface KBShoutViewController : AbstractPushNotificationViewController <UITextViewDelegate, MGTwitterEngineDelegate> {
    IBOutlet UITextView *theTextView;
    NSString *venueId;
    IBOutlet UIView *checkinView;
    IBOutlet UIView *nonCheckinView;
    IBOutlet UILabel *characterCountLabel;
    BOOL isCheckin;
    
    BOOL isTwitterOn;
    BOOL isFacebookOn;
    IBOutlet UIButton *twitterButton;
    IBOutlet UIButton *facebookButton;
    XAuthTwitterEngine *twitterEngine;
    BOOL isReadyToClose;
}

@property (nonatomic, retain) XAuthTwitterEngine *twitterEngine;
@property (nonatomic, retain) NSString *venueId;
@property (nonatomic) BOOL isCheckin;

- (IBAction) shout;
- (IBAction) shoutAndTweet;
- (IBAction) shoutAndCheckin;
- (IBAction) shoutAndTweetAndCheckin;
- (IBAction) cancelView;
- (IBAction) toggleTwitter;
- (IBAction) toggleFacebook;
- (void) closeUpShop;
- (void) statusRetrieved:(NSNotification *)inNotification;

@end
