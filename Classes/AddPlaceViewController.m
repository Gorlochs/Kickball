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
#import "AddPlaceTipsViewController.h"
#import "AddPlaceFormViewController.h"
#import "Utilities.h"
#import "PlaceDetailViewController.h"

@implementation AddPlaceViewController

@synthesize checkin;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // pull this up into a method (or property)
    //FSUser *tmpUser = [self getAuthenticatedUser];
//    signedInUserIcon.imageView.image = [[Utilities sharedInstance] getCachedImage:tmpUser.photo];
//    signedInUserIcon.hidden = NO;
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

- (void)venuesResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"venues: %@", inString);
	NSDictionary *allVenues = [FoursquareAPI venuesFromResponseXML:inString];
	venues = [allVenues copy];
	[theTableView reloadData];
    [self stopProgressBar];
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
    return [venues count] > 0 ? [venues count] : 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    for (NSString *key in [venues allKeys]) {
        return [(NSArray*)[venues objectForKey:key] count];
    }
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if (indexPath.row > [(NSArray*)[venues objectForKey:@"Matching Places"] count] && ![newPlaceName.text isEqualToString:@""]) {
            return noneOfTheseCell;
        } else {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
    }
	
    // FIXME: find a better way to do this!
    if ([venues count] == 0 && ![newPlaceName.text isEqualToString:@""]) {
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
    if (section == 0 && [venues count] > 0) {
        // create the parent view that will hold header Label
        UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)] autorelease];
        customView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *gradient = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradient-top.png"]];
        gradient.frame = CGRectMake(0, 38, gradient.frame.size.width, gradient.frame.size.height);
        [customView addSubview:gradient];
        [gradient release];
        
        // create the button object
        UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.opaque = NO;
        headerLabel.textColor = [UIColor grayColor];
        headerLabel.highlightedTextColor = [UIColor grayColor];
        headerLabel.font = [UIFont systemFontOfSize:16];
        headerLabel.frame = CGRectMake(15.0, 0.0, 320.0, 24.0);
        
        headerLabel.text = @"Did you mean...";
        
        [customView addSubview:headerLabel];
        [headerLabel release];
        return customView;
    }
    return nil;
}

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

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self checkListings];
    return YES;
}


- (void)dealloc {
    [theTableView release];
    [newPlaceName release];
    
    [noneOfTheseCell release];
    
    [checkin release];
    [venues release];
    
    [super dealloc];
}


@end

