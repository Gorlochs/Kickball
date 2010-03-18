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
#import "KBBaseViewController.h"
#import "GAConnectionDelegate.h"
#import "MockPhotoSource.h"
#import "KBPhotoThumbnailCell.h"

@interface PlaceDetailViewController : KBBaseViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, GAConnectionDelegate, UIActionSheetDelegate> {
    IBOutlet UITableView *theTableView;
    IBOutlet UITableViewCell *checkinCell;
    IBOutlet KBPhotoThumbnailCell *giftCell;
    IBOutlet UITableViewCell *mayorMapCell;
    IBOutlet UITableViewCell *pointsCell;
    IBOutlet UITableViewCell *badgeCell;
    IBOutlet UITableViewCell *newMayorCell;
    IBOutlet UITableViewCell *stillTheMayorCell;
    IBOutlet UITableViewCell *bottomButtonCell;
    IBOutlet UITableViewCell *detailButtonCell;
    IBOutlet UITableViewCell *shoutCell;
    IBOutlet MKMapView *smallMapView;
    IBOutlet MKMapView *fullMapView;
    
    IBOutlet UILabel *venueName;
    IBOutlet UILabel *venueAddress;
    IBOutlet UILabel *mayorNameLabel;
    IBOutlet UILabel *mayorCheckinCountLabel;
    IBOutlet UILabel *badgeLabel;
    IBOutlet UILabel *badgeTitleLabel;
    IBOutlet UILabel *newMayorshipLabel;
    IBOutlet UILabel *stillTheMayorLabel;
    
    IBOutlet UIImageView *badgeImage;
    
    IBOutlet UIButton *twitterButton;
    IBOutlet UIButton *pingAndTwitterToggleButton;
//     IBOutlet UIButton *twitterToggleButton;
    IBOutlet UIButton *venueDetailButton;
    IBOutlet UIButton *specialsButton;
    IBOutlet UIButton *mapButton;
    IBOutlet UIButton *closeMapButton;
    IBOutlet UIButton *phoneButton;
    IBOutlet UIButton *choosePhotoButton;
    IBOutlet UIImageView *noMayorImage;
    IBOutlet UIImageView *mayorOverlay;
    IBOutlet UIImageView *mayorArrow;
    IBOutlet UIImageView *mayorCrown;
    
    NSArray *checkin;
    FSVenue *venue;
    NSString *venueId;
    
    bool isUserCheckedIn;
    bool isPingOn;
    bool isTwitterOn;  
    
    // set to YES if the user should be checked in with the initialization of this view
    BOOL doCheckin;
    
    // photo related objects
    NSMutableArray *goodies;
    MockPhotoSource *photoSource;
    IBOutlet UILabel *photoHeaderLabel;
    IBOutlet UIView *photoHeaderView;
    IBOutlet UIButton *seeAllPhotosButton;
    IBOutlet UIButton *addPhotoButton;
}

@property (nonatomic, retain) UITableViewCell *mayorMapCell;
@property (nonatomic, retain) UITableViewCell *checkinCell;
@property (nonatomic, retain) UITableViewCell *giftCell;
@property (nonatomic, retain) NSArray *checkin;
@property (nonatomic, retain) FSVenue *venue;
@property (nonatomic, retain) NSString *venueId;
@property (nonatomic) BOOL doCheckin;

- (void) retrievePhotos;
- (IBAction) callVenue;
- (IBAction) uploadImageToServer;
- (IBAction) showTwitterFeed;
- (IBAction) checkinToVenue;
- (IBAction) togglePingsAndTwitter;
- (IBAction) doGeoAPICall;
- (IBAction) showSpecial;
- (IBAction) viewVenueMap;
- (IBAction) addTipTodo;
- (IBAction) markVenueWrongAddress;
- (IBAction) markVenueClosed;
- (IBAction) closeMap;
- (FSCheckin*) getSingleCheckin;
- (BOOL) hasMayorCell;
- (BOOL) isNewMayor;
//- (void) setProperTwitterButtonState;
//- (void) setProperPingButtonState;
- (void) setProperButtonStates;
- (void)friendsReceived:(NSNotification *)inNotification;
- (IBAction) choosePhotoSelectMethod;
- (void) getPhoto:(UIImagePickerControllerSourceType)sourceType;
- (IBAction) viewPhotos;
- (BOOL)uploadImage:(NSData *)imageData filename:(NSString *)filename withWidth:(float)width andHeight:(float)height andOrientation:(UIImageOrientation)orientation;
- (UIImage*)imageByScalingToSize:(UIImage*)image toSize:(CGSize)targetSize;
- (IBAction) displayAllImages;

@end
