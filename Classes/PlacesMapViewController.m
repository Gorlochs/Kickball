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
    [mapViewer setShowsUserLocation:YES];
    [[Beacon shared] startSubBeaconWithName:@"Venues Map"];
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

    [mapViewer removeAnnotations:mapViewer.annotations];
  
    double minLat = 1000;
    double maxLat = -1000;
    double minLong = 1000;
    double maxLong = -1000;
    
    for (FSVenue *venue in self.venues)
    {
        double lat = venue.geolat.doubleValue;
        double lng = venue.geolong.doubleValue;
        
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
        span.latitudeDelta = 0.05;
    }
    span.longitudeDelta=(maxLong - minLong);
    if (span.longitudeDelta == 0)
    {
        span.longitudeDelta = 0.05;
    }
    
    CLLocationCoordinate2D center;
    center.latitude = (minLat + maxLat) / 2;
    center.longitude = (minLong + maxLong) / 2;
    
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
    // does this go here?
    [self stopProgressBar];
}

- (void) zoomToProperDepth {
    if (self.venues && self.venues.count > 0)
	{
//		NSLog(@"checkins count: %d", checkins.count);
		
        double minLat = 1000;
        double maxLat = -1000;
        double minLong = 1000;
        double maxLong = -1000;
        
        for (FSVenue *venue in self.venues)
        {
        	double lat = venue.geolat.doubleValue;
        	double lng = venue.geolong.doubleValue;
        	
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
		
		//MKCoordinateRegion region;
		MKCoordinateSpan span;
        span.latitudeDelta=(maxLat - minLat);
        if (span.latitudeDelta == 0)
        {
        span.latitudeDelta = 0.05;
        }
        span.longitudeDelta=(maxLong - minLong);
        if (span.longitudeDelta == 0)
        {
        span.longitudeDelta = 0.05;
        }
		
		CLLocationCoordinate2D center;
        center.latitude = (minLat + maxLat) / 2;
        center.longitude = (minLong + maxLong) / 2;
    }
}


#pragma mark MapViewer functions

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
	if (annotation == mapView.userLocation) {
        MKAnnotationView* annotationView;
		annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"blueDot"];
		if (annotationView != nil) {
			annotationView.annotation = annotation;
		} else {
			annotationView = [[[NSClassFromString(@"MKUserLocationView") alloc] initWithAnnotation:annotation reuseIdentifier:@"blueDot"] autorelease];
		}
        return annotationView;
	} else {
        int postag = 0;
        
        KBPin *annView=[[[KBPin alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomId"] autorelease];
        //annView.pinColor = MKPinAnnotationColorGreen;
        annView.image = [UIImage imageNamed:@"pin.png"];
        
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
        //annView.calloutOffset = CGPointMake(-5, 5);
        return annView;
    }
}

//- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>) annotation{
//    if (annotation == mapView.userLocation) {
//        return nil;
//    }
//	int postag = 0;
//    
//	KBPin *annView=[[[KBPin alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomId"] autorelease];
//	//annView.pinColor = MKPinAnnotationColorGreen;
//    annView.image = [UIImage imageNamed:@"pin.png"];
//    
//    // add an accessory button so user can click through to the venue page
//	UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	myDetailButton.frame = CGRectMake(0, 0, 23, 23);
//	myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//	myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//	
//	// Set the image for the button
//	[myDetailButton setImage:[UIImage imageNamed:@"button_right.png"] forState:UIControlStateNormal];
//	[myDetailButton addTarget:self action:@selector(showVenue:) forControlEvents:UIControlEventTouchUpInside]; 
//	
//    postag = [((VenueAnnotation*)annotation).venueId intValue];
//	myDetailButton.tag  = postag;
//	
//	// Set the button as the callout view
//	annView.rightCalloutAccessoryView = myDetailButton;
//	
//	//annView.animatesDrop=TRUE;
//	annView.canShowCallout = YES;
//	//annView.calloutOffset = CGPointMake(-5, 5);
//	return annView;
//}

- (void) showVenue:(id)sender {
    [[Beacon shared] startSubBeaconWithName:@"Clicked on Show Venue from Map Annotation"];
    int nrButtonPressed = ((UIButton *)sender).tag;
    NSLog(@"annotation for venue pressed: %d", nrButtonPressed);
    
    PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];
    placeDetailController.venueId = [NSString stringWithFormat:@"%d", nrButtonPressed];
    [self.navigationController pushViewController:placeDetailController animated:YES];
    [placeDetailController release];
}


#pragma mark IBAction methods

-(void)searchOnKeywordsandLatLong {
    [self startProgressBar:@"Searching..."];
    [searchbox resignFirstResponder];
    if (![searchbox.text isEqualToString:@""]) {
        // TODO: I am just replacing a space with a +, but other characters might give this method a headache.
        [[FoursquareAPI sharedInstance] getVenuesByKeyword:[NSString stringWithFormat:@"%f",[[LocationManager locationManager] latitude]] 
                                              andLongitude:[NSString stringWithFormat:@"%f",[[LocationManager locationManager] longitude]] 
                                               andKeywords:[searchbox.text stringByReplacingOccurrencesOfString:@" " withString:@"+"]
                                                withTarget:self 
                                                 andAction:@selector(venuesResponseReceived:withResponseString:)
         ];
    }
}

- (void)venuesResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"venues from search - instring: %@", inString);
	NSDictionary *allVenues = [FoursquareAPI venuesFromResponseXML:inString];
    NSMutableArray *venueArray = [[NSMutableArray alloc] initWithCapacity:1];
    NSArray *keys = [allVenues allKeys];
    for (NSString *key in keys) {
        [venueArray addObjectsFromArray:[allVenues objectForKey:key]];
    }
	self.venues = [NSArray arrayWithArray:venueArray];
    NSLog(@"searched on venues: %@", self.venues);
    [venueArray release];
    [self stopProgressBar];
    [self refreshVenuePoints];
}

- (void) cancelKeyboard: (UIControl *) button {
    [searchbox resignFirstResponder];
}

- (void) refresh: (UIControl *) button {
    [self refreshVenuePoints];
}

#pragma mark UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [switchingButton setImage:[UIImage imageNamed:@"resultsClear.png"] forState:UIControlStateNormal];
    [switchingButton setImage:[UIImage imageNamed:@"resultsClear02.png"] forState:UIControlStateHighlighted];
    [switchingButton addTarget:self action:@selector(cancelKeyboard:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [switchingButton setImage:[UIImage imageNamed:@"resultsRefresh01.png"] forState:UIControlStateNormal];
    [switchingButton setImage:[UIImage imageNamed:@"resultsRefresh02.png"] forState:UIControlStateHighlighted];
    [switchingButton addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self searchOnKeywordsandLatLong];
    return YES;
}

- (void)dealloc {
    [venues release];
    [mapViewer release];
    [bestEffortAtLocation release];
    [searchbox release];
    [switchingButton release];
    [super dealloc];
}
@end
