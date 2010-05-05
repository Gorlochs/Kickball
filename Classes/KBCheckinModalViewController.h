//
//  KBCheckinModalViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 5/5/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractPushNotificationViewController.h"
#import "XAuthTwitterEngine.h"
#import "MGTwitterEngineDelegate.h"


@interface KBCheckinModalViewController : AbstractPushNotificationViewController <UITextFieldDelegate, MGTwitterEngineDelegate> {
    NSString *venueId;
    IBOutlet UILabel *characterCountLabel;
    
    BOOL isTwitterOn;
    BOOL isFacebookOn;
    BOOL isFoursquareOn;
    IBOutlet UIButton *twitterButton;
    IBOutlet UIButton *facebookButton;
    IBOutlet UIButton *foursquareButton;
    IBOutlet UIButton *checkinButton;
    IBOutlet UITextField *checkinTextField;
    
    XAuthTwitterEngine *twitterEngine;
    BOOL isReadyToClose;
}

@property (nonatomic, retain) XAuthTwitterEngine *twitterEngine;
@property (nonatomic, retain) NSString *venueId;

- (IBAction) shout;
- (IBAction) cancelView;
- (IBAction) toggleTwitter;
- (IBAction) toggleFacebook;
- (IBAction) toggleFoursquare;
- (void) closeUpShop;
- (void) statusRetrieved:(NSNotification *)inNotification;

@end
