//
//  HistoryViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 2/7/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "HistoryViewController.h"
#import "FoursquareAPI.h"
#import "PlaceDetailViewController.h"
#import "FSCheckin.h"

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[FoursquareAPI sharedInstance] getCheckinHistoryWithTarget:self andAction:@selector(historyResponseReceived:withResponseString:)];
    
    dateFormatterD2S = [[NSDateFormatter alloc] init];
    [dateFormatterD2S setDateFormat: @"HH:mma "]; // 2009-02-01 19:50:41 PST
    
    dateFormatterS2D = [[NSDateFormatter alloc] init];
    [dateFormatterS2D setDateFormat:@"EEE, dd MMM yy HH:mm:ss"];
}

- (void) historyResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"history instring: %@", inString);
    NSArray *allCheckins = [FoursquareAPI checkinsFromResponseXML:inString];
    checkins = [allCheckins copy];
    //[allCheckins release];
    NSLog(@"checkins: %@", checkins);
    
    NSDateFormatter *dayOfWeekFormatter = [[NSDateFormatter alloc] init];
    [dayOfWeekFormatter setDateFormat: @"cccc"];
    checkinDaysOfWeek = [[NSMutableArray alloc] initWithCapacity:1];
    
    for (FSCheckin *checkin in checkins) {
        NSDate *date = [dateFormatterS2D dateFromString:checkin.created];
        NSString *dayOfWeek = [dayOfWeekFormatter stringFromDate:date];
        if (![checkinDaysOfWeek containsObject:dayOfWeek]) {
            [checkinDaysOfWeek addObject:dayOfWeek];
        }
    }
    
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
    return [checkinDaysOfWeek count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [checkins count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [checkinDaysOfWeek objectAtIndex:section];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10.0];
    }
    
    FSCheckin *checkin = [checkins objectAtIndex:indexPath.row];
    if (checkin.shout) {
        cell.textLabel.text = [NSString stringWithFormat:@"shout: \"%@\"", checkin.shout];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.textLabel.text = checkin.venue.name;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSDate *date = [dateFormatterS2D dateFromString:checkin.created];
    cell.detailTextLabel.text = [dateFormatterD2S stringFromDate:date];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FSCheckin *checkin = [checkins objectAtIndex:indexPath.row];
    if (checkin.venue) {
        PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];
        placeDetailController.venueId = checkin.venue.venueid;
        [self.navigationController pushViewController:placeDetailController animated:YES];
        [placeDetailController release];        
    }
}


- (void)dealloc {
    [theTableView release];
    [checkins release];
    [dateFormatterS2D release];
    [dateFormatterD2S release];
    [super dealloc];
}


@end

