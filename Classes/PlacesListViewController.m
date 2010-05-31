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
#import "KBLocationManager.h"
#import "FriendsListViewController.h"
#import "PlacesListTableViewCellv2.h"
#import "TableSectionHeaderView.h"

@interface PlacesListViewController (Private)

- (void)stopUpdatingLocation:(NSString *)state;
- (void)venuesResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;
- (FSVenue*) extractVenueFromDictionaryForRow:(NSIndexPath*)indexPath;

@end

@implementation PlacesListViewController

@synthesize searchCell;
@synthesize venues;


- (void)viewDidLoad {
    
    pageType = KBPageTypePlaces;
    pageViewType = KBPageViewTypeList;
    
    [super viewDidLoad];
    
    NSLog(@"PlacesListViewController get venue - geolat: %f", [[KBLocationManager locationManager] latitude]);
    NSLog(@"PlacesListViewController get venue - geolong: %f", [[KBLocationManager locationManager] longitude]);
    [self addHeaderAndFooter:theTableView];
    [self startProgressBar:@"Retrieving nearby venues..."];
    if ([FoursquareAPI sharedInstance].cachedVenues == nil) {
        [[FoursquareAPI sharedInstance] getVenuesNearLatitude:[NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] latitude]]
                                                 andLongitude:[NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] longitude]]
                                                   withTarget:self 
                                                    andAction:@selector(venuesResponseReceived:withResponseString:)
         
         ];   
    } else {
        self.venues = [NSDictionary dictionaryWithDictionary:[FoursquareAPI sharedInstance].cachedVenues];
        [theTableView reloadData];
        [self stopProgressBar];
    }
    
    isSearchEmpty = NO;
    [FlurryAPI logEvent:@"Venue List"];
}


- (void)venuesResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"venue list: %@", inString);
    NSString *errorMessage = [FoursquareAPI errorFromResponseXML:inString];
    if (errorMessage) {
        NSLog(@"error found in Places List");
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
        [[FoursquareAPI sharedInstance] getVenuesByKeyword:[searchbox.text stringByReplacingOccurrencesOfString:@" " withString:@"+"]
                                               andLatitude:[NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] latitude]] 
                                              andLongitude:[NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] longitude]] 
                                                withTarget:self 
                                                 andAction:@selector(venuesResponseReceived:withResponseString:)
         ];
        [FlurryAPI logEvent:@"Venue Search from Venue List View"];
    }
}

- (void) flipBetweenMapAndList {
    PlacesMapViewController *mapViewController = [[PlacesMapViewController alloc] initWithNibName:@"PlacesMapView_v2" bundle:nil];
    // TODO: do we need to combine both items in the venues array?
    NSMutableArray *allvenues = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSString *key in [venues allKeys]) {
        [allvenues addObjectsFromArray:[venues objectForKey:key]];
    }
    
	mapViewController.venues = allvenues;
    mapViewController.searchKeywords = searchbox.text;
    [allvenues release];
    [self.navigationController pushViewController:mapViewController animated:NO];
    [mapViewController release];
}

// TODO: currently refresh button refreshes the list to the original list
- (void) refresh: (UIControl *) button {
    isSearchEmpty = NO;
    [self startProgressBar:@"Retrieving nearby venues..."];
    [[FoursquareAPI sharedInstance] getVenuesNearLatitude:[NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] latitude]] 
                                             andLongitude:[NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] longitude]]
                                               withTarget:self 
                                                andAction:@selector(venuesResponseReceived:withResponseString:)
     ];
    [FlurryAPI logEvent:@"Refreshing Venue List"];
    
    venuesTypeToDisplay = KBNearbyVenues;
}

- (void) addNewVenue {
    AddPlaceViewController *addPlaceController = [[AddPlaceViewController alloc] initWithNibName:@"AddVenueViewController_v2" bundle:nil];
    addPlaceController.newVenueName = searchbox.text;
    [self.navigationController pushViewController:addPlaceController animated:YES];
    [addPlaceController release];
    
//    AddPlaceViewController *addPlaceController = [[AddPlaceViewController alloc] initWithNibName:@"AddPlaceViewControllerv2" bundle:nil];
//    [self.navigationController pushViewController:addPlaceController animated:YES];
//    [addPlaceController release];
}

- (void) cancelKeyboard: (UIControl *) button {
    [self cancelTheKeyboard];
}

- (void) cancelTheKeyboard {
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
    
    PlacesListTableViewCellv2 *cell = (PlacesListTableViewCellv2*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PlacesListTableViewCellv2 alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.imageView.image = nil;
    if (isSearchEmpty) {
        if (indexPath.row == 0) {
            cell.venueName.text = @"No search results found.";
            cell.venueAddress.text = @"";
        } else {
            return footerCell;
        }
    } else {
        if ([venues count] > indexPath.section) {
            FSVenue *venue = [self extractVenueFromDictionaryForRow:indexPath];
            cell.venueName.text = venue.name;
            cell.venueAddress.text = venue.addressWithCrossstreet;
            cell.venueId = venue.venueid;
            cell.categoryIcon.urlPath = venue.primaryCategory.iconUrl;
            if (venue.specials && [venue.specials count] > 0) {
                cell.specialImage.hidden = NO;
            } else {
                cell.specialImage.hidden = YES;
            }

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
        PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView_v2" bundle:nil];
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
            return 38;
        }
    } else {
        if (indexPath.section == [venues count]) {
            return 38;
        } else {
            return 44;
        }
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 30.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];  
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (isSearchEmpty) {
        return nil;
    } else {
        
        TableSectionHeaderView *headerView = [[[TableSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)] autorelease];
        
        if (section < [venues count]) {
            headerView.leftHeaderLabel.text = [[venues allKeys] objectAtIndex:section];
        } else {
            return nil;
        }

        return headerView;
    }
}

#pragma mark 
#pragma mark table refresh methods

- (void) refreshTable {        
    [[FoursquareAPI sharedInstance] getVenuesNearLatitude:[NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] latitude]]
                                             andLongitude:[NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] longitude]]
                                               withTarget:self 
                                                andAction:@selector(venuesRefreshResponseReceived:withResponseString:)
     ];
}

- (void)venuesRefreshResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    [self venuesResponseReceived:inURL withResponseString:inString];
	[self dataSourceDidFinishLoadingNewData];
}

#pragma mark 
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [searchbox resignFirstResponder];
    [self searchOnKeywordsandLatLong];
    return YES;
}

- (void) cancelEdit {
    [self cancelTheKeyboard];
    searchbox.text = @"";
}

- (void)dealloc {
    [searchCell release];
    [footerCell release];
    [searchbox release];
    [venues release];
    [super dealloc];
}

@end

