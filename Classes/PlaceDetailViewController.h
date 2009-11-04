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

@interface PlaceDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    IBOutlet UITableView *theTableView;
    IBOutlet UITableViewCell *mayorMapCell;
    IBOutlet MKMapView *mapView;
    
    IBOutlet UILabel *venueName;
    IBOutlet UILabel *venueAddress;
    
    IBOutlet UIImageView *mayorImage;
    
    FSVenue *venue;
}

@property (nonatomic, retain) UITableViewCell *mayorMapCell;
@property (nonatomic, retain) FSVenue *venue;

- (IBAction) callVenue;
- (IBAction) uploadImageToServer;

@end
