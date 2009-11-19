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

@interface FriendsListViewController (Private)

- (NSDate*) convertToUTC:(NSDate*)sourceDate;

@end


@implementation FriendsListViewController
@synthesize checkins, recentCheckins, todayCheckins, yesterdayCheckins, theTableView;

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
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // TODO: we need to separate out the checkins in the past 3 hours from the checkins not in the past 3 hours
	if (section == 0) {
		return [self.recentCheckins count];
	} else if (section == 1) {
        return [self.todayCheckins count];
    } else if (section == 2) {
        return [self.yesterdayCheckins count];
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
        cell.selectionStyle = UITableViewCellSelectionStyleGray;\
        [vc release];
    }
    
    FSCheckin *checkin = nil;
    if (indexPath.section == 0) {
        checkin = [self.recentCheckins objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        checkin = [self.todayCheckins objectAtIndex:indexPath.row];
    } else if (indexPath.section == 2) {
        checkin = [self.yesterdayCheckins objectAtIndex:indexPath.row];
    }
	
	FSUser * checkUser = checkin.user;
	
	NSString * path = checkUser.photo;
	if(path){
		NSURL *url = [NSURL URLWithString:path];
		NSData *data = [NSData dataWithContentsOfURL:url];
		UIImage *img = [[UIImage alloc] initWithData:data];
	
		cell.profileIcon.image = img;
        [img release];
	}
	cell.checkinDisplayLabel.text = checkin.display;
    // TODO: check to see if there is a better way to check for [off the grid]
    if (checkin.venue.venueAddress == nil || [checkin.venue.venueAddress isEqual:@""]) {
        cell.addressLabel.text = @"...location unknown...";
    } else {
        cell.addressLabel.text = checkin.venue.venueAddress;
    }
    
    // probably break this out into another method
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, dd MMM yy HH:mm:ss"];
    NSDate *checkinDate = [dateFormatter dateFromString:checkin.created];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSMinuteCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit;
    NSDateComponents *components = [gregorian components:unitFlags fromDate:[self convertToUTC:[NSDate date]] toDate:checkinDate options:0];
    NSInteger minutes = [components minute] * -1;
    NSInteger hours = [components hour] * -1;
    NSInteger days = [components day] * -1;

    // odd logic, I know, but the logical logic didn't work
    if (days == 0 && hours == 0) {
        cell.timeUnits.text = @"min.";
        cell.numberOfTimeUnits.text = [NSString stringWithFormat:@"%02d", minutes];
    } else if (days == 0) {
        cell.timeUnits.text = @"hours";
        cell.numberOfTimeUnits.text = [NSString stringWithFormat:@"%02d", hours];
    } else {
        cell.timeUnits.text = @"days";
        cell.numberOfTimeUnits.text = [NSString stringWithFormat:@"%02d", days];
    }
    [dateFormatter release];
    
	return cell;
}

- (NSDate*) convertToUTC:(NSDate*)sourceDate {
    NSTimeZone* currentTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone* utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval gmtInterval = gmtOffset - currentGMTOffset;
    
    NSDate* destinationDate = [[[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:sourceDate] autorelease];     
    return destinationDate;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"row selected");
    FSVenue *venue = nil;
    switch (indexPath.section) {
        case 0: // last 3 hours
            venue = ((FSCheckin*)[self.recentCheckins objectAtIndex:indexPath.row]).venue;
            break;
        case 1: //today
            venue = ((FSCheckin*)[self.todayCheckins objectAtIndex:indexPath.row]).venue;
            break;
        case 2: //yesterday
            venue = ((FSCheckin*)[self.yesterdayCheckins objectAtIndex:indexPath.row]).venue;
            break;
        default:
            break;
    }
    
	PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];
	//handle off the grid checkins.
	if (venue.venueid != nil) {
		placeDetailController.venueId = venue.venueid;
        [self.navigationController pushViewController:placeDetailController animated:YES];
	}
    [placeDetailController release];
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
	headerLabel.frame = CGRectMake(0.0, 0.0, 320.0, 24.0);
    
	// If you want to align the header text as centered
	// headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
    switch (section) {
        case 0:
            headerLabel.text = @"  Last 3 Hours";
            break;
        case 1:
            headerLabel.text = @"  Today";
            break;
        case 2:
            headerLabel.text = @"  Older";
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


- (void)dealloc {
    [theTableView release];
    [checkins release];
    [super dealloc];
}

#pragma mark IBAction methods

- (void) checkin {
    PlacesListViewController *placesListController = [[PlacesListViewController alloc] initWithNibName:@"PlacesListViewController" bundle:nil];
    [self.navigationController pushViewController:placesListController animated:YES];
    [placesListController release];
}

- (IBAction) flipToMap {
    FriendsMapViewController *mapViewController = [[FriendsMapViewController alloc] initWithNibName:@"FriendsMapView" bundle:nil];
    mapViewController.checkins = self.checkins;
    [self.navigationController pushViewController:mapViewController animated:YES];
    [mapViewController release];
}

- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
	NSArray * allCheckins = [FoursquareAPI checkinsFromResponseXML:inString];
	self.checkins = [allCheckins copy];
    
    recentCheckins = [[NSMutableArray alloc] init];
    todayCheckins = [[NSMutableArray alloc] init];
    yesterdayCheckins = [[NSMutableArray alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, dd MMM yy HH:mm:ss"];
    
    NSDate *threeHoursFromNow = [[NSDate alloc] initWithTimeIntervalSinceNow:-60*60*3];
    NSDate *twentyfourHoursFromNow = [[NSDate alloc] initWithTimeIntervalSinceNow:-60*60*24];
    
    for (FSCheckin *checkin in checkins) {
        NSDate *date = [dateFormatter dateFromString:checkin.created];
        if ([date compare:threeHoursFromNow] == NSOrderedDescending) {
            [recentCheckins addObject:checkin];
        } else if ([date compare:threeHoursFromNow] == NSOrderedAscending  && [date compare:twentyfourHoursFromNow] == NSOrderedDescending) {
            [todayCheckins addObject:checkin];
        } else {
            [yesterdayCheckins addObject:checkin];
        }
    }
    NSLog(@"all checkins: %d", [checkins count]);
    NSLog(@"recent checkins: %d", [recentCheckins count]);
    NSLog(@"today checkins: %d", [todayCheckins count]);
    NSLog(@"yesterday checkins: %d", [yesterdayCheckins count]);
    
    [threeHoursFromNow release];
    [twentyfourHoursFromNow release];
    [dateFormatter release];
	[self.theTableView reloadData];
}

- (void) shout {
    if ([shoutField.text length] > 0) {
        if(![[FoursquareAPI sharedInstance] isAuthenticated]){
            //run sheet to log in.
            NSLog(@"Foursquare is not authenticated");
        } else {
            [[FoursquareAPI sharedInstance] doCheckinAtVenueWithId:nil 
                                                          andShout:shoutField.text 
                                                           offGrid:NO
                                                         toTwitter:NO
                                                        withTarget:self 
                                                         andAction:@selector(shoutResponseReceived:withResponseString:)];
        }
    } else {
        NSLog(@"no text in shout field");
    }
}

- (void)shoutResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"instring: %@", inString);
	NSArray *shoutCheckins = [FoursquareAPI checkinsFromResponseXML:inString];
    NSLog(@"shoutCheckins: %@", shoutCheckins);
    [shoutField resignFirstResponder];
//    isUserCheckedIn = YES;
    // TODO: display some notification to user to let them know that the shout was sent
    [theTableView reloadData];
}

@end

