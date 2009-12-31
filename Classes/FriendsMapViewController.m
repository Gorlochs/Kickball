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


@implementation FriendsMapViewController

@synthesize mapViewer;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

-(void) viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	[self refreshFriendPoints];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(void) refreshMapRegion {
	NSLog(@"Refresh map region");
	[mapViewer setRegion:mapRegion animated:TRUE];
	[mapViewer regionThatFits:mapRegion];
}


- (void) setCheckins:(NSArray *) checkin{
	[checkins release];
	checkins = checkin;
	[checkins retain];
	
    // TODO: center map on user's coordinate, which will be pulled from [FoursquareAPI user] or something

	if (checkins && checkins.count > 0)
	{
		NSLog(@"checkins count: %d", checkins.count);
		
		double minLat = 1000;
		double maxLat = -1000;
		double minLong = 1000;
		double maxLong = -1000;
		
		for (FSCheckin *checkin in checkins)
		{
			double lat = checkin.venue.geolat.doubleValue;
			double lng = checkin.venue.geolong.doubleValue;
			
			if (lat < minLat)
			{
				minLat = lat;
			}
			if (lat > maxLat)
			{
				maxLat = lat;
			}
			
			if (lng < minLong)
			{
				minLong = lng;
			}
			if (lng > maxLong)
			{
				maxLong = lng;
			}
		}
		
		MKCoordinateRegion region;
		MKCoordinateSpan span;
		span.latitudeDelta=(maxLat - minLat);
		if (span.latitudeDelta == 0)
		{
			span.latitudeDelta = 0.1;
		}
		span.longitudeDelta=(maxLong - minLong);
		if (span.longitudeDelta == 0)
		{
			span.longitudeDelta = 0.1;
		}
		
		CLLocationCoordinate2D center;
		center.latitude = (minLat + maxLat) / 2;
		center.longitude = (minLong + maxLong) / 2;
		
		NSLog(@"Lat delta: %f.  Long delta: %f.  Lat: %f.  Long: %f", span.latitudeDelta, span.longitudeDelta, center.latitude, center.longitude);
		
		region.span = span;
		region.center = center;
		
		mapRegion = region;
		[self performSelectorOnMainThread:@selector(refreshMapRegion) withObject:nil waitUntilDone:NO];	
	}
	
	[self refreshFriendPoints];
}


- (NSArray *) checkins{
	return checkins;
}

- (void) refreshFriendPoints{
	for(FSCheckin * checkin in self.checkins){		
		FSVenue * checkVenue = checkin.venue;
		if(checkVenue.geolat && checkVenue.geolong){
			CLLocationCoordinate2D location = checkVenue.location;
			FSUser * checkUser = checkin.user;

			FriendPlacemark *placemark=[[FriendPlacemark alloc] initWithCoordinate:location];
			if(checkUser.photo != nil){
				placemark.url = checkUser.photo;
			}
			[mapViewer addAnnotation:placemark];
            [placemark release];
		}
	}	
}

#pragma mark MapViewer functions
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    // If it's the user location, just return nil.
	
    if ([annotation isKindOfClass:[MKUserLocation class]]) return nil;
	FriendIconAnnotationView*    pinView = (FriendIconAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotation"];
	if (!pinView){
		// If an existing pin view was not available, create one
		//pinView = [[[FriendIconAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotation"] autorelease];
		pinView = [[[FriendIconAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotation" andImageUrl:((FriendPlacemark *)annotation).url] autorelease];
//		pinView.pinColor = MKPinAnnotationColorRed;
//		pinView.animatesDrop = YES;
//		pinView.canShowCallout = NO;
		
	} else
		pinView.annotation = annotation;
	return pinView;	
}

- (void)dealloc {
    [super dealloc];
}

@end
