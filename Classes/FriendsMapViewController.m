//
//  FriendsMapViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 10/25/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//
//  Google Map view of friends over the past X hours/days
//

#import "FriendsMapViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "KBLocationManager.h"
#import "ProfileViewController.h"
#import "PlacesListViewController.h"
#import "PlacesMapViewController.h"
#import "Utilities.h"


@implementation FriendsMapViewController

@synthesize mapViewer, checkins;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    pageType = KBPageTypeFriends;
    pageViewType = KBPageViewTypeMap;
    [super viewDidLoad];
    [FlurryAPI logEvent:@"Friends Map View"];
}
 
-(void) viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
    [self startProgressBar:@"Retrieving map..."];
    if (checkins) {
        [self refreshEverything];
    } else {
        [[FoursquareAPI sharedInstance] getCheckinsWithTarget:self andAction:@selector(checkinResponseReceived:withResponseString:)];
    }
}

- (void) flipBetweenMapAndList {
    [self goToHomeViewNotAnimated];
}

- (void) refreshEverything {
    [self refreshFriendPoints];
    [self refreshMapRegion];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    self.mapViewer = nil;
}

- (void) refreshMapRegion {
	[mapViewer setRegion:mapRegion animated:TRUE];
	[mapViewer regionThatFits:mapRegion];
}

// map is to be centered on the user and a generic zoom level
// FUTURE: allow user to set zoom level in settings
- (void) setCheckins:(NSArray *) checkin {
	[self.checkins release];
	checkins = checkin;
	[self.checkins retain];

	if (self.checkins && self.checkins.count > 0) {
		NSLog(@"checkins count: %d", self.checkins.count);
		
		MKCoordinateRegion region;
		MKCoordinateSpan span;

        span.latitudeDelta = 0.05;
        span.longitudeDelta = 0.05;
		
		CLLocationCoordinate2D center;
        center.latitude = [[KBLocationManager locationManager] latitude];
        center.longitude = [[KBLocationManager locationManager] longitude];
		
		NSLog(@"Lat delta: %f.  Long delta: %f.  Lat: %f.  Long: %f", span.latitudeDelta, span.longitudeDelta, center.latitude, center.longitude);
		
		region.span = span;
		region.center = center;
		
		mapRegion = region;
		[self performSelectorOnMainThread:@selector(refreshMapRegion) withObject:nil waitUntilDone:NO];	
	}
}

- (void) refreshFriendPoints {
	for(FSCheckin * checkin in self.checkins){		
		FSVenue * checkVenue = checkin.venue;
		if(checkVenue.geolat && checkVenue.geolong){
			CLLocationCoordinate2D location = checkVenue.location;
			FSUser * checkUser = checkin.user;

			FriendPlacemark *placemark=[[FriendPlacemark alloc] initWithCoordinate:location];

            NSLog(@"checkuser: %@", checkUser);
            placemark.checkin = checkin;
            placemark.title = checkin.display;
            placemark.subtitle = checkin.venue.addressWithCrossstreet;
			[mapViewer addAnnotation:placemark];
            [placemark release];
		}
	}
    [self stopProgressBar];
}

- (void) retrieveNewFriendLocationsAndRefresh {
    //self.checkins = nil;
    [self startProgressBar:@"Refreshing friends' locations..."];
    [mapViewer removeAnnotations:mapViewer.annotations];
	[[FoursquareAPI sharedInstance] getCheckinsWithTarget:self andAction:@selector(checkinResponseReceived:withResponseString:)];
}

- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    [self setCheckins:[FoursquareAPI checkinsFromResponseXML:inString]];
    [mapViewer removeAnnotations:mapViewer.annotations];
    [self refreshFriendPoints];
}

- (void) viewPlacesMap {
    PlacesMapViewController *placesMapController = [[PlacesMapViewController alloc] initWithNibName:@"PlacesMapView_v2" bundle:nil];
    [self.navigationController pushViewController:placesMapController animated:NO];
    [placesMapController release];
}

#pragma mark MapViewer functions
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    // If it's the user location, just return nil.
	
    if ([annotation isKindOfClass:[MKUserLocation class]]) return nil;
    // removing dequeueing because it is screwing up the refresh of the friends, plus there really isn't that much to dequeue.
//	FriendIconAnnotationView* pinView = (FriendIconAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotation"];
	FriendIconAnnotationView* pinView = nil;
	if (!pinView){
		// If an existing pin view was not available, create one
		pinView = [[[FriendIconAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotation" andCheckin:((FriendPlacemark *)annotation).checkin] autorelease];
	} else {
        pinView.annotation = annotation;
    }
    
    // add an accessory button so user can click through to the venue page
	UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
	myDetailButton.frame = CGRectMake(0, 0, 23, 23);
	myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	// Set the image for the button
	[myDetailButton setImage:[UIImage imageNamed:@"button_right.png"] forState:UIControlStateNormal];
	[myDetailButton addTarget:self action:@selector(showProfile:) forControlEvents:UIControlEventTouchUpInside]; 
	
    int postag = [((FriendPlacemark*)annotation).checkin.user.userId intValue];
	myDetailButton.tag  = postag;
	
	// Set the button as the callout view
	pinView.rightCalloutAccessoryView = myDetailButton;
    
    pinView.canShowCallout = YES;
    //pinView.calloutOffset = CGPointMake(-5, 5);
		
	return pinView;	
}

- (void) showProfile:(id)sender {
    [FlurryAPI logEvent:@"Clicked on Profile from Friends Map"];
    int nrButtonPressed = ((UIButton *)sender).tag;
    NSLog(@"annotation for profile pressed: %d", nrButtonPressed);
    
    [self displayProperProfileView:[NSString stringWithFormat:@"%d", nrButtonPressed]];
}

- (void)dealloc {
    // all this is a fix for the MKMapView bug where the bouncing blue dot animation causes a crash when you go back one view
    [self.mapViewer removeAnnotations:self.mapViewer.annotations];
    self.mapViewer.delegate = nil;
    self.mapViewer.showsUserLocation = NO;
    self.mapViewer = nil;
    
    [mapViewer performSelector:@selector(release) withObject:nil afterDelay:4.0f];
    //[mapViewer release];
    [checkins release];
    if (false) [super dealloc]; // I assume that this is just so that there is no Xcode warning
}

@end
