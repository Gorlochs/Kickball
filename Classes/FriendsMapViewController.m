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
#import "LocationManager.h"
#import "ProfileViewController.h"
#import "PlacesListViewController.h"


@implementation FriendsMapViewController

@synthesize mapViewer, checkins;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self startProgressBar:@"Retrieving map..."];
    [[Beacon shared] startSubBeaconWithName:@"Friends Map View"];
}
 
-(void) viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	[self refreshFriendPoints];
    [self refreshMapRegion];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

//- (void) viewDidDisappear:(BOOL)animated {
//    [mapViewer removeAnnotations:mapViewer.annotations];
//}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void) refreshMapRegion {
	NSLog(@"Refresh map region");
	[mapViewer setRegion:mapRegion animated:TRUE];
	[mapViewer regionThatFits:mapRegion];
}

// map is to be centered on the user and a generic zoom level
// FUTURE: allow user to set zoom level in settings
- (void) setCheckins:(NSArray *) checkin{
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
        center.latitude = [[LocationManager locationManager] latitude];
        center.longitude = [[LocationManager locationManager] longitude];
		
		NSLog(@"Lat delta: %f.  Long delta: %f.  Lat: %f.  Long: %f", span.latitudeDelta, span.longitudeDelta, center.latitude, center.longitude);
		
		region.span = span;
		region.center = center;
		
		mapRegion = region;
		[self performSelectorOnMainThread:@selector(refreshMapRegion) withObject:nil waitUntilDone:NO];	
	}
	
	//[self refreshFriendPoints];
}

- (void) refreshFriendPoints {
	for(FSCheckin * checkin in self.checkins){		
		FSVenue * checkVenue = checkin.venue;
		if(checkVenue.geolat && checkVenue.geolong){
			CLLocationCoordinate2D location = checkVenue.location;
			FSUser * checkUser = checkin.user;

			FriendPlacemark *placemark=[[FriendPlacemark alloc] initWithCoordinate:location];
			if(checkUser.photo != nil){
				placemark.url = checkUser.photo;
			}
            NSLog(@"checkuser: %@", checkUser);
            placemark.title = checkin.display;
            placemark.subtitle = checkin.venue.addressWithCrossstreet;
            //placemark.subtitle = checkUser.lastname;
            placemark.userId = checkUser.userId;
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

- (void) checkin {
    PlacesListViewController *placesListController = [[PlacesListViewController alloc] initWithNibName:@"PlacesListViewController" bundle:nil];
    [self.navigationController pushViewController:placesListController animated:NO];
    [placesListController release];
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
		pinView = [[[FriendIconAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotation" andImageUrl:((FriendPlacemark *)annotation).url] autorelease];
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
	
    int postag = [((FriendPlacemark*)annotation).userId intValue];
	myDetailButton.tag  = postag;
	
	// Set the button as the callout view
	pinView.rightCalloutAccessoryView = myDetailButton;
    
    pinView.canShowCallout = YES;
    //pinView.calloutOffset = CGPointMake(-5, 5);
		
	return pinView;	
}

- (void) showProfile:(id)sender {
    [[Beacon shared] startSubBeaconWithName:@"Clicked on Profile from Friends Map"];
    int nrButtonPressed = ((UIButton *)sender).tag;
    NSLog(@"annotation for profile pressed: %d", nrButtonPressed);
    
    ProfileViewController *profileDetailController = [[ProfileViewController alloc] initWithNibName:@"ProfileView" bundle:nil];;
    profileDetailController.userId = [NSString stringWithFormat:@"%d", nrButtonPressed];
    [self.navigationController pushViewController:profileDetailController animated:YES];
    [profileDetailController release];
}

- (void)dealloc {
    [mapViewer release];
    [checkins release];
    [super dealloc];
}

@end
