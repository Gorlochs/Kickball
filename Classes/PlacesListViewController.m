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
#import "AddPlaceFormViewController.h"
#import "LocationManager.h"
#import "FriendsListViewController.h"

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
    [self addHeaderAndFooter:theTableView];
    [self startProgressBar:@"Retrieving nearby venues..."];
    if ([FoursquareAPI sharedInstance].cachedVenues == nil) {
        [[FoursquareAPI sharedInstance] getVenuesNearLatitude:[NSString stringWithFormat:@"%f",[[LocationManager locationManager] latitude]]
                                                 andLongitude:[NSString stringWithFormat:@"%f",[[LocationManager locationManager] longitude]]
                                                   withTarget:self 
                                                    andAction:@selector(venuesResponseReceived:withResponseString:)
         
         ];   
    } else {
        self.venues = [NSDictionary dictionaryWithDictionary:[FoursquareAPI sharedInstance].cachedVenues];
        [theTableView reloadData];
        [self stopProgressBar];
    }
    
    isSearchEmpty = NO;
    [[Beacon shared] startSubBeaconWithName:@"Venue List"];
}


- (void)venuesResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSString *errorMessage = [FoursquareAPI errorFromResponseXML:inString];
    if (errorMessage) {
        [self displayFoursquareErrorMessage:errorMessage];
    } else {
        NSLog(@"venues: %@", inString);
        NSDictionary *allVenues = [FoursquareAPI venuesFromResponseXML:inString];
        self.venues = [NSDictionary dictionaryWithDictionary:allVenues];
        [FoursquareAPI sharedInstance].cachedVenues = [[NSDictionary alloc] initWithDictionary:self.venues];
        if ([self.venues count] == 0) {
            isSearchEmpty = YES;
        }
        [theTableView reloadData];
        
        //move table to new entry
        if ([theTableView numberOfSections] != 0) {
            NSUInteger indexArr[] = {0,0};
            [theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
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
    isSearchEmpty = NO;
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
    [self.navigationController pushViewController:mapViewController animated:NO];
    [mapViewController release];
}

// TODO: currently refresh button refreshes the list to the original list
- (void) refresh: (UIControl *) button {
    isSearchEmpty = NO;
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
    AddPlaceFormViewController *addPlaceController = [[AddPlaceFormViewController alloc] initWithNibName:@"AddPlaceFormViewController" bundle:nil];
    addPlaceController.newVenueName = searchbox.text;
    [self.navigationController pushViewController:addPlaceController animated:YES];
    [addPlaceController release];
//    AddPlaceViewController *addPlaceController = [[AddPlaceViewController alloc] initWithNibName:@"AddPlaceViewController" bundle:nil];
//    [self.navigationController pushViewController:addPlaceController animated:YES];
//    [addPlaceController release];
}

- (void) cancelKeyboard: (UIControl *) button {
    [searchbox resignFirstResponder];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (isSearchEmpty) {
        return 1;
    } else {
        return [venues count] + 1;
    }
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isSearchEmpty) {
        return 2;
    } else {
        if (section < [[venues allKeys] count]) {
            return [(NSArray*)[venues objectForKey:[[venues allKeys] objectAtIndex:section]] count];
        } else {
            return 1;
        }
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
        line.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.13];
        [cell addSubview:line];
        [line release];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    if (isSearchEmpty) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"No search results found.";
            cell.detailTextLabel.text = @"";
        } else {
            return footerCell;
        }
    } else {
        if ([venues count] > indexPath.section) {
            FSVenue *venue = [self extractVenueFromDictionaryForRow:indexPath];
            cell.textLabel.text = venue.name;
            cell.detailTextLabel.text = venue.addressWithCrossstreet;
        } else {
            return footerCell;
        }        
    }
    return cell;
}

- (FSVenue*) extractVenueFromDictionaryForRow:(NSIndexPath*)indexPath {
    NSString *keyForSection = [[venues allKeys] objectAtIndex:indexPath.section];
    NSArray *venuesForSection = [venues objectForKey:keyForSection];
    return (FSVenue*) [venuesForSection objectAtIndex:indexPath.row];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([venues count] > indexPath.section) {
        PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];
        FSVenue *venue = [self extractVenueFromDictionaryForRow:indexPath];
        [theTableView deselectRowAtIndexPath:indexPath animated:YES];
        
        placeDetailController.venueId = venue.venueid;
        [self.navigationController pushViewController:placeDetailController animated:YES];
        [placeDetailController release];   
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isSearchEmpty) {
        if (indexPath.section == 0) {
            return 44;
        } else {
            return 50;
        }
    } else {
        if (indexPath.section == [venues count]) {
            return 50;
        } else {
            return 44;
        }
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 24.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor whiteColor]];  
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (isSearchEmpty) {
        return nil;
    } else {
        // create the parent view that will hold header Label
        UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 24.0)] autorelease];
        customView.backgroundColor = [UIColor whiteColor];
        customView.alpha = 0.85;
        
        // create the button object
        UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.opaque = NO;
        headerLabel.textColor = [UIColor grayColor];
        headerLabel.highlightedTextColor = [UIColor grayColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:12];
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

