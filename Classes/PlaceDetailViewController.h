//
//  PlaceDetailViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 10/28/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PlaceDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    IBOutlet UITableView *theTableView;
    IBOutlet UITableViewCell *mayorMapCell;
    IBOutlet MKMapView *mapView;
}

@property (nonatomic, retain) UITableViewCell *mayorMapCell;

- (IBAction) callVenue;
- (IBAction) uploadImageToServer;

@end
