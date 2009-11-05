//
//  PlacesListViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 10/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PlacesListViewController.h"
#import "PlaceDetailViewController.h"
#import "FoursquareAPI.h"

@interface PlacesListViewController (Private)

- (void)stopUpdatingLocation:(NSString *)state;
- (void)venuesResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;

@end

@implementation PlacesListViewController

@synthesize searchCell;
@synthesize locationManager;
@synthesize bestEffortAtLocation;
@synthesize venues;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
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
    
    [super viewDidLoad];
}

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
    // update the display with the new location data
    //[theTableView reloadData];
    
    // RUN FOURSQUARE API CALL HERE
    [[FoursquareAPI sharedInstance] getVenuesNearLatitude:[NSString stringWithFormat:@"%f",bestEffortAtLocation.coordinate.latitude] 
                                             andLongitude:[NSString stringWithFormat:@"%f",bestEffortAtLocation.coordinate.longitude]
                                               withTarget:self 
                                                andAction:@selector(venuesResponseReceived:withResponseString:)
     ];
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
    
    // TODO: RUN FOURSQUARE API CALL HERE
    
//    UIBarButtonItem *resetItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reset", @"Reset") style:UIBarButtonItemStyleBordered target:self action:@selector(reset)] autorelease];
//    [self.navigationItem setLeftBarButtonItem:resetItem animated:YES];;
}

- (void)venuesResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
	NSArray *allVenues = [FoursquareAPI venuesFromResponseXML:inString];
	self.venues = [allVenues copy];
	[theTableView reloadData];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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
    theTableView = nil;
    searchCell = nil;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    theTableView = nil;
    searchCell = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [(NSArray*)[venues objectAtIndex:0] count];
    } else if (section == 1) {
        return [(NSArray*)[venues objectAtIndex:1] count];
    }
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
    if (indexPath.section == 0) {
        cell.textLabel.text = ((FSVenue*) [(NSArray*)[venues objectAtIndex:0] objectAtIndex:indexPath.row]).name;
    } else if (indexPath.section == 1) {
        cell.textLabel.text = ((FSVenue*) [(NSArray*)[venues objectAtIndex:1] objectAtIndex:indexPath.row]).name;
    }
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	PlaceDetailViewController *placeDetailController = [[[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil] autorelease];
    [self.view addSubview:placeDetailController.view];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    switch (indexPath.section) {
//        case 0:
//            return 62;
//        case 2:
//            return 62;
//        default:
//            return 44;
//    }
//}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 24.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // create the parent view that will hold header Label
    UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 24.0)] autorelease];
    
    // create the button object
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor blackColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor grayColor];
    headerLabel.highlightedTextColor = [UIColor grayColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:12];
    headerLabel.frame = CGRectMake(00.0, 0.0, 320.0, 24.0);
    
    // If you want to align the header text as centered
    // headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
    switch (section) {
        case 0:
            headerLabel.text = @"  Nearby Favorites";
            break;
        case 1:
            headerLabel.text = @"  Nearby";
            break;
        default:
            headerLabel.text = @"You shouldn't see this";
            break;
    }
    //headerLabel.text = <Put here whatever you want to display> // i.e. array element
    [customView addSubview:headerLabel];
    [headerLabel release];
    return customView;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [theTableView release];
    [searchCell release];
    [locationManager release];
    [bestEffortAtLocation release];
    [super dealloc];
}


@end

