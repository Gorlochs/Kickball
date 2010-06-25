//
//  KBFacebookCreateWallPostVC.h
//  Kickball
//
//  Created by Shawn Bernard on 4/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBFacebookViewController.h"
#import "KBPhotoManager.h"
#import "MGTwitterEngineDelegate.h"


@interface KBFacebookCreateWallPostVC : KBFacebookViewController <UITextViewDelegate, PhotoManagerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    IBOutlet UITextView *tweetTextView;
    IBOutlet UILabel *characterCountLabel;
    IBOutlet UIButton *sendTweet;
    IBOutlet UIButton *cancel;
    
    NSNumber *replyToStatusId;
    NSString *replyToScreenName;
    NSNumber *retweetStatusId;
    NSString *retweetToScreenName;
    NSString *retweetTweetText;
	NSString *directMentionToScreenname;
    
    BOOL isFoursquareOn;
    BOOL isFacebookOn;
    BOOL isGeotagOn;
    IBOutlet UIButton *foursquareButton;
    IBOutlet UIButton *facebookButton;
    IBOutlet UIButton *geotagButton;
    IBOutlet UIButton *addPhotoButton;
    IBOutlet UIButton *removePhotoButton;
    UIImage *photoImage;
    KBPhotoManager *photoManager;
    IBOutlet UIImageView *thumbnailPreview;
    IBOutlet UIImageView *thumbnailBackground;
    
    int actionCount;
}

@property (nonatomic, retain) NSNumber *replyToStatusId;
@property (nonatomic, retain) NSString *replyToScreenName;
@property (nonatomic, retain) NSNumber *retweetStatusId;
@property (nonatomic, retain) NSString *retweetToScreenName;
@property (nonatomic, retain) NSString *retweetTweetText;
@property (nonatomic, retain) NSString *directMentionToScreenname;

- (IBAction) submitTweet;
//- (IBAction) cancelCreate;
- (IBAction) toggleFacebook;
- (IBAction) toggleFoursquare;
- (IBAction) toggleGeotag;
- (void) decrementActionCount;
- (void) closeUpShop;
- (void) getPhoto:(UIImagePickerControllerSourceType)sourceType;
- (IBAction) choosePhotoSelectMethod;
- (IBAction) removePhoto;

@end
