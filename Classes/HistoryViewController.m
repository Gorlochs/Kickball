//
//  HistoryViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 2/7/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "HistoryViewController.h"
#import "FoursquareAPI.h"

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[FoursquareAPI sharedInstance] getCheckinHistoryWithTarget:self andAction:@selector(historyResponseReceived:withResponseString:)];
}

- (void) historyResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"history instring: %@", inString);
    NSArray *allCheckins = [FoursquareAPI checkinsFromResponseXML:inString];
    checkins = [allCheckins copy];
    //[allCheckins release];
    NSLog(@"checkins: %@", checkins);
    [theTableView reloadData];
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
    return [checkins count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    FSCheckin *checkin = [checkins objectAtIndex:indexPath.row];
    cell.textLabel.text = checkin.venue.name;
    cell.detailTextLabel.text = checkin.created;
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


- (void)dealloc {
    [theTableView release];
    [checkins release];
    [super dealloc];
}


@end

