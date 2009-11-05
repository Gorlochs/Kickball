//
//  FriendsListViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 10/25/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//
//  Standard table view of friends' recent activity
//

#import "FriendsListViewController.h"
#import "FriendsListTableCell.h"
#import "PlaceDetailViewController.h"
#import "PlacesListViewController.h"
#import "FSCheckin.h"


#import "Beacon.h"
#import "FoursquareAPI.h"

@implementation FriendsListViewController
@synthesize checkins, theTableView;
/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	if(![[FoursquareAPI sharedInstance] isAuthenticated]){
		//run sheet to log in.
		NSLog(@"Foursquare is not authenticated");
	} else {
		[[FoursquareAPI sharedInstance] getCheckinsWithTarget:self andAction:@selector(checkinResponseReceived:withResponseString:)];
	}
}


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
    theTableView = nil;
    
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // TODO: we need to separate out the checkins in the past 3 hours from the checkins not in the past 3 hours
	if(section == 0){
		return [self.checkins count];
	}
	return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    FriendsListTableCell *cell = (FriendsListTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[FriendsListTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        // TODO: I'm not sure that this is the best way to do this with 3.x - there might be a better way to do it now
        UIViewController *vc = [[UIViewController alloc]initWithNibName:@"FriendsListTableCellView" bundle:nil];
        cell = (FriendsListTableCell*) vc.view;
        [vc release];
    }
    
	FSCheckin * checkin = [self.checkins objectAtIndex:indexPath.row];
	FSUser * checkUser = checkin.user;
	
	NSString * path = checkUser.photo;
	if(path){
		NSURL *url = [NSURL URLWithString:path];
		NSData *data = [NSData dataWithContentsOfURL:url];
		UIImage *img = [[UIImage alloc] initWithData:data];
	
		cell.profileIcon.image = img;
	}
	cell.checkinDisplayLabel.text = checkin.display;
    // TODO: check to see if there is a better way to check for [off the grid]
    if (checkin.venue.venueAddress == nil || [checkin.venue.venueAddress isEqual:@""]) {
        cell.addressLabel.text = @"...location unknown...";
    } else {
        cell.addressLabel.text = checkin.venue.venueAddress;
    }
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"row selected");
    // Navigation logic may go here. Create and push another view controller.
	PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];
    placeDetailController.venue = ((FSCheckin*)[self.checkins objectAtIndex:indexPath.row]).venue;
    NSLog(@"pre venue: %@", placeDetailController.venue);
    // TODO: come up with a better way to manage the views
    [self.view addSubview:placeDetailController.view];
}

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
            headerLabel.text = @"  Last 3 Hours";
            break;
        case 1:
            headerLabel.text = @"  Today";
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
    [super dealloc];
}

#pragma mark IBAction methods

- (void) checkin {
    PlacesListViewController *placesListController = [[PlacesListViewController alloc] initWithNibName:@"PlacesListViewController" bundle:nil];
    [self.view addSubview:placesListController.view];
}

- (IBAction) flipToMap {
    FriendsMapViewController *mapViewController = [[FriendsMapViewController alloc] initWithNibName:@"FriendsMapView" bundle:nil];
    [self.view addSubview:mapViewController.view];
	mapViewController.checkins = self.checkins;
}

- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
	NSArray * allCheckins = [FoursquareAPI checkinsFromResponseXML:inString];
	self.checkins = [allCheckins copy];
	[self.theTableView reloadData];
}


@end

