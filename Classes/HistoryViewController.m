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
    [self startProgressBar:@"Retrieving your check-in history..."];
    [[FoursquareAPI sharedInstance] getCheckinHistoryWithTarget:self andAction:@selector(historyResponseReceived:withResponseString:)];
    
    dateFormatterD2S = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatterD2S setLocale:locale];
    [locale release];
    [dateFormatterD2S setDateFormat: @"HH:mma "]; // 2009-02-01 19:50:41 PST
}

- (void) historyResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSArray *allCheckins = [FoursquareAPI checkinsFromResponseXML:inString];
    checkins = [allCheckins copy];
    
    NSDateFormatter *dayOfWeekFormatter = [[NSDateFormatter alloc] init];
    [dayOfWeekFormatter setDateFormat: @"EEEE, MMMM d "];
    //[dayOfWeekFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    checkinDaysOfWeek = [[NSMutableArray alloc] initWithCapacity:1];
    checkinsByDate = [[NSMutableArray alloc] initWithCapacity:1];
    
    for (FSCheckin *checkin in checkins) {
        NSString *dayOfWeek = [dayOfWeekFormatter stringFromDate:[checkin convertUTCCheckinDateToLocal]];
        
        if (![checkinDaysOfWeek containsObject:dayOfWeek]) {
            [checkinDaysOfWeek addObject:dayOfWeek];
            NSMutableArray *tempCheckinArray = [[NSMutableArray alloc] initWithObjects:checkin, nil];
            [checkinsByDate addObject:tempCheckinArray];
            [tempCheckinArray release];
        } else {
            NSMutableArray *arr = [checkinsByDate objectAtIndex:[checkinsByDate count] - 1];
            [arr addObject:checkin];
        }
    }
    [dayOfWeekFormatter release];
    [self stopProgressBar];
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
    return [(NSArray*)[checkinsByDate objectAtIndex:section] count];
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
    
    FSCheckin *checkin = [[checkinsByDate objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (checkin.shout) {
        cell.textLabel.text = [NSString stringWithFormat:@"shout: \"%@\"", checkin.shout];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.textLabel.text = checkin.venue.name;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:[checkin convertUTCCheckinDateToLocal]];
    NSLog(@"date components: %@", comps);
    if ([comps hour] > 12) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%02d:%02dpm", [comps hour] - 12, [comps minute]];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%02d:%02dam", [comps hour], [comps minute]];
    }
    [gregorian release];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FSCheckin *checkin = [[checkinsByDate objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (checkin.venue) {
        [theTableView deselectRowAtIndexPath:indexPath animated:YES];
        PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView_v2" bundle:nil];
        placeDetailController.venueId = checkin.venue.venueid;
        [self.navigationController pushViewController:placeDetailController animated:YES];
        [placeDetailController release];        
    }
}


- (void)dealloc {
    [theTableView release];
    [checkins release];
    [dateFormatterD2S release];
    [super dealloc];
}


@end

