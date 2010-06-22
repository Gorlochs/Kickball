//
//  FBFacebookCreatePostViewController.h
//  Kickball
//
//  Created by scott bates on 6/21/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBFacebookViewController.h"
#import "KBPhotoManager.h"
#import "KBTwitterManager.h"

@interface FBFacebookCreatePostViewController : KBFacebookViewController <UITextViewDelegate, MGTwitterEngineDelegate, PhotoManagerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
	IBOutlet UITextView *tweetTextView;
    IBOutlet UILabel *characterCountLabel;
    IBOutlet UIButton *sendTweet;
    IBOutlet UIButton *cancel;
	IBOutlet UIButton *foursquareButton;
    IBOutlet UIButton *twitterButton;
    IBOutlet UIButton *geotagButton;
    IBOutlet UIButton *addPhotoButton;
    IBOutlet UIButton *removePhotoButton;
	IBOutlet UIImageView *thumbnailPreview;
    IBOutlet UIImageView *thumbnailBackground;
	
	BOOL isFoursquareOn;
    BOOL isTwitterOn;
    BOOL isGeotagOn;
	UIImage *photoImage;
    KBPhotoManager *photoManager;
}


- (IBAction) submitTweet;
//- (IBAction) cancelCreate;
- (IBAction) toggleTwitter;
- (IBAction) toggleFoursquare;
- (IBAction) toggleGeotag;
- (IBAction) choosePhotoSelectMethod;
- (IBAction) removePhoto;

@end
