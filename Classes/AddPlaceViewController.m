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
    
    [[Beacon shared] startSubBeaconWithName:@"Add Venue"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVenue:) name:@"venueAddressUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCategory:) name:@"venueCategoryUpdate" object:nil];
}

- (void) updateVenue:(NSNotification*)notification {
    NSLog(@"notification: %@", notification);
    venue = nil;
    [venue release];
    venue = [[[notification userInfo] objectForKey:@"updatedVenue"] retain];
    addressNotation.text = @"Added!";
    addressNotation.textColor = [UIColor colorWithRed:0.0 green:164.0/255.0 blue:237.0/255.0 alpha:1.0];
    NSLog(@"updated address venue: %@", venue);
}

- (void) updateCategory:(NSNotification*)notification {
    NSLog(@"notification: %@", notification);
    venue = nil;
    [venue release];
    venue = [[[notification userInfo] objectForKey:@"updatedCategory"] retain];
    categoryNotation.text = @"Added!";
    categoryNotation.textColor = [UIColor colorWithRed:0.0 green:164.0/255.0 blue:237.0/255.0 alpha:1.0];
    NSLog(@"updated category venue: %@", venue);
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

- (void) checkinToNewVenue {
    //[newPlaceName resignFirstResponder];
    if (![venue.name isEqualToString:@""]) {
        [self startProgressBar:@"Searching..."];
        // TODO: I am just replacing a space with a +, but other characters might give this method a headache.
        NSLog(@"searching on latitude: %f", [[KBLocationManager locationManager] latitude]);
        NSLog(@"searching on longitude: %f", [[KBLocationManager locationManager] longitude]);
        [[FoursquareAPI sharedInstance] getVenuesByKeyword:[venue.name stringByReplacingOccurrencesOfString:@" " withString:@"+"]
                                               andLatitude:[NSString stringWithFormat:@"%f", [[KBLocationManager locationManager] latitude]] 
                                              andLongitude:[NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] longitude]] 
                                                withTarget:self 
                                                 andAction:@selector(venuesResponseReceived:withResponseString:)
         ];
    }
}

- (void) addAddress {
    AddPlaceFormViewController *formController = [[AddPlaceFormViewController alloc] initWithNibName:@"AddPlaceFormViewController" bundle:nil];
    formController.newVenue = [venue retain];
    [self.navigationController pushViewController:formController animated:YES];
    // FIXME: vvv this is wrong. please fix vvv
    //[formController release];
}

- (void) addCategory {
    AddPlaceCategoryViewController *formController = [[AddPlaceCategoryViewController alloc] initWithNibName:@"AddPlaceCategoryViewController" bundle:nil];
    formController.newVenue = [venue retain];
    [self.navigationController pushViewController:formController animated:YES];
    //[formController release];
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
    //[newPlaceName resignFirstResponder];
    [self checkinToNewVenue];
}

- (void) doVenuelessCheckin {
    if ([venue.name isEqualToString:@""]){
        KBMessage *msg = [[KBMessage alloc] initWithMember:@"Error" andMessage:@"Please fill out a venue name"];
        [self displayPopupMessage:msg];
        [msg release];
    } else {
        [self startProgressBar:@"Checking you in..."];
        [[FoursquareAPI sharedInstance] doVenuelessCheckin:venue.name withTarget:self andAction:@selector(checkinResponseReceived:withResponseString:)];
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
