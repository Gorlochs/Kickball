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
#import "LocationManager.h"
#import "PlaceDetailViewController.h"


@implementation PlacesMapViewController

@synthesize mapViewer, bestEffortAtLocation;


 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self refreshVenuePoints];
}

-(void) viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
}

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
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.02;
    span.longitudeDelta = 0.02;
    
    CLLocationCoordinate2D center;
    center.latitude = [[LocationManager locationManager] latitude];
    center.longitude = [[LocationManager locationManager] longitude];
    
    region.span = span;
    region.center = center;
    
	for(FSVenue * venue in self.venues){
		//FSVenue * checkVenue = checkin.venue; 
		if(venue.geolat && venue.geolong){
            
            CLLocationCoordinate2D location = venue.location;
            [mapViewer setRegion:region animated:NO];
            [mapViewer regionThatFits:region];
            
            VenueAnnotation *anote = [[VenueAnnotation alloc] init];
            anote.coordinate = location;
            anote.title = venue.name;
            anote.venueId = venue.venueid;
            anote.subtitle = venue.addressWithCrossstreet;
            [mapViewer addAnnotation:anote];
            [anote release];
            
//            MKAnnotationView *av = [[MKAnnotationView alloc] initWithAnnotation:anote reuseIdentifier:@"testing"];
//            av.rightCalloutAccessoryView
		}
	}	
}


#pragma mark MapViewer functions

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>) annotation{
	int postag = 0;
    
	KBPin *annView=[[KBPin alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomId"];
	//annView.pinColor = MKPinAnnotationColorGreen;
    annView.image = [UIImage imageNamed:@"pinRed.png"];
    
    // add an accessory button so user can click through to the venue page
	UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
	myDetailButton.frame = CGRectMake(0, 0, 23, 23);
	myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	// Set the image for the button
	[myDetailButton setImage:[UIImage imageNamed:@"button_right.png"] forState:UIControlStateNormal];
	[myDetailButton addTarget:self action:@selector(showVenue:) forControlEvents:UIControlEventTouchUpInside]; 
	
    postag = [((VenueAnnotation*)annotation).venueId intValue];
	myDetailButton.tag  = postag;
	
	// Set the button as the callout view
	annView.rightCalloutAccessoryView = myDetailButton;
	
	//annView.animatesDrop=TRUE;
	annView.canShowCallout = YES;
	annView.calloutOffset = CGPointMake(-5, 5);
	return annView;
}

- (void) showVenue:(id)sender {
    int nrButtonPressed = ((UIButton *)sender).tag;
    NSLog(@"annotation for venue pressed: %d", nrButtonPressed);
    
    PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];;
    placeDetailController.venueId = [NSString stringWithFormat:@"%d", nrButtonPressed];
    [self.navigationController pushViewController:placeDetailController animated:YES];
    [placeDetailController release];
}

// this one displays the proper pin, but doesn't work with the pop up annotation
//- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation: (id<MKAnnotation>) annotation {
//
//    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomId"];
//    UIImage *image = [UIImage imageNamed:@"pinRed.png"];
////    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
////    [annView addSubview:imageView];
////    [imageView release];
//    annView.image = image;
//    [image release];
//    annView.animatesDrop=TRUE;
//    annView.canShowCallout = YES;
//    annView.calloutOffset = CGPointMake(-5, 5);
//    annView.
//    return annView;
//
//    
////    MKAnnotationView *annView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
////    
////    UIImage *image = [UIImage imageNamed:@"pinRed.png"];
////    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
////    [annView addSubview:imageView];
////    [imageView release];
////    
////    MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];     
////    [annView addSubview:pinView];
////    [pinView release];
////    
////    return annView;
//}
    

//{    
//    MKPinAnnotationView *pin=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomAnnotation"];
////	[pin setPinColor:MKPinAnnotationColorRed];
////    
//	// Set up the Left callout
//	UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//	myDetailButton.frame = CGRectMake(0, 0, 23, 23);
//	myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//	myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
////	[myDetailButton addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
//	
//	
//	pin.rightCalloutAccessoryView = myDetailButton;
//	pin.animatesDrop = YES;
//	pin.canShowCallout = YES;
//    
//    //	if (pin == nil)
////    {
////        //pin = [[[KBPin alloc] initWithAnnotation:annotation] autorelease];
////
////        pin = [[[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"CustomAnnotation"] autorelease];
////    }
////    else
////    {
////        pin.annotation = annotation;
////    }
//    //pin.annotation.title = @"test";
//    //pin.title = @"testing";
////    pin.pinColor = MKPinAnnotationColorRed;
//    //pin.animatesDrop = YES;
//    return pin;
//}

#pragma mark IBAction methods

-(void)searchOnKeywordsandLatLong {
    [searchbox resignFirstResponder];
    if (![searchbox.text isEqualToString:@""]) {
        // TODO: I am just replacing a space with a +, but other characters might give this method a headache.
        [[FoursquareAPI sharedInstance] getVenuesByKeyword:[NSString stringWithFormat:@"%f",bestEffortAtLocation.coordinate.latitude] 
                                              andLongitude:[NSString stringWithFormat:@"%f",bestEffortAtLocation.coordinate.longitude] 
                                               andKeywords:[searchbox.text stringByReplacingOccurrencesOfString:@" " withString:@"+"]
                                                withTarget:self 
                                                 andAction:@selector(venuesResponseReceived:withResponseString:)
         ];
    }
}
- (void)venuesResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
	NSDictionary *allVenues = [FoursquareAPI venuesFromResponseXML:inString];
	self.venues = [[allVenues copy] objectAtIndex:0];
    [self stopProgressBar];
    //[self refreshVenuePoints];
}


- (void)dealloc {
    [venues release];
    [mapViewer release];
    [bestEffortAtLocation release];
    [searchbox release];
    [super dealloc];
}
@end
