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


@implementation AddPlaceViewController

@synthesize checkin;
@synthesize newVenueName;
@synthesize categoryId;

- (void)viewDidLoad {
    self.hideFooter = YES;
    self.hideHeader = YES;
    pageType = KBPageTypeOther;
    pageViewType = KBPageViewTypeOther;
    
    [super viewDidLoad];
    
    newPlaceName.text = newVenueName;
    
    [[Beacon shared] startSubBeaconWithName:@"Add Venue"];
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

- (void) checkinToNewVenue {
    [newPlaceName resignFirstResponder];
    if (![newPlaceName.text isEqualToString:@""]) {
        [self startProgressBar:@"Searching..."];
        // TODO: I am just replacing a space with a +, but other characters might give this method a headache.
        NSLog(@"searching on latitude: %f", [[KBLocationManager locationManager] latitude]);
        NSLog(@"searching on longitude: %f", [[KBLocationManager locationManager] longitude]);
        [[FoursquareAPI sharedInstance] getVenuesByKeyword:[NSString stringWithFormat:@"%f", [[KBLocationManager locationManager] latitude]] 
                                              andLongitude:[NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] longitude]] 
                                               andKeywords:[newPlaceName.text stringByReplacingOccurrencesOfString:@" " withString:@"+"]
                                                withTarget:self 
                                                 andAction:@selector(venuesResponseReceived:withResponseString:)
         ];
    }
}

- (void) addAddress {
    AddPlaceFormViewController *formController = [[AddPlaceFormViewController alloc] initWithNibName:@"AddPlaceFormViewController" bundle:nil];
    formController.newVenueName = newPlaceName.text;
    [self.navigationController pushViewController:formController animated:YES];
    [formController release];
}

- (void) addCategory {
    AddPlaceCategoryViewController *formController = [[AddPlaceCategoryViewController alloc] initWithNibName:@"AddPlaceCategoryViewController" bundle:nil];
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

- (void) checkListings {
    [newPlaceName resignFirstResponder];
    [self checkinToNewVenue];
}

- (void) doVenuelessCheckin {
    if ([newPlaceName.text isEqualToString:@""]){
        KBMessage *msg = [[KBMessage alloc] initWithMember:@"Error" andMessage:@"Please fill out a venue name"];
        [self displayPopupMessage:msg];
        [msg release];
    } else {
        [self startProgressBar:@"Checking you in..."];
        [[FoursquareAPI sharedInstance] doVenuelessCheckin:newPlaceName.text withTarget:self andAction:@selector(checkinResponseReceived:withResponseString:)];
    }
}

- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"new checkin instring: %@", inString);
	NSArray *checkins = [FoursquareAPI checkinFromResponseXML:inString];
    FSCheckin *ci = [checkins objectAtIndex:0];
    NSLog(@"venueless checkin: %@", checkins);
    [self stopProgressBar];

    KBMessage *msg = [[KBMessage alloc] initWithMember:@"Check-in Successful" andMessage:ci.message];
    [self displayPopupMessage:msg];
    [msg release];
}



- (void)dealloc {
    [newPlaceName release];
    [mapView release];
    [addCategoryButton release];
    [addAddressButton release];
    [newVenueName release];
    [categoryId release];
    
    [checkin release];
    
    [super dealloc];
}


@end

