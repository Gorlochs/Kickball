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
#import "KBFoursquareViewController.h"


@interface PlacesMapViewController : KBFoursquareViewController <UITextFieldDelegate, MKMapViewDelegate> {
	IBOutlet MKMapView * mapViewer;
	NSMutableArray * venues;
    CLLocation *bestEffortAtLocation;
    IBOutlet UITextField *searchbox;
    IBOutlet UIButton *switchingButton;
    NSString *searchKeywords;
    
    BOOL isMapFinishedLoading;
}

@property (nonatomic, retain) NSMutableArray * venues;
@property (nonatomic, retain) MKMapView * mapViewer;
@property (nonatomic, retain) CLLocation *bestEffortAtLocation;
@property (nonatomic, retain) NSString *searchKeywords;

- (void) refreshVenuePoints;
- (void) setVenues:(NSMutableArray *) venue;
- (NSArray *) venues;
- (IBAction) searchOnKeywordsandLatLong;
- (IBAction) refresh: (UIControl *) button;
- (void) cancelKeyboard: (UIControl *) button;
- (IBAction) cancelTheKeyboard;
- (IBAction) viewFriendsMap;
- (IBAction) cancelEdit;
- (void) searchOnMapScrollLatLongWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (void) releaseAllAnnotationExceptCurrentLocation;
- (void) addAnnotationsToMap:(NSArray*)venueArray;
- (void) zoomToProperDepth;

@end

