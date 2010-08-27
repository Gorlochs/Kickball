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
#import "FSCheckin.h"
#import "FSVenue.h"
#import "KBPhotoManager.h"
#import "KBTwitterManager.h"
#import "TweetPhoto.h"


@interface KBCheckinModalViewController : AbstractPushNotificationViewController <KBTwitterManagerDelegate, UITextFieldDelegate, MGTwitterEngineDelegate, PhotoManagerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    FSVenue *venue;
    IBOutlet UILabel *characterCountLabel;
    
    BOOL isTwitterOn;
    BOOL isFacebookOn;
    BOOL isFoursquareOn;
    IBOutlet UIButton *twitterButton;
    IBOutlet UIButton *facebookButton;
    IBOutlet UIButton *foursquareButton;
    IBOutlet UIButton *checkinButton;
    IBOutlet UITextField *checkinTextField;
    FSCheckin *checkin;
    UIImage *photoImage;
    KBPhotoManager *photoManager;
    IBOutlet UIImageView *thumbnailPreview;
    KBTwitterManager *twitterManager;
	TweetPhoto * tweetPhoto;
	TweetPhotoResponse *tweetPhotoResponse;
	
    int actionCount;
	id parentController;
}

@property (nonatomic, retain) FSVenue *venue;
@property (nonatomic, retain)id parentController;

- (IBAction) checkin;
- (IBAction) cancelView;
- (IBAction) toggleTwitter;
- (IBAction) toggleFacebook;
- (IBAction) toggleFoursquare;
-(void)updateTwitterButton;
-(void)updateFacebookButton;
-(void)updateFoursquareButton;
-(void) uploadToFacebook;
- (void) submitToTwitter:(TweetPhotoResponse*)response;
- (void) closeUpShop;
- (void) decrementActionCount;
- (void) getPhoto:(UIImagePickerControllerSourceType)sourceType;
- (IBAction) choosePhotoSelectMethod;

@end
