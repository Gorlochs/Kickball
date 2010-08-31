//
//  AddPlaceViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 12/12/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "AddPlaceViewController.h"
#import "FoursquareAPI.h"
#import "KBLocationManager.h"
#import "AddPlaceFormViewController.h"
#import "Utilities.h"
#import "PlaceDetailViewController.h"
#import "AddPlaceCategoryViewController.h"
#import "KBPin.h"


@implementation AddPlaceViewController

@synthesize checkin;
@synthesize newVenueName;
@synthesize categoryId;
@synthesize venue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    self.hideFooter = YES;
    self.hideHeader = YES;
    pageType = KBPageTypeOther;
    pageViewType = KBPageViewTypeOther;
    
    [super viewDidLoad];
    
    venue = [[FSVenue alloc] init];
    venue.name = newVenueName;
    newPlaceName.text = venue.name;
    
    [FlurryAPI logEvent:@"Add Venue"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVenue:) name:@"venueAddressUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCategory:) name:@"venueCategoryUpdate" object:nil];
    
    // center map on user location
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.01;
    span.longitudeDelta = 0.01;
    
    region.span = span;
    region.center = [[KBLocationManager locationManager] bestEffortAtLocation].coordinate;
    
    [mapView setRegion:region animated:NO];
    [mapView regionThatFits:region];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    if( [[annotation title] isEqualToString:@"Current Location"] ) {
		return nil;
	}
    
	static NSString* annotationIdentifier = @"annotationIdentifier";
	KBPin* annView = (KBPin *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
	if (!annView)
	{
		// if an existing pin view was not available, create one
		annView = [[[KBPin alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
		//KBPin *annView=[[[KBPin alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomId"] autorelease];
	}
    annView.image = [UIImage imageNamed:@"place-mapPin.png"];

    return annView;
}

- (void) updateVenue:(NSNotification*)notification {
    DLog(@"notification: %@", notification);
    venue = nil;
    [venue release];
    venue = [[[notification userInfo] objectForKey:@"updatedVenue"] retain];
    addressNotation.text = @"Added!";
    addressNotation.textColor = [UIColor colorWithRed:0.0 green:164.0/255.0 blue:237.0/255.0 alpha:1.0];
    DLog(@"updated address venue: %@", venue);
}

- (void) updateCategory:(NSNotification*)notification {
    DLog(@"notification: %@", notification);
    venue = nil;
    [venue release];
    venue = [[[notification userInfo] objectForKey:@"updatedVenue"] retain];
    categoryNotation.text = @"Added!";
    categoryNotation.textColor = [UIColor colorWithRed:0.0 green:164.0/255.0 blue:237.0/255.0 alpha:1.0];
    DLog(@"updated category venue: %@", venue);
    [self.navigationController popToViewController:self animated:YES];
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

#pragma mark IBOutlet methods

//- (void) checkinToNewVenue {
//    //[newPlaceName resignFirstResponder];
//    if (![venue.name isEqualToString:@""]) {
//        [self startProgressBar:@"Searching..."];
//        // TODO: I am just replacing a space with a +, but other characters might give this method a headache.
//        DLog(@"searching on latitude: %f", [[KBLocationManager locationManager] latitude]);
//        DLog(@"searching on longitude: %f", [[KBLocationManager locationManager] longitude]);
//        [[FoursquareAPI sharedInstance] getVenuesByKeyword:[venue.name stringByReplacingOccurrencesOfString:@" " withString:@"+"]
//                                               andLatitude:[NSString stringWithFormat:@"%f", [[KBLocationManager locationManager] latitude]] 
//                                              andLongitude:[NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] longitude]] 
//                                                withTarget:self 
//                                                 andAction:@selector(venuesResponseReceived:withResponseString:)
//         ];
//    }
//}

- (void) addAddress {
    AddPlaceFormViewController *formController = [[AddPlaceFormViewController alloc] initWithNibName:@"AddPlaceFormViewController" bundle:nil];
    formController.newVenue = [venue retain];
    [self.navigationController pushViewController:formController animated:YES];
    // FIXME: vvv this is wrong. please fix vvv
    [formController release];
}

- (void) addCategory {
    AddPlaceCategoryViewController *formController = [[AddPlaceCategoryViewController alloc] initWithNibName:@"AddPlaceCategoryViewController" bundle:nil];
    formController.newVenue = [venue retain];
    [self.navigationController pushViewController:formController animated:YES];
    [formController release];
}

- (void) backOneView {
    [self.navigationController popViewControllerAnimated:YES];
}

//
//- (FSVenue*) extractVenueFromDictionaryForRow:(NSIndexPath*)indexPath {
//    NSString *keyForSection = [[venues allKeys] objectAtIndex:indexPath.section];
//    NSArray *venuesForSection = [venues objectForKey:keyForSection];
//    return (FSVenue*) [venuesForSection objectAtIndex:indexPath.row];
//}

//- (void) checkListings {
//    //[newPlaceName resignFirstResponder];
//    [self checkinToNewVenue];
//}

- (void) doVenuelessCheckin {
    if ([venue.name isEqualToString:@""]){
        KBMessage *msg = [[KBMessage alloc] initWithMember:@"Error" andMessage:@"Oops! Enter a venue name."];
        [self displayPopupMessage:msg];
        [msg release];
    } else {
        [self startProgressBar:@"Checking you in..."];
        [[FoursquareAPI sharedInstance] doVenuelessCheckin:venue.name withTarget:self andAction:@selector(checkinResponseReceived:withResponseString:)];
    }
}

- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    DLog(@"new checkin instring: %@", inString);
    FSCheckin *ci = [FoursquareAPI checkinFromResponseXML:inString];
    DLog(@"venueless checkin: %@", checkin);
    [self stopProgressBar];

    KBMessage *msg = [[KBMessage alloc] initWithMember:@"Check-in Successful" andMessage:ci.message];
    [self displayPopupMessage:msg];
    [msg release];
}


- (void) saveVenueAndCheckin {
//    if (![address.text isEqualToString:@""]) {
//        FSUser *user = [self getAuthenticatedUser];
        
        [self startProgressBar:@"Adding new venue and checking you in..."];
        [[FoursquareAPI sharedInstance] addNewVenue:venue.name
                                          atAddress:[Utilities safeString:venue.venueAddress]
                                     andCrossstreet:[Utilities safeString:venue.crossStreet]
                                            andCity:[Utilities safeString:venue.city]
                                           andState:[Utilities safeString:venue.venueState]
                                     andOptionalZip:[Utilities safeString:venue.zip]
                                  andRequiredCityId:[Utilities safeString:venue.city]
                                   andOptionalPhone:[Utilities safeString:venue.phone]
                                         withTarget:self 
                                          andAction:@selector(newVenueResponseReceived:withResponseString:)];
//    } else {
//        KBMessage *msg = [[KBMessage alloc] initWithMember:@"Form Error!" andMessage:@"All the required fields must be filled in."];
//        [self displayPopupMessage:msg];
//        [msg release];
//    }
}

- (void)newVenueResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    BOOL hasError = [inString rangeOfString:@"<error>"].location != NSNotFound;
    if (hasError) {
        KBMessage *msg = [[KBMessage alloc] initWithMember:@"Foursquare Error" andMessage:@"The venue could not be created. Is it a duplicate venue?"];
        [self displayPopupMessage:msg];
        [msg release];
    } else {
        DLog(@"new venue instring: %@", inString);
        FSVenue *theVenue = [FoursquareAPI venueFromResponseXML:inString];
        
        // TODO: we should think about removing the Add Venue pages from the stack so users can't use the BACK button to return to them
        PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView_v2" bundle:nil];    
        placeDetailController.venueId = theVenue.venueid;
        placeDetailController.doCheckin = YES;
        [self.navigationController pushViewController:placeDetailController animated:YES];
        [placeDetailController release]; 
    }
    [self stopProgressBar];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"venueAddressUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"venueCategoryUpdate" object:nil];
    [newPlaceName release];
    [mapView release];
    [addCategoryButton release];
    [addAddressButton release];
    [newVenueName release];
    [categoryId release];
    [checkin release];
    [venue release];
    [categoryNotation release];
    [addressNotation release];
    
    [super dealloc];
}

@end
