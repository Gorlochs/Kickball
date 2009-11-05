//
//  PlaceDetailViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 10/28/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FSVenue.h";

#define DebugLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )

@interface PlaceDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    IBOutlet UITableView *theTableView;
    IBOutlet UITableViewCell *mayorMapCell;
    IBOutlet MKMapView *mapView;
    
    IBOutlet UILabel *venueName;
    IBOutlet UILabel *venueAddress;
    
    IBOutlet UIImageView *mayorImage;
    IBOutlet UIButton *twitterButton;
    
    FSVenue *venue;
    NSString *venueId;
}

@property (nonatomic, retain) UITableViewCell *mayorMapCell;
@property (nonatomic, retain) FSVenue *venue;
@property (nonatomic, retain) NSString *venueId;

- (IBAction) callVenue;
- (IBAction) uploadImageToServer;
- (IBAction) showTwitterFeed;

@end
