//
//  PlacesMapViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 11/18/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FoursquareAPI.h"
#import "FriendPlacemark.h"
#import "FriendIconAnnotationView.h"
#import "KBBaseViewController.h"


@interface PlacesMapViewController : KBBaseViewController {
	IBOutlet MKMapView * mapViewer;
	NSDictionary * venues;
    CLLocation *bestEffortAtLocation;
    IBOutlet UITextField *searchbox;
}

@property (nonatomic, retain) NSDictionary * venues;
@property (nonatomic, retain) MKMapView * mapViewer;
@property (nonatomic, retain) CLLocation *bestEffortAtLocation;

- (void) refreshVenuePoints;
- (void) setVenues:(NSDictionary *) venue;
- (NSDictionary *) venues;
- (IBAction) searchOnKeywordsandLatLong;

@end

