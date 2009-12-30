//
//  AddPlaceViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 12/12/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "AddPlaceViewController.h"
#import "FoursquareAPI.h"
#import "LocationManager.h"
#import "AddPlaceTipsViewController.h"
#import "AddPlaceFormViewController.h"
#import "Utilities.h"
#import "PlaceDetailViewController.h"

@implementation AddPlaceViewController

@synthesize checkin;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // pull this up into a method (or property)
    FSUser *tmpUser = [self getAuthenticatedUser];
    signedInUserIcon.imageView.image = [[Utilities sharedInstance] getCachedImage:tmpUser.photo];
    signedInUserIcon.hidden = NO;
    isPingOn = tmpUser.isPingOn;
    isTwitterOn = tmpUser.sendToTwitter;
    twitterToggleButton.selected = isTwitterOn;
    pingToggleButton.selected = isPingOn;
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

//-(void)searchOnKeywordsandLatLong {
//    [newPlaceName resignFirstResponder];
//    if (![newPlaceName.text isEqualToString:@""]) {
//        [self startProgressBar:@"Searching..."];
//        // TODO: I am just replacing a space with a +, but other characters might give this method a headache.
//        NSLog(@"searching on latitude: %f", [[LocationManager locationManager] latitude]);
//        NSLog(@"searching on longitude: %f", [[LocationManager locationManager] longitude]);
//        [[FoursquareAPI sharedInstance] getVenuesByKeyword:[NSString stringWithFormat:@"%f", [[LocationManager locationManager] latitude]] 
//                                              andLongitude:[NSString stringWithFormat:@"%f",[[LocationManager locationManager] longitude]] 
//                                               andKeywords:[newPlaceName.text stringByReplacingOccurrencesOfString:@" " withString:@"+"]
//                                                withTarget:self 
//                                                 andAction:@selector(venuesResponseReceived:withResponseString:)
//         ];
//    }
//}

- (void)venuesResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"venues: %@", inString);
	NSDictionary *allVenues = [FoursquareAPI venuesFromResponseXML:inString];
	venues = [allVenues copy];
	[theTableView reloadData];
    [self stopProgressBar];
    
//    //move table to new entry
//    if ([theTableView numberOfSections] != 0) {
//        NSUInteger indexArr[] = {0,0};
//        [theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//        [self stopProgressBar];   
//    }
}

#pragma mark IBOutlet methods

- (void) checkinToNewVenue {
    [newPlaceName resignFirstResponder];
    if (![newPlaceName.text isEqualToString:@""]) {
        [self startProgressBar:@"Searching..."];
        // TODO: I am just replacing a space with a +, but other characters might give this method a headache.
        NSLog(@"searching on latitude: %f", [[LocationManager locationManager] latitude]);
        NSLog(@"searching on longitude: %f", [[LocationManager locationManager] longitude]);
        [[FoursquareAPI sharedInstance] getVenuesByKeyword:[NSString stringWithFormat:@"%f", [[LocationManager locationManager] latitude]] 
                                              andLongitude:[NSString stringWithFormat:@"%f",[[LocationManager locationManager] longitude]] 
                                               andKeywords:[newPlaceName.text stringByReplacingOccurrencesOfString:@" " withString:@"+"]
                                                withTarget:self 
                                                 andAction:@selector(venuesResponseReceived:withResponseString:)
         ];
    }
}

- (void) togglePing {
    isPingOn = !isPingOn;
    pingToggleButton.selected = isPingOn;
    NSLog(@"is ping on: %d", isPingOn);
}

- (void) toggleTwitter {
    isTwitterOn = !isTwitterOn;
    twitterToggleButton.selected = isTwitterOn;
    NSLog(@"is twitter on: %d", isTwitterOn);
}

- (void) viewTipsForAddingNewPlace {
    AddPlaceTipsViewController *tipController = [[AddPlaceTipsViewController alloc] initWithNibName:@"AddPlaceTipsViewController" bundle:nil];
    [self.navigationController pushViewController:tipController animated:YES];
    [tipController release];
}

- (void) switchToTextFields {
    AddPlaceFormViewController *formController = [[AddPlaceFormViewController alloc] initWithNibName:@"AddPlaceFormViewController" bundle:nil];
    formController.newVenueName = newPlaceName.text;
    [self.navigationController pushViewController:formController animated:YES];
    [formController release];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [venues count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    for (NSString *key in [venues allKeys]) {
        return [(NSArray*)[venues objectForKey:key] count] + 1;
    }
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if (indexPath.row > [(NSArray*)[venues objectForKey:@"Matching Places"] count]) {
            return noneOfTheseCell;
        } else {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
    }
	
    // FIXME: find a better way to do this!
    if (indexPath.row == [(NSArray*)[venues objectForKey:@"Matching Places"] count] 
        || ([venues count] == 0 && ![newPlaceName.text isEqualToString:@""])) {
        return noneOfTheseCell;
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
    
    if (indexPath.row != [(NSArray*)[venues objectForKey:@"Matching Places"] count]) {
        PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];
        FSVenue *venue = [self extractVenueFromDictionaryForRow:indexPath];
        [theTableView deselectRowAtIndexPath:indexPath animated:YES];
        
        placeDetailController.venueId = venue.venueid;
        placeDetailController.doCheckin = YES;
        [self.navigationController pushViewController:placeDetailController animated:YES];
        [placeDetailController release];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        // create the parent view that will hold header Label
        UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 24.0)] autorelease];
        customView.backgroundColor = [UIColor whiteColor];
        
        // create the button object
        UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor whiteColor];
        headerLabel.opaque = NO;
        headerLabel.textColor = [UIColor grayColor];
        headerLabel.highlightedTextColor = [UIColor grayColor];
        headerLabel.font = [UIFont systemFontOfSize:16];
        headerLabel.frame = CGRectMake(10.0, 0.0, 320.0, 24.0);
        
        headerLabel.text = @"Did you mean...";
        
        [customView addSubview:headerLabel];
        [headerLabel release];
        return customView;
    }
    return nil;
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self checkinToNewVenue];
    return YES;
}


- (void)dealloc {
    [theTableView release];
    [pingToggleButton release];
    [twitterToggleButton release];
    [newPlaceName release];
    
    [checkin release];
    [venues release];
    [super dealloc];
}


@end

