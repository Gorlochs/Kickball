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

@interface FriendsMapViewController : UIViewController {
	IBOutlet MKMapView * mapViewer;
	NSArray * checkins;
}

@property (nonatomic, retain) NSArray * checkins;
@property (nonatomic, retain) MKMapView * mapViewer;


- (void) refreshFriendPoints;
- (void) setCheckins:(NSArray *) checkin;
- (NSArray *) checkins;
@end
