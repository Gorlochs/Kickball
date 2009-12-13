//
//  PlacesListViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 10/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PlacesListViewController.h"
#import "PlaceDetailViewController.h"
#import "PlacesMapViewController.h"
#import "FoursquareAPI.h"
#import "FSCheckin.h"
#import "AddPlaceViewController.h"

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
    
    [self startProgressBar:@"Retrieving nearby venues..."];
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    locationManager.delegate = self;
    // This is the most important property to set for the manager. It ultimately determines how the manager will
    // attempt to acquire location and thus, the amount of power that will be consumed.
//    locationManager.desiredAccuracy = [[setupInfo objectForKey:kSetupInfoKeyAccuracy] doubleValue];
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    // Once configured, the location manager must be "started".
    [locationManager startUpdatingLocation];
    
    if(![[FoursquareAPI sharedInstance] isAuthenticated]){
		//run sheet to log in.
		NSLog(@"Foursquare is not authenticated");
	} else {
		//[[FoursquareAPI sharedInstance] getCheckinsWithTarget:self andAction:@selector(checkinResponseReceived:withResponseString:)];
	}
    
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
	self.venues = [allVenues copy];
	[theTableView reloadData];
    
    //move table to new entry
    if ([theTableView numberOfSections] != 0) {
        NSUInteger indexArr[] = {0,0};
        [theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [self stopProgressBar];   
    }
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
        [[FoursquareAPI sharedInstance] getVenuesByKeyword:[NSString stringWithFormat:@"%f",bestEffortAtLocation.coordinate.latitude] 
                                              andLongitude:[NSString stringWithFormat:@"%f",bestEffortAtLocation.coordinate.longitude] 
                                               andKeywords:[searchbox.text stringByReplacingOccurrencesOfString:@" " withString:@"+"]
                                                withTarget:self 
                                                 andAction:@selector(venuesResponseReceived:withResponseString:)
         ];
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

- (void) refresh {
    [self startProgressBar:@"Retrieving nearby venues..."];
    [[FoursquareAPI sharedInstance] getVenuesNearLatitude:[NSString stringWithFormat:@"%f",bestEffortAtLocation.coordinate.latitude] 
                                             andLongitude:[NSString stringWithFormat:@"%f",bestEffortAtLocation.coordinate.longitude]
                                               withTarget:self 
                                                andAction:@selector(venuesResponseReceived:withResponseString:)
     ];
    
    venuesTypeToDisplay = KBNearbyVenues;
}

- (void) addNewVenue {
    AddPlaceViewController *addPlaceController = [[AddPlaceViewController alloc] initWithNibName:@"AddPlaceViewController" bundle:nil];
    [self.navigationController pushViewController:addPlaceController animated:YES];
    [addPlaceController release];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [venues count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    for (NSString *key in [venues allKeys]) {
        return [(NSArray*)[venues objectForKey:key] count];
    }
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
    }
    
    if ([venues count] >= indexPath.section) {
        FSVenue *venue = [self extractVenueFromDictionaryForRow:indexPath];
        cell.textLabel.text = venue.name;
        cell.detailTextLabel.text = venue.addressWithCrossstreet;
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

    headerLabel.text = [[venues allKeys] objectAtIndex:section];
    
    [customView addSubview:headerLabel];
    [headerLabel release];
    return customView;
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self searchOnKeywordsandLatLong];
    return YES;
}

- (void)dealloc {
    [theTableView release];
    [searchCell release];
    [searchbox release];
    [locationManager release];
    [bestEffortAtLocation release];
    [venues release];
    [super dealloc];
}


@end

