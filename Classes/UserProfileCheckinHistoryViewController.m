    //
//  UserProfileCheckinHistoryViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/15/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "UserProfileCheckinHistoryViewController.h"
#import "PlaceDetailViewController.h"
#import "PlacesListTableViewCellv2.h"

@implementation UserProfileCheckinHistoryViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    checkinHistoryButton.enabled = NO;
    yourStuffButton.enabled = YES;
    yourFriendsButton.enabled = YES;
    
    [yourStuffButton setImage:[UIImage imageNamed:@"myProfileStuffTab03.png"] forState:UIControlStateNormal];
    [yourFriendsButton setImage:[UIImage imageNamed:@"myProfileFriendsTab02.png"] forState:UIControlStateNormal];
    [checkinHistoryButton setImage:[UIImage imageNamed:@"myProfileHistoryTab01.png"] forState:UIControlStateDisabled];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(instaCheckin:) name:@"touchAndHoldCheckin" object:nil];
}

- (void) instaCheckin:(NSNotification *)inNotification {
    NSString *venueId = [[inNotification userInfo] objectForKey:@"venueIdOfCell"];
    PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView_v2" bundle:nil];    
    placeDetailController.venueId = venueId;
    placeDetailController.doCheckin = YES;
    [self.navigationController pushViewController:placeDetailController animated:YES];
    [placeDetailController release]; 
}

- (void) executeFoursquareCalls {
    [self startProgressBar:@"Retrieving your check-in history..."];
    [[FoursquareAPI sharedInstance] getCheckinHistoryWithTarget:self andAction:@selector(historyResponseReceived:withResponseString:)];
    
    dateFormatterD2S = [[NSDateFormatter alloc] init];
    [dateFormatterD2S setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
    [dateFormatterD2S setDateFormat: @"HH:mma "]; // 2009-02-01 19:50:41 PST
}

- (void) historyResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSArray *allCheckins = [FoursquareAPI checkinsFromResponseXML:inString];
    checkins = [allCheckins copy];
    
    NSDateFormatter *dayOfWeekFormatter = [[NSDateFormatter alloc] init];
    [dayOfWeekFormatter setDateFormat: @"EEEE, MMMM d "];
    checkinDaysOfWeek = [[NSMutableArray alloc] initWithCapacity:1];
    checkinsByDate = [[NSMutableArray alloc] initWithCapacity:1];
    
    for (FSCheckin *theCheckin in checkins) {
        NSString *dayOfWeek = [dayOfWeekFormatter stringFromDate:[theCheckin convertUTCCheckinDateToLocal]];
        
        if (![checkinDaysOfWeek containsObject:dayOfWeek]) {
            [checkinDaysOfWeek addObject:dayOfWeek];
            NSMutableArray *tempCheckinArray = [[NSMutableArray alloc] initWithObjects:theCheckin, nil];
            [checkinsByDate addObject:tempCheckinArray];
            [tempCheckinArray release];
        } else {
            NSMutableArray *arr = [checkinsByDate objectAtIndex:[checkinsByDate count] - 1];
            [arr addObject:theCheckin];
        }
    }
    [dayOfWeekFormatter release];
    [self stopProgressBar];
    [theTableView reloadData];
}
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [checkinDaysOfWeek count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
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
    
    PlacesListTableViewCellv2 *cell = (PlacesListTableViewCellv2*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PlacesListTableViewCellv2 alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.venueName.size = CGSizeMake(210, cell.venueName.size.height);
    }
    
    FSCheckin *theCheckin = [[checkinsByDate objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (theCheckin.shout) {
        cell.venueName.text = [NSString stringWithFormat:@"shout: \"%@\"", theCheckin.shout];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.venueName.text = theCheckin.venue.name;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (theCheckin.venue) {
        cell.venueId = theCheckin.venue.venueid;
    }
    cell.categoryIcon.urlPath = theCheckin.venue.primaryCategory.iconUrl;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:[theCheckin convertUTCCheckinDateToLocal]];
    NSLog(@"date components: %@", comps);
    if ([comps hour] > 12) {
        cell.venueAddress.text = [NSString stringWithFormat:@"%02d:%02dpm", [comps hour] - 12, [comps minute]];
    } else {
        cell.venueAddress.text = [NSString stringWithFormat:@"%02d:%02dam", [comps hour], [comps minute]];
    }
    [gregorian release];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FSCheckin *theCheckin = [[checkinsByDate objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (theCheckin.venue) {
        [theTableView deselectRowAtIndexPath:indexPath animated:YES];
        PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView_v2" bundle:nil];
        placeDetailController.venueId = theCheckin.venue.venueid;
        [self.navigationController pushViewController:placeDetailController animated:YES];
        [placeDetailController release];        
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    BlackTableCellHeader *headerView = [[[BlackTableCellHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 36)] autorelease];
    headerView.leftHeaderLabel.text = [checkinDaysOfWeek objectAtIndex:section];
    return headerView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
}

#pragma mark 
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {    
    [checkins release];
    [dateFormatterS2D release];
    [dateFormatterD2S release];
    
    [checkinDaysOfWeek release];
    [checkinsByDate release];
    [super dealloc];
}


@end
