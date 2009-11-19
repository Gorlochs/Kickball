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
	NSArray * venues;
}

@property (nonatomic, retain) NSArray * venues;
@property (nonatomic, retain) MKMapView * mapViewer;

- (void) refreshVenuePoints;
- (void) setVenues:(NSArray *) venue;
- (NSArray *) venues;

@end
