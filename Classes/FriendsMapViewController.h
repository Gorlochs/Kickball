//
//  FriendsMapViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 10/25/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FoursquareAPI.h"
#import "FriendPlacemark.h"
#import "FriendIconAnnotationView.h"
#import "KBFoursquareViewController.h"

@interface FriendsMapViewController : KBFoursquareViewController {
	IBOutlet MKMapView * mapViewer;
	NSArray * checkins;
	MKCoordinateRegion mapRegion;
}

- (void) refreshFriendPoints;
- (void) refreshMapRegion;
- (void) setCheckins:(NSArray *) checkin;
- (NSArray *) checkins;
- (void) showProfile:(id)sender;
- (IBAction) retrieveNewFriendLocationsAndRefresh;
- (void) refreshEverything;

@end
