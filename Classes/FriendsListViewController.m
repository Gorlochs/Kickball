//
//  FriendsListViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 10/25/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//
//  Standard table view of friends' recent activity
//

#import <QuartzCore/QuartzCore.h>
#import "FriendsListViewController.h"
#import "FriendsListTableCell.h"
#import "PlaceDetailViewController.h"
#import "PlacesListViewController.h"
#import "ProfileViewController.h"
#import "FSCheckin.h"
#import "Beacon.h"
#import "FoursquareAPI.h"
#import "LoginViewModalController.h"
#import "Utilities.h"
#import "LocationManager.h"

@interface FriendsListViewController (Private)

- (NSDate*) convertToUTC:(NSDate*)sourceDate;
- (void) addAuthToWebRequest:(NSMutableURLRequest*)requestObj email:(NSString*)email password:(NSString*)password;

@end


@implementation FriendsListViewController

@synthesize checkins, recentCheckins, todayCheckins, yesterdayCheckins, theTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // this is so the cell doesn't show up before the table is filled in
    footerViewCell.hidden = YES;
    mapButton.hidden = YES;
    
	if(![[FoursquareAPI sharedInstance] isAuthenticated]){
		//run sheet to log in.
		NSLog(@"Foursquare is not authenticated");
		if (self.loginViewModal == nil)
			self.loginViewModal = [[[LoginViewModalController alloc] initWithNibName:
									NSStringFromClass([LoginViewModalController class]) bundle:nil] autorelease];
		
		self.loginViewModal.rootController = self;
		[self.navigationController presentModalViewController:self.loginViewModal animated:YES];
        
		[self.loginViewModal setRootController:self];
		[self.navigationController presentModalViewController:self.loginViewModal animated:YES];
        
	} else {
		[self doInitialDisplay];
	}
//    NSURL *url = [NSURL URLWithString:@"https://go.urbanairship.com/api/app/content"];
//    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url];
//    
//    // TEST: this is just testing communication with Airship's servers
//    [self addAuthToWebRequest:requestObj email:@"qpHHiOCAT8iYATFJa4dsIQ" password:@"PGTRPo6OTI2dvtz2xw-vfw"];    
//    NSURLResponse *response = nil;
//    NSError *error = nil;
//    NSData *returnData = [NSURLConnection sendSynchronousRequest:requestObj returningResponse:&response error:&error];
//    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
//    NSLog(@"return string: %@", returnString);
}

- (void) doInitialDisplay {
    // check to see if we need to display the instruction view
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL hasViewedInstructions = [standardUserDefaults boolForKey:@"viewedInstructions"];
    NSLog(@"hasViewedInstructions: %d", hasViewedInstructions);
    if (!hasViewedInstructions) {
        [self.view addSubview:instructionView];
    }

	[self startProgressBar:@"Retrieving friends' whereabouts..."];
	[[FoursquareAPI sharedInstance] getCheckinsWithTarget:self andAction:@selector(checkinResponseReceived:withResponseString:)];
	
	// testing
	//[[FoursquareAPI sharedInstance ] doSendFriendRequest:@"53961" withTarget:self andAction:@selector(sendFriendRequestResponseReceived:withResponseString:)];
	//[[FoursquareAPI sharedInstance ] findFriendsByName:@"francine" withTarget:self andAction:@selector(findFriendsResponseReceived:withResponseString:)];
	
    // FIXME: fix this. this seems out of place here
	// this didn't work in the appdelegate (timing issues), so it's in the first page, but it's going to set an appDelegate property
	// probably should be put back in the appdelegate with a notification that this page checks for
	[[FoursquareAPI sharedInstance] getUser:nil withTarget:self andAction:@selector(userResponseReceived:withResponseString:)];
	
	
}

//- (void)findFriendsResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
//    NSLog(@"find friend instring: %@", inString);
//    NSArray *users = [FoursquareAPI usersFromResponseXML:inString];
//    NSLog(@"users: %@", users);
//}

- (void) addAuthToWebRequest:(NSMutableURLRequest*)requestObj email:(NSString*)email password:(NSString*)password{
    NSString *authString = [[[NSString stringWithFormat:@"%@:%@", email, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodingWithLineLength:0];
    
    authString = [NSString stringWithFormat: @"Basic %@", authString];
    
    [requestObj setValue:authString forHTTPHeaderField:@"Authorization"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)userResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
	FSUser* user = [FoursquareAPI userFromResponseXML:inString];
    
    [signedInUserIcon setImage:[[Utilities sharedInstance] getCachedImage:user.photo] forState:UIControlStateNormal];
//    signedInUserIcon.imageView.image = [[Utilities sharedInstance] getCachedImage:user.photo];
    signedInUserIcon.hidden = NO;
    
    [self setAuthenticatedUser:user];
    NSLog(@"auth'd user: %@", user);
//    [[LocationManager locationManager] stopUpdates];
    //[self displayPopupMessage:@"1" andSubtitle:@"2" andMessage:@"3"];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    theTableView = nil;
    
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    instructionView = nil;
    footerViewCell = nil;
}

- (void)dealloc {
    [shoutField release];
    [recentCheckins release];
    [todayCheckins release];
    [yesterdayCheckins release];
    [theTableView release];
    [checkins release];
    [instructionView release];
    [footerViewCell release];
    [super dealloc];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    int rows = 0;
//    if ([self.recentCheckins count] > 0) 
//        rows++;
//    if ([self.todayCheckins count] > 0) 
//        rows++;
//    if ([self.yesterdayCheckins count] > 0) 
//        rows++;
//    return rows;
    return 4;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
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
        if (indexPath.section == 3) {
            return footerViewCell;
        }
        //cell = [[[FriendsListTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        // TODO: I'm not sure that this is the best way to do this with 3.x - there might be a better way to do it now
        UIViewController *vc = [[UIViewController alloc]initWithNibName:@"FriendsListTableCellView" bundle:nil];
        cell = (FriendsListTableCell*) vc.view;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        [vc release];
    }
    
    FSCheckin *checkin = nil;
    if (indexPath.section == 0) {
        checkin = [self.recentCheckins objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        checkin = [self.todayCheckins objectAtIndex:indexPath.row];
    } else if (indexPath.section == 2) {
        checkin = [self.yesterdayCheckins objectAtIndex:indexPath.row];
    } else if (indexPath.section == 3) {
        return footerViewCell;
    }
	
	FSUser * checkUser = checkin.user;
	
    // create icon image
	NSString * path = checkUser.photo;
	if (path) {
        cell.profileIcon.image = [[Utilities sharedInstance] getCachedImage:checkUser.photo];
        cell.profileIcon.layer.masksToBounds = YES;
        cell.profileIcon.layer.cornerRadius = 4.0;
        //cell.profileIcon.layer.borderWidth = 1.0;
    }
	cell.checkinDisplayLabel.text = checkin.display;
    // TODO: check to see if there is a better way to check for [off the grid]
    if ([checkin.display rangeOfString:@"[off the grid]"].location != NSNotFound) {
        cell.addressLabel.text = @"...location unknown...";
    } else if (checkin.shout != nil) {
        cell.addressLabel.text = checkin.shout;
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
    FSUser *user = nil;
    switch (indexPath.section) {
        case 0: // last 3 hours
            user = ((FSCheckin*)[self.recentCheckins objectAtIndex:indexPath.row]).user;
            break;
        case 1: //today
            user = ((FSCheckin*)[self.todayCheckins objectAtIndex:indexPath.row]).user;
            break;
        case 2: //yesterday
            user = ((FSCheckin*)[self.yesterdayCheckins objectAtIndex:indexPath.row]).user;
            break;
        default:
            break;
    }
    
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
	ProfileViewController *profileController = [[ProfileViewController alloc] initWithNibName:@"ProfileView" bundle:nil];
	//handle off the grid checkins.
	if (user.userId != nil) {
        profileController.userId = user.userId;
        [self.navigationController pushViewController:profileController animated:YES];
	}
    [profileController release];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 24.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        return 50;
    }
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	// create the parent view that will hold header Label
	UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 24.0)] autorelease];
    customView.backgroundColor = [UIColor blackColor];
	
	// create the button object
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor blackColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor grayColor];
	headerLabel.highlightedTextColor = [UIColor grayColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:12];
	headerLabel.frame = CGRectMake(10.0, 0.0, 320.0, 24.0);
    
    // damn, this is ugly.  nil should be returned before all the above code is executed.  
    // probably should extract the headerLabel construction and just have a single switch in here
    // and pass the text into the method
    // TODO: clean this crap up
    switch (section) {
        case 0:
            if ([recentCheckins count] > 0) {
                headerLabel.text = @"Last 3 Hours";
            } else {
                [headerLabel release];
                return nil;
            }
            break;
        case 1:
            if ([todayCheckins count] > 0) {
                headerLabel.text = @"Today";
            } else {
                [headerLabel release];
                return nil;
            }
            break;
        case 2:
            if ([yesterdayCheckins count] > 0) {
                headerLabel.text = @"Older";
            } else {
                [headerLabel release];
                return nil;
            }
            break;
        case 3:  // footer cell
            [headerLabel release];
            return nil;
        default:
            headerLabel.text = @"You shouldn't see this";
            break;
    }
	//headerLabel.text = <Put here whatever you want to display> // i.e. array element
	[customView addSubview:headerLabel];
    [headerLabel release];
	return customView;
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

//- (void)friendsResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
//    NSLog(@"friends: %@", inString);
//}

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
    threeHoursFromNow = [self convertToUTC:threeHoursFromNow];
    twentyfourHoursFromNow = [self convertToUTC:twentyfourHoursFromNow];
    
    for (FSCheckin *checkin in checkins) {
        NSDate *date = [dateFormatter dateFromString:checkin.created];
        if ([date compare:threeHoursFromNow] == NSOrderedDescending) {
            [recentCheckins addObject:checkin];
        } else if ([date compare:threeHoursFromNow] == NSOrderedAscending && [date compare:twentyfourHoursFromNow] == NSOrderedDescending) {
            [todayCheckins addObject:checkin];
        } else {
            [yesterdayCheckins addObject:checkin];
        }
    }
    NSLog(@"all checkins: %d", [checkins count]);
    NSLog(@"recent checkins: %d", [recentCheckins count]);
    NSLog(@"today checkins: %d", [todayCheckins count]);
    NSLog(@"yesterday checkins: %d", [yesterdayCheckins count]);
    
//    [threeHoursFromNow release];
//    [twentyfourHoursFromNow release];
    [dateFormatter release];
	[self.theTableView reloadData];
    footerViewCell.hidden = NO;
    mapButton.hidden = NO;
    [self stopProgressBar];
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
    
    // TODO: confirm that the shout was sent?
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Kickball" 
													message:@"Your shout was sent!"
												   delegate:self 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
    
    [theTableView reloadData];
}

- (void) addFriend {
    NSLog(@"******** adding friend *********");
}

@end

