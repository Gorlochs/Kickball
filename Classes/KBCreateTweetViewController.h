//
//  KBCreateTweetViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractFacebookViewController.h"


@interface KBCreateTweetViewController : AbstractFacebookViewController <UITextViewDelegate, MGTwitterEngineDelegate> {
    IBOutlet UITextView *tweetTextView;
    IBOutlet UILabel *characterCountLabel;
    IBOutlet UIButton *sendTweet;
    IBOutlet UIButton *cancel;
    
    NSNumber *replyToStatusId;
    NSString *replyToScreenName;
    NSNumber *retweetStatusId;
    NSString *retweetToScreenName;
    
    BOOL isFoursquareOn;
    BOOL isFacebookOn;
    BOOL isGeotagOn;
    IBOutlet UIButton *foursquareButton;
    IBOutlet UIButton *facebookButton;
    IBOutlet UIButton *geotagButton;
    IBOutlet UIButton *addPhotoButton;
    
    int actionCount;
}

@property (nonatomic, retain) NSNumber *replyToStatusId;
@property (nonatomic, retain) NSString *replyToScreenName;
@property (nonatomic, retain) NSNumber *retweetStatusId;
@property (nonatomic, retain) NSString *retweetToScreenName;

- (IBAction) submitTweet;
- (IBAction) cancelCreate;
- (IBAction) toggleFacebook;
- (IBAction) toggleFoursquare;
- (IBAction) toggleGeotag;
- (IBAction) addPhoto;
- (void) decrementActionCount;
- (void) closeUpShop;

@end
