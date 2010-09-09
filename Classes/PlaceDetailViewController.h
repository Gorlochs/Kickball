//
//  PlaceDetailViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 10/28/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FSVenue.h"
#import "AbstractPushNotificationViewController.h"
#import "GAConnectionDelegate.h"
#import "MockPhotoSource.h"
#import "KBPhotoThumbnailCell.h"
#import "PhotoMessageViewController.h"
#import "KBPhotoManager.h"
#import "TipDetailViewController.h"
#import "KBCheckinModalViewController.h"
#import "GAConnectionManager.h"
#import "TableSectionHeaderView.h"


@interface PlaceDetailViewController : AbstractPushNotificationViewController <PhotoManagerDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, GAConnectionDelegate, UIActionSheetDelegate> {
    IBOutlet UITableViewCell *checkinCell;
    IBOutlet KBPhotoThumbnailCell *giftCell;
    IBOutlet UITableViewCell *mayorMapCell;
    IBOutlet UITableViewCell *bottomButtonCell;
    IBOutlet UITableViewCell *detailButtonCell;
    IBOutlet MKMapView *smallMapView;
    IBOutlet MKMapView *fullMapView;
    
    IBOutlet UILabel *venueName;
    IBOutlet UILabel *venueAddress;
    IBOutlet UILabel *mayorNameLabel;
    IBOutlet UILabel *mayorCheckinCountLabel;
    
    IBOutlet UIImageView *badgeImage;
    
    IBOutlet UIButton *twitterButton;
    IBOutlet UIButton *pingAndTwitterToggleButton;
    IBOutlet UIButton *venueDetailButton;
    IBOutlet UIButton *specialsButton;
    IBOutlet UIButton *mapButton;
    IBOutlet UIButton *closeMapButton;
    IBOutlet UIButton *phoneButton;
    IBOutlet UIButton *choosePhotoButton;
    IBOutlet UIButton *imHereButton;
    IBOutlet UIImageView *noMayorImage;
    IBOutlet UIImageView *mayorArrow;
    IBOutlet UIImageView *mayorCrown;
	IBOutlet UILabel *noMayorLabel;
    
    NSArray *checkin;
    FSVenue *venue;
    NSString *venueId;
    
    bool isUserCheckedIn;
    bool isPingOn;
    bool isTwitterOn;  
    bool isFacebookOn;  
    
    // set to YES if the user should be checked in with the initialization of this view
    BOOL doCheckin;
    
    // set ot YES if the user should have the checkin modal view displayed
    BOOL showCheckinView;
    
    // photo related objects
    NSMutableArray *goodies;
    MockPhotoSource *photoSource;
    IBOutlet UILabel *photoHeaderLabel;
    IBOutlet TableSectionHeaderView *photoHeaderView;
    IBOutlet UIButton *seeAllPhotosButton;
    IBOutlet UIButton *addPhotoButton;
    UIImage *photoImage;
    PhotoMessageViewController *photoMessageViewController;
    IBOutlet UILabel *distanceAndNumCheckinsLabel;
    KBPhotoManager *photoManager;
    
    // specials
    IBOutlet UIView *specialView;
    IBOutlet UILabel *specialPlaceName;
    IBOutlet UILabel *specialAddress;
    IBOutlet UITextView *specialText;
    IBOutlet UIButton *specialClose;
    IBOutlet UIButton *nextSpecialButton;
    IBOutlet UIButton *previousSpecialButton;
    
    TipDetailViewController *tipController;
    
    int currentSpecial;
	int actionCount;
    
    KBCheckinModalViewController *checkinViewController;
	
	UITableViewCell *peopleHereCell;
	UIView *checkinView;
	GAConnectionManager *connectionManager_;
}

@property (nonatomic, retain) UITableViewCell *mayorMapCell;
@property (nonatomic, retain) UITableViewCell *checkinCell;
@property (nonatomic, retain) UITableViewCell *giftCell;
@property (nonatomic, retain) NSArray *checkin;
@property (nonatomic, retain) FSVenue *venue;
@property (nonatomic, retain) NSString *venueId;
@property (nonatomic, retain) UIImage *photoImage;
@property (nonatomic) BOOL doCheckin;
@property (nonatomic) BOOL showCheckinView;

- (IBAction) callVenue;
- (IBAction) uploadImageToServer;
- (IBAction) showTwitterFeed;
- (IBAction) doGeoAPICall;
- (IBAction) doCityGridCall;
- (IBAction) showSpecial;
- (IBAction) viewVenueMap;
- (IBAction) addTipTodo;
- (IBAction) markVenueWrongAddress;
- (IBAction) markVenueClosed;
- (IBAction) closeMap;
- (IBAction) choosePhotoSelectMethod;
//- (IBAction) viewPhotos;
- (IBAction) viewThumbnails;
//- (IBAction) displayAllImages;
- (IBAction) openCheckinView;
- (IBAction) closeSpecialView;
- (IBAction) showNextSpecial;
- (IBAction) showPreviousSpecial;

- (void) showSpecial:(int)specialIndex;

- (FSCheckin*) getSingleCheckin;
- (BOOL) hasMayorCell;
- (BOOL) isNewMayor;
- (void) retrievePhotos;
- (void) setProperButtonStates;
- (void) getPhoto:(UIImagePickerControllerSourceType)sourceType;
- (void) returnFromMessageView:(NSNotification *)inNotification;
//- (void) uploadFacebookPhoto:(NSData*)img withCaption:(NSString*)caption;
//- (BOOL)uploadImage:(NSData *)imageData filename:(NSString *)filename withWidth:(float)width andHeight:(float)height andMessage:(NSString*)message andOrientation:(UIImageOrientation)orientation;
//- (UIImage*)imageByScalingToSize:(UIImage*)image toSize:(CGSize)targetSize;

-(void)addPersonHere:(UIView*)container :(FSCheckin*)person :(int)position;
-(void)touchedPersonHere:(id)sender;

-(void) closeCheckinView;

@end
