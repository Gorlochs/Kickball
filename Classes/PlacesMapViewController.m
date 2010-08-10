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
#import "KBLocationManager.h"
#import "PlaceDetailViewController.h"
#import "PlacesListViewController.h"
#import "FriendsListViewController.h"
#import "FriendsMapViewController.h"


@implementation PlacesMapViewController

@synthesize bestEffortAtLocation, searchKeywords;


 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    pageType = KBPageTypePlaces;
    pageViewType = KBPageViewTypeMap;
    venues = nil;
    [super viewDidLoad];
    
    // this hack is here to help make the toggle 'global'
    if (venues == nil || [venues count] == 0) {
        [self startProgressBar:@"Retrieving venues..."];
        [[FoursquareAPI sharedInstance] getVenuesNearLatitude:[NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] latitude]]
                                                 andLongitude:[NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] longitude]]
                                                   withTarget:self 
                                                    andAction:@selector(venuesResponseReceived:withResponseString:)
        ];   
    } else {
        searchbox.text = searchKeywords;
        [self refreshVenuePoints];
    }
	
    [FlurryAPI logEvent:@"Venues Map"];
}

- (void)venuesResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    DLog(@"venues: %@", inString);
	NSDictionary *allVenues = [FoursquareAPI venuesFromResponseXML:inString];
	[venues release];
	venues = nil;
    venues = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSString *key in [allVenues allKeys]) {
        [venues addObjectsFromArray:[allVenues objectForKey:key]];
    }
    [self stopProgressBar];
    [self refreshVenuePoints];
}

- (void) viewFriendsMap {
    FriendsMapViewController *friendsMapController = [[FriendsMapViewController alloc] initWithNibName:@"FriendsMapView_v2" bundle:nil];
    [self.navigationController pushViewController:friendsMapController animated:NO];
    [friendsMapController release];
}

- (void) viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
}

- (void) flipBetweenMapAndList {
    PlacesListViewController *placesListController = [[PlacesListViewController alloc] initWithNibName:@"PlacesListView_v2" bundle:nil];
    [self.navigationController pushViewController:placesListController animated:NO];
    [placesListController release];
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


- (void) setVenues:(NSMutableArray *) venue{
	[venues release];
	venues = nil;
	venues = venue;
    
	//[self refreshVenuePoints];
}


- (NSArray *) venues {
	return venues;
}

- (void) releaseAllAnnotationExceptCurrentLocation {
    NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:1];
    for (id<MKAnnotation> annotation in mapViewer.annotations) {
        if( ![[annotation title] isEqualToString:@"Current Location"] ) {
            [tmpArray addObject:annotation];
        }
    }
    [mapViewer removeAnnotations:tmpArray];
    [tmpArray release];
}

- (void) refreshVenuePoints {

    [self addAnnotationsToMap:self.venues];
    [self zoomToProperDepth];
    
    // does this go here?
    [self stopProgressBar];
}

- (void) addAnnotationsToMap:(NSArray*)venueArray {
    for(FSVenue * venue in venueArray){
		if(venue.geolat && venue.geolong){
            
            CLLocationCoordinate2D location = venue.location;
            
            VenueAnnotation *anote = [[VenueAnnotation alloc] init];
            anote.coordinate = location;
            anote.title = venue.name;
            anote.venueId = venue.venueid;
            anote.subtitle = venue.addressWithCrossstreet;
            [mapViewer addAnnotation:anote];
            [anote release];
		}
	}
}


- (void) zoomToProperDepth {
    if (self.venues && self.venues.count > 0)
	{
//		DLog(@"checkins count: %d", checkins.count);
		
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
        
        [mapViewer setRegion:region animated:NO];
        [mapViewer regionThatFits:region];
    }
}

#pragma mark MKMapViewDelegate functions

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (isMapFinishedLoading) {
        isMapFinishedLoading = NO;
        CLLocationCoordinate2D newCenterCoordinate = mapView.centerCoordinate;
        [self searchOnMapScrollLatLongWithCoordinate:newCenterCoordinate];
    }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    isMapFinishedLoading = YES;
}

#pragma mark MapViewer functions

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    if( [[annotation title] isEqualToString:@"Current Location"] ) {
		return nil;
	}

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

- (void) showVenue:(id)sender {
    [FlurryAPI logEvent:@"Clicked on Show Venue from Map Annotation"];
    int nrButtonPressed = ((UIButton *)sender).tag;
    DLog(@"annotation for venue pressed: %d", nrButtonPressed);
    
    PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView_v2" bundle:nil];
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
        [self releaseAllAnnotationExceptCurrentLocation];
        [[FoursquareAPI sharedInstance] getVenuesByKeyword:searchbox.text 
                                               andLatitude:[NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] latitude]]
                                              andLongitude:[NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] longitude]]
                                                withTarget:self 
                                                 andAction:@selector(venuesResponseReceived:withResponseString:)
         ];  
    }
}

// no search criteria (yet), no rezoom
- (void) searchOnMapScrollLatLongWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if ([searchbox.text isEqualToString:@""]) {
        [[FoursquareAPI sharedInstance] getVenuesNearLatitude:[NSString stringWithFormat:@"%f", coordinate.latitude]
                                                 andLongitude:[NSString stringWithFormat:@"%f", coordinate.longitude]
                                                   withTarget:self 
                                                    andAction:@selector(allVenuesOnScrollResponseReceived:withResponseString:)
         ];
    } else {
        [[FoursquareAPI sharedInstance] getVenuesByKeyword:searchbox.text 
                                               andLatitude:[NSString stringWithFormat:@"%f", coordinate.latitude]
                                              andLongitude:[NSString stringWithFormat:@"%f", coordinate.longitude]
                                                withTarget:self 
                                                 andAction:@selector(allVenuesOnScrollResponseReceived:withResponseString:)
         ];
    }
}

- (void)allVenuesOnScrollResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    DLog(@"venues from search - instring: %@", inString);
	NSDictionary *allVenues = [FoursquareAPI venuesFromResponseXML:inString];
    NSMutableArray *venueArray = [[NSMutableArray alloc] initWithCapacity:1];
    NSArray *keys = [allVenues allKeys];
    for (NSString *key in keys) {
        [venueArray addObjectsFromArray:[allVenues objectForKey:key]];
    }
	[venues release];
	venues = nil;
	venues = [venueArray copy];
    DLog(@"searched on venues: %@", venues);
    [venueArray release];
    [self stopProgressBar];
    [self addAnnotationsToMap:venues];
}

- (void)allVenuesResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    DLog(@"venues from search - instring: %@", inString);
	NSDictionary *allVenues = [FoursquareAPI venuesFromResponseXML:inString];
    NSMutableArray *venueArray = [[NSMutableArray alloc] initWithCapacity:1];
    NSArray *keys = [allVenues allKeys];
    for (NSString *key in keys) {
        [venueArray addObjectsFromArray:[allVenues objectForKey:key]];
    }
	[venues release];
	venues = nil;
	venues = [venueArray copy];
    DLog(@"searched on venues: %@", venues);
    [venueArray release];
    [self stopProgressBar];
    [self refreshVenuePoints];
}

- (void) cancelKeyboard: (UIControl *) button {
    [self cancelTheKeyboard];
}

- (void) cancelTheKeyboard {
    [searchbox resignFirstResponder];
}

- (void) refresh: (UIControl *) button {
    [self startProgressBar:@"Retrieving venues..."];
    [[FoursquareAPI sharedInstance] getVenuesNearLatitude:[NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] latitude]]
                                             andLongitude:[NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] longitude]]
                                               withTarget:self 
                                                andAction:@selector(venuesResponseReceived:withResponseString:)
     
     ];
//    [self refreshVenuePoints];
}

#pragma mark UITextFieldDelegate methods

- (void) cancelEdit {
    [self cancelTheKeyboard];
    searchbox.text = @"";
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self searchOnKeywordsandLatLong];
    return YES;
}

- (void) dealloc {
    // all this is a fix for the MKMapView bug where the bouncing blue dot animation causes a crash when you go back one view
    [mapViewer removeAnnotations:mapViewer.annotations];
    mapViewer.delegate = nil;
    mapViewer.showsUserLocation = NO;
    [mapViewer release];

    [venues release];
    [bestEffortAtLocation release];
    [searchbox release];
    [switchingButton release];
    [super dealloc]; // I assume that this is just so that there is no Xcode warning
}
@end
