//
//  GeoApiTableViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 11/20/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "GeoApiTableViewController.h"
#import "GeoApiDetailsViewController.h"

@implementation GeoApiTableViewController

@synthesize geoAPIResults;

- (void)viewDidLoad {
    hideFooter = YES;
    pageType = KBPageTypeOther;
    pageViewType = KBPageViewTypeList;
    
    [super viewDidLoad];
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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [geoAPIResults count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Set up the cell...
    GAPlace *place = [geoAPIResults objectAtIndex:indexPath.row];
	cell.textLabel.text = place.name;
	cell.detailTextLabel.text = place.address;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [FlurryAPI logEvent:@"GeoAPI venue selected from list view"];
	GeoApiDetailsViewController *vc = [[GeoApiDetailsViewController alloc] initWithNibName:@"GeoApiDetailsView" bundle:nil];
    vc.place = [geoAPIResults objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)dealloc {
    if (geoAPIResults) [geoAPIResults release];
    [super dealloc];
}


@end

