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


@implementation AddPlaceViewController

@synthesize checkin;

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(void)searchOnKeywordsandLatLong {
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

- (IBAction) viewTipsForAddingNewPlace {
    AddPlaceTipsViewController *tipController = [[AddPlaceTipsViewController alloc] initWithNibName:@"AddPlaceTipsViewController" bundle:nil];
    [self.navigationController pushViewController:tipController animated:YES];
    [tipController release];
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
    }
    
    // Set up the cell...
	
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
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
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
    [self searchOnKeywordsandLatLong];
    return YES;
}


- (void)dealloc {
    [super dealloc];
}


@end

