//
//  PlaceMapViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 12/20/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "PlaceMapViewController.h"
#import "VenueAnnotation.h"
#import "KBPin.h"
#import "PlaceDetailViewController.h"

@implementation PlaceMapViewController

@synthesize venue;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.01;
    span.longitudeDelta = 0.01;
    
    CLLocationCoordinate2D location = venue.location;
    
    region.span = span;
    region.center = location;
    
    [theMapView setRegion:region animated:NO];
    [theMapView regionThatFits:region];
    
    VenueAnnotation *anote = [[VenueAnnotation alloc] init];
    anote.coordinate = location;
    anote.title = venue.name;
    anote.venueId = venue.venueid;
    anote.subtitle = venue.addressWithCrossstreet;
    
    [theMapView addAnnotation:anote];
    [anote release];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    for (id<MKAnnotation> currentAnnotation in mapView.annotations) { 
        [mapView selectAnnotation:currentAnnotation animated:YES];
    }    
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>) annotation{
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

//- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>) annotation{
////	int postag = 0;
//    
//	KBPin *annView = [[[KBPin alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomId"] autorelease];
//    annView.image = [UIImage imageNamed:@"pin.png"];
//    
//    // add an accessory button so user can click through to the venue page
////	UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
////	myDetailButton.frame = CGRectMake(0, 0, 23, 23);
////	myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
////	myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
////	
////	// Set the image for the button
////	[myDetailButton setImage:[UIImage imageNamed:@"button_right.png"] forState:UIControlStateNormal];
////	[myDetailButton addTarget:self action:@selector(showVenue:) forControlEvents:UIControlEventTouchUpInside]; 
////	
////    postag = [((VenueAnnotation*)annotation).venueId intValue];
////	myDetailButton.tag  = postag;
////	
////	// Set the button as the callout view
////	annView.rightCalloutAccessoryView = myDetailButton;
//	
//	//annView.animatesDrop=TRUE;
//	annView.canShowCallout = YES;
//	annView.calloutOffset = CGPointMake(-5, 5);
//	return annView;
//}

- (void) showVenue:(id)sender {
    int nrButtonPressed = ((UIButton *)sender).tag;
    NSLog(@"annotation for venue pressed: %d", nrButtonPressed);
    
    PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];;
    placeDetailController.venueId = [NSString stringWithFormat:@"%d", nrButtonPressed];
    [self.navigationController pushViewController:placeDetailController animated:YES];
    [placeDetailController release];
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


- (void)dealloc {
    [theMapView release];
    [venue release];
    [super dealloc];
}


@end
