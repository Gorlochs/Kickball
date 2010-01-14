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


#define CONST_fps 25.0
#define CONST_map_shift 0.15

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
//    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
//    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / CONST_fps)];
}
 
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

//- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
//    static CGFloat ZZ = 0.;
//    CGFloat z = (atan2(acceleration.x, acceleration.y) + M_PI);
//
//    if (fabsf(ZZ - z) > CONST_map_shift)
//    {
//        mapViewer.layer.transform = CATransform3DMakeRotation(ZZ=z, 0., 0., 1.);
//    }
//}

-(void) refreshMapRegion {
	NSLog(@"Refresh map region");
	[mapViewer setRegion:mapRegion animated:TRUE];
	[mapViewer regionThatFits:mapRegion];
}

// map is to be centered on the user and a generic zoom level
// FUTURE: allow user to set zoom level in settings
- (void) setCheckins:(NSArray *) checkin{
	[checkins release];
	checkins = checkin;
	[checkins retain];

	if (checkins && checkins.count > 0)
	{
		NSLog(@"checkins count: %d", checkins.count);
		
//		double minLat = 1000;
//		double maxLat = -1000;
//		double minLong = 1000;
//		double maxLong = -1000;
//		
//		for (FSCheckin *checkin in checkins)
//		{
//			double lat = checkin.venue.geolat.doubleValue;
//			double lng = checkin.venue.geolong.doubleValue;
//			
//			if (lat < minLat)
//			{
//				minLat = lat;
//			}
//			if (lat > maxLat)
//			{
//				maxLat = lat;
//			}
//			
//			if (lng < minLong)
//			{
//				minLong = lng;
//			}
//			if (lng > maxLong)
//			{
//				maxLong = lng;
//			}
//		}
		
		MKCoordinateRegion region;
		MKCoordinateSpan span;
//		span.latitudeDelta=(maxLat - minLat);
//		if (span.latitudeDelta == 0)
//		{
			span.latitudeDelta = 0.05;
//		}
//		span.longitudeDelta=(maxLong - minLong);
//		if (span.longitudeDelta == 0)
//		{
			span.longitudeDelta = 0.05;
//		}
		
		CLLocationCoordinate2D center;
//		center.latitude = (minLat + maxLat) / 2;
        //		center.longitude = (minLong + maxLong) / 2;
        center.latitude = [[LocationManager locationManager] latitude];
        center.longitude = [[LocationManager locationManager] longitude];
		
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
            //placemark.userId = checkUser.userId;
			if(checkUser.photo != nil){
				placemark.url = checkUser.photo;
			}
			[mapViewer addAnnotation:placemark];
            [placemark release];
		}
	}	
}

- (void) viewProfile:(NSString*)userId {
    ProfileViewController *profileController = [[ProfileViewController alloc] initWithNibName:@"ProfileView" bundle:nil];
    profileController.userId = userId;
    [self.navigationController pushViewController:profileController animated:YES];
    [profileController release];
}

#pragma mark MapViewer functions
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    // If it's the user location, just return nil.
	
    if ([annotation isKindOfClass:[MKUserLocation class]]) return nil;
	FriendIconAnnotationView* pinView = (FriendIconAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotation"];
//    [pinView addObserver:self
//                          forKeyPath:@"selected"
//                             options:NSKeyValueObservingOptionNew
//                             context:@"annotationTouch"];
	if (!pinView){
		// If an existing pin view was not available, create one
		//pinView = [[[FriendIconAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotation"] autorelease];
		pinView = [[[FriendIconAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotation" andImageUrl:((FriendPlacemark *)annotation).url] autorelease];
//        pinView.userId = ((FriendPlacemark *)annotation).userId;
//		pinView.pinColor = MKPinAnnotationColorRed;
//		pinView.animatesDrop = YES;
//		pinView.canShowCallout = NO;
		
	} else {
        pinView.annotation = annotation;
    }
		
	return pinView;	
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
//    
//    NSString *action = (NSString*)context;
//    
//    NSLog(@"**************** annotation touched 1 *************");
//    
//    if([action isEqualToString:@"annotationTouch"]){
//        BOOL annotationAppeared = [[change valueForKey:@"new"] boolValue];
//        NSLog(@"**************** annotation touched 2 *************");
//        // do something
//    }
//}

- (void)dealloc {
    [mapViewer release];
    [checkins release];
    [super dealloc];
}

@end
