//
//  PlacesMapViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 11/18/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "PlacesMapViewController.h"
#import "VenueAnnotation.h"
#import "KBPin.h"

@implementation PlacesMapViewController

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
	[self refreshVenuePoints];
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


- (void) setVenues:(NSArray *) venue{
	[venues release];
	venues = venue;
	[venues retain];
    // TODO: center map on user's coordinate, which will be pulled from [FoursquareAPI user] or something
	[self refreshVenuePoints];
}


- (NSArray *) venues{
	return venues;
}

- (void) refreshVenuePoints{
	for(FSVenue * venue in self.venues){
		//FSVenue * checkVenue = checkin.venue;
		if(venue.geolat && venue.geolong){
            MKCoordinateRegion region;
            MKCoordinateSpan span;
            span.latitudeDelta = 0.01;
            span.longitudeDelta = 0.01;
            
            CLLocationCoordinate2D location = mapViewer.userLocation.coordinate;
            
            location.latitude =  [venue.geolat doubleValue];
            location.longitude = [venue.geolong doubleValue];
            
            region.span = span;
            region.center = location;
            
            [mapViewer setRegion:region animated:NO];
            [mapViewer regionThatFits:region];
            
            VenueAnnotation *anote = [[VenueAnnotation alloc] init];
            anote.coordinate = location;
            anote.title = venue.name;
            anote.subtitle = venue.addressWithCrossstreet;
            [mapViewer addAnnotation:anote];
		}
	}	
}

#pragma mark MapViewer functions
//// this one displays the proper pin, but doesn't work with the pop up annotation
//- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation: (id<MKAnnotation>) annotation
//{    
//    KBPin *pin = (KBPin *) [self.mapViewer dequeueReusableAnnotationViewWithIdentifier: @"CustomPinAnnotation"];
//    if (pin == nil)
//    {
//        pin = [[[KBPin alloc] initWithAnnotation:annotation] autorelease];
//
//        //pin = [[[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"CustomPinAnnotation"] autorelease];
//    }
//    else
//    {
//        pin.annotation = annotation;
//    }
//    pin.title = @"testing";
////    pin.pinColor = MKPinAnnotationColorRed;
//    //pin.animatesDrop = YES;
//    return pin;
//}

- (void)dealloc {
    [venues release];
    [mapViewer release];

    [super dealloc];
}
@end
