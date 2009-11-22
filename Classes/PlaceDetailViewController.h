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

// just testing this snippet out that I picked up somewhere
#define DebugLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )

@interface PlaceDetailViewController : KBBaseViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, GAConnectionDelegate> {
    IBOutlet UITableView *theTableView;
    IBOutlet UITableViewCell *checkinCell;
    IBOutlet UITableViewCell *giftCell;
    IBOutlet UITableViewCell *mayorMapCell;
    IBOutlet UITableViewCell *pointsCell;
    IBOutlet UITableViewCell *badgeCell;
    IBOutlet MKMapView *mapView;
    
    IBOutlet UILabel *venueName;
    IBOutlet UILabel *venueAddress;
    IBOutlet UILabel *mayorNameLabel;
    IBOutlet UILabel *badgeLabel;
    
    IBOutlet UIButton *twitterButton;
    IBOutlet UIButton *pingToggleButton;
    IBOutlet UIButton *twitterToggleButton;
    IBOutlet UIButton *venueDetailButton;
    
    NSArray *checkin;
    FSVenue *venue;
    NSString *venueId;
    
    bool isUserCheckedIn;
    bool isPingOn;
    bool isTwitterOn;
}

@property (nonatomic, retain) UITableViewCell *mayorMapCell;
@property (nonatomic, retain) UITableViewCell *checkinCell;
@property (nonatomic, retain) UITableViewCell *giftCell;
@property (nonatomic, retain) NSArray *checkin;
@property (nonatomic, retain) FSVenue *venue;
@property (nonatomic, retain) NSString *venueId;

- (IBAction) callVenue;
- (IBAction) uploadImageToServer;
- (IBAction) showTwitterFeed;
- (IBAction) checkinToVenue;
- (IBAction) togglePing;
- (IBAction) toggleTwitter;
- (IBAction) doGeoAPICall;

@end
