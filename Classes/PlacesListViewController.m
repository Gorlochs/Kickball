//
//  PlacesListViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 10/30/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import "PlacesListViewController.h"
#import "PlaceDetailViewController.h"
#import "PlacesMapViewController.h"
#import "FoursquareAPI.h"
#import "FSCheckin.h"
#import "AddPlaceViewController.h"
#import "LocationManager.h"

@interface PlacesListViewController (Private)

- (void)stopUpdatingLocation:(NSString *)state;
- (void)venuesResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;
- (FSVenue*) extractVenueFromDictionaryForRow:(NSIndexPath*)indexPath;

@end

@implementation PlacesListViewController

@synthesize searchCell;
@synthesize locationManager;
@synthesize bestEffortAtLocation;
@synthesize venues;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"PlacesListViewController get venue - geolat: %f", [[LocationManager locationManager] latitude]);
    NSLog(@"PlacesListViewController get venue - geolong: %f", [[LocationManager locationManager] longitude]);
    [[FoursquareAPI sharedInstance] getVenuesNearLatitude:[NSString stringWithFormat:@"%f",[[LocationManager locationManager] latitude]]
                                             andLongitude:[NSString stringWithFormat:@"%f",[[LocationManager locationManager] longitude]]
                                               withTarget:self 
                                                andAction:@selector(venuesResponseReceived:withResponseString:)
     ];
    
    [self addHeaderAndFooter:theTableView];
    [[Beacon shared] startSubBeaconWithName:@"Venue List"];
    
//    [self startProgressBar:@"Retrieving nearby venues..."];
//    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
//    locationManager.delegate = self;
//    // This is the most important property to set for the manager. It ultimately determines how the manager will
//    // attempt to acquire location and thus, the amount of power that will be consumed.
////    locationManager.desiredAccuracy = [[setupInfo objectForKey:kSetupInfoKeyAccuracy] doubleValue];
//    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
//    // Once configured, the location manager must be "started".
//    [locationManager startUpdatingLocation];
//    
//    if(![[FoursquareAPI sharedInstance] isAuthenticated]){
//		//run sheet to log in.
//		NSLog(@"Foursquare is not authenticated");
//	} else {
//		//[[FoursquareAPI sharedInstance] getCheckinsWithTarget:self andAction:@selector(checkinResponseReceived:withResponseString:)];
//	}
    
}

// TODO: this takes a bit of time.  Should we push this up to the appDelegate so that it's not executed every time this screen is displayed?
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // store all of the measurements, just so we can see what kind of data we might receive
    //[locationMeasurements addObject:newLocation];
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;
    // test the measurement to see if it is more accurate than the previous measurement
    if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy < newLocation.horizontalAccuracy) {
        // store the location as the "best effort"
        self.bestEffortAtLocation = newLocation;
        NSLog(@"best effort at location: %@", bestEffortAtLocation);
        // test the measurement to see if it meets the desired accuracy
        //
        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue 
        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of 
        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
        //
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
            // we have a measurement that meets our requirements, so we can stop updating the location
            // 
            // IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
            //
            [self stopUpdatingLocation:NSLocalizedString(@"Acquired Location", @"Acquired Location")];
            // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
        }
    }
    
    // TODO: this @selector should probably be different than the one for the searchbox.
    //       this way, we can switch back and forth to this list without having to reload everything
    [[FoursquareAPI sharedInstance] getVenuesNearLatitude:[NSString stringWithFormat:@"%f",bestEffortAtLocation.coordinate.latitude] 
                                             andLongitude:[NSString stringWithFormat:@"%f",bestEffortAtLocation.coordinate.longitude]
                                               withTarget:self 
                                                andAction:@selector(venuesResponseReceived:withResponseString:)
    ];
    
    venuesTypeToDisplay = KBNearbyVenues;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    // We can ignore this error for the scenario of getting a single location fix, because we already have a 
    // timeout that will stop the location manager to save power.
    if ([error code] != kCLErrorLocationUnknown) {
        [self stopUpdatingLocation:NSLocalizedString(@"Error", @"Error")];
    }
}

- (void)stopUpdatingLocation:(NSString *)state {
//    self.stateString = state;
//    [self.tableView reloadData];
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;
}

- (void)venuesResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"venues: %@", inString);
	NSDictionary *allVenues = [FoursquareAPI venuesFromResponseXML:inString];
	self.venues = [NSDictionary dictionaryWithDictionary:allVenues];
	[theTableView reloadData];
    
    //move table to new entry
    if ([theTableView numberOfSections] != 0) {
        NSUInteger indexArr[] = {0,0};
        [theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    [self stopProgressBar];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
    theTableView = nil;
    searchCell = nil;
}

- (void)viewDidUnload {
    theTableView = nil;
    searchCell = nil;
}

#pragma mark IBAction methods

// TODO: this should probably use a different @selector and set a instance variable?
-(void)searchOnKeywordsandLatLong {
    [searchbox resignFirstResponder];
    if (![searchbox.text isEqualToString:@""]) {
        venuesTypeToDisplay = KBSearchVenues;
        [self startProgressBar:@"Searching..."];
        // TODO: I am just replacing a space with a +, but other characters might give this method a headache.
        [[FoursquareAPI sharedInstance] getVenuesByKeyword:[NSString stringWithFormat:@"%f",[[LocationManager locationManager] latitude]] 
                                              andLongitude:[NSString stringWithFormat:@"%f",[[LocationManager locationManager] longitude]] 
                                               andKeywords:[searchbox.text stringByReplacingOccurrencesOfString:@" " withString:@"+"]
                                                withTarget:self 
                                                 andAction:@selector(venuesResponseReceived:withResponseString:)
         ];
        [[Beacon shared] startSubBeaconWithName:@"Venue Search from Venue List View"];
    }
}

- (void) flipToMap {
    PlacesMapViewController *mapViewController = [[PlacesMapViewController alloc] initWithNibName:@"PlacesMapView" bundle:nil];
    // TODO: do we need to combine both items in the venues array?
    NSMutableArray *allvenues = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSString *key in [venues allKeys]) {
        [allvenues addObjectsFromArray:[venues objectForKey:key]];
    }
    
	mapViewController.venues = allvenues;
    [allvenues release];
    [self.navigationController pushViewController:mapViewController animated:YES];
    [mapViewController release];
}

// TODO: currently refresh button refreshes the list to the original list
- (void) refresh: (UIControl *) button {
    [self startProgressBar:@"Retrieving nearby venues..."];
    [[FoursquareAPI sharedInstance] getVenuesNearLatitude:[NSString stringWithFormat:@"%f",[[LocationManager locationManager] latitude]] 
                                             andLongitude:[NSString stringWithFormat:@"%f",[[LocationManager locationManager] longitude]]
                                               withTarget:self 
                                                andAction:@selector(venuesResponseReceived:withResponseString:)
     ];
    [[Beacon shared] startSubBeaconWithName:@"Refreshing Venue List"];
    
    venuesTypeToDisplay = KBNearbyVenues;
}

- (void) addNewVenue {
    AddPlaceViewController *addPlaceController = [[AddPlaceViewController alloc] initWithNibName:@"AddPlaceViewController" bundle:nil];
    [self.navigationController pushViewController:addPlaceController animated:YES];
    [addPlaceController release];
}

- (void) cancelKeyboard: (UIControl *) button {
    [searchbox resignFirstResponder];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [venues count] + 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section < [[venues allKeys] count]) {
        return [(NSArray*)[venues objectForKey:[[venues allKeys] objectAtIndex:section]] count];
    }
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([venues count] > indexPath.section) {
        FSVenue *venue = [self extractVenueFromDictionaryForRow:indexPath];
        cell.textLabel.text = venue.name;
        cell.detailTextLabel.text = venue.addressWithCrossstreet;
	} else {
        return footerCell;
    }
    return cell;
}

- (FSVenue*) extractVenueFromDictionaryForRow:(NSIndexPath*)indexPath {
    NSString *keyForSection = [[venues allKeys] objectAtIndex:indexPath.section];
    NSArray *venuesForSection = [venues objectForKey:keyForSection];
    return (FSVenue*) [venuesForSection objectAtIndex:indexPath.row];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];
    FSVenue *venue = [self extractVenueFromDictionaryForRow:indexPath];
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
   
    placeDetailController.venueId = venue.venueid;
    [self.navigationController pushViewController:placeDetailController animated:YES];
    [placeDetailController release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == [venues count]) {
        return 50;
    }
    return 44;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 24.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // create the parent view that will hold header Label
    UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 24.0)] autorelease];
    customView.backgroundColor = [UIColor blackColor];
    
    // create the button object
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor blackColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor grayColor];
    headerLabel.highlightedTextColor = [UIColor grayColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    headerLabel.frame = CGRectMake(10.0, 0.0, 320.0, 24.0);

    if (section < [venues count]) {
        headerLabel.text = [[venues allKeys] objectAtIndex:section];
    } else {
        [headerLabel release];
        return nil;
    }
    
    [customView addSubview:headerLabel];
    [headerLabel release];
    return customView;
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
    [theTableView release];
    [searchCell release];
    [footerCell release];
    [searchbox release];
    [locationManager release];
    [bestEffortAtLocation release];
    [venues release];
    [switchingButton release];
    [super dealloc];
}

@end

