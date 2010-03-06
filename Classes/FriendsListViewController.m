//
//  FriendsListViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 10/25/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//
//  Standard table view of friends' recent activity
//

#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "FriendsListViewController.h"
#import "FriendsListTableCellv2.h"
#import "PlaceDetailViewController.h"
#import "PlacesListViewController.h"
#import "ProfileViewController.h"
#import "FSCheckin.h"
#import "Beacon.h"
#import "FoursquareAPI.h"
#import "LoginViewModalController.h"
#import "Utilities.h"
#import "LocationManager.h"
#import "FriendRequestsViewController.h"
#import "KickballAppDelegate.h"


@interface FriendsListViewController (Private)

- (NSDate*) convertToUTC:(NSDate*)sourceDate;
- (void) addAuthToWebRequest:(NSMutableURLRequest*)requestObj email:(NSString*)email password:(NSString*)password;

@end


@implementation FriendsListViewController

@synthesize checkins, recentCheckins, todayCheckins, yesterdayCheckins;

- (void) viewDidLoad {
    [super viewDidLoad];
//    [self setupSplashAnimation];
////    [self showSplash];
////}
////
////- (void) showSplash {
//    UIViewController *modalSplashViewController = [[UIViewController alloc] init];
//    modalSplashViewController.view = splashView;
//    splashView.image = [UIImage imageNamed:@"kickballLoading40.png"];
//    [self presentModalViewController:modalSplashViewController animated:NO];
//    fadeOutImage.hidden = NO;
//    //[self.view addSubview:splashView];
//    [self performSelector:@selector(hideSplash) withObject:nil afterDelay:1.33];
//    [splashView startAnimating];
//}
//
////- (void)hideSplash:(NSString*)animationID finished:(BOOL)finished context:(void *)context {
//- (void) hideSplash {
//    
//    [self.view bringSubviewToFront:fadeOutImage];
//    [splashView stopAnimating];
//    [self.modalViewController dismissModalViewControllerAnimated:NO];
//    //splashView = nil;
//    //[self.modalViewController dismissModalViewControllerAnimated:NO];
//    [UIView setAnimationsEnabled:YES];
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationDuration:1.5];
////    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    fadeOutImage.alpha = 0;
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(continueLoadingView)];
//    [UIView commitAnimations];
//    //[splashView removeFromSuperview];
//    
//}
//
//- (void) continueLoadingView {
    welcomePageNum = 1;
    isDisplayingMore = NO;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, dd MMM yy HH:mm:ss"];
    gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    // check to see if we need to display the instruction view
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    hasViewedInstructions = [standardUserDefaults boolForKey:@"viewedInstructions"];
    instructionView.backgroundColor = [UIColor clearColor];
    
    [self addHeaderAndFooter:theTableView];
    //theTableView.separatorColor = [UIColor blackColor];
    NSData *recentCheckinsData=[[NSUserDefaults standardUserDefaults] dataForKey:@"recentCheckinsData"];
    NSData *todayCheckinsData=[[NSUserDefaults standardUserDefaults] dataForKey:@"todayCheckinsData"];
    NSData *yesterdayCheckinsData=[[NSUserDefaults standardUserDefaults] dataForKey:@"yesterdayCheckinsData"];
    if (recentCheckinsData) {
        self.recentCheckins = [NSKeyedUnarchiver unarchiveObjectWithData:recentCheckinsData];
    }
    if (todayCheckinsData) {
        self.todayCheckins = [NSKeyedUnarchiver unarchiveObjectWithData:todayCheckinsData];
    }
    if (yesterdayCheckinsData) {
        self.yesterdayCheckins = [NSKeyedUnarchiver unarchiveObjectWithData:yesterdayCheckinsData];
    }
    [theTableView reloadData];
    
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
}

- (void) doInitialDisplay {
    [[Beacon shared] startSubBeaconWithName:@"Initial Friends List Display"];
    [self startProgressBar:@"Retrieving friends' whereabouts..."]; 
    
    if (!hasViewedInstructions) {
        [iconImageView setHidden:YES];
        [self.view addSubview:instructionView];
        [self.view bringSubviewToFront:instructionView];
    }
    
    [[FoursquareAPI sharedInstance] getCheckinsWithTarget:self andAction:@selector(checkinResponseReceived:withResponseString:)];
    
    if (![self getAuthenticatedUser]) {
        [[FoursquareAPI sharedInstance] getUser:nil withTarget:self andAction:@selector(userResponseReceived:withResponseString:)];
    }
}

- (void) addAuthToWebRequest:(NSMutableURLRequest*)requestObj email:(NSString*)email password:(NSString*)password{
    NSString *authString = [[[NSString stringWithFormat:@"%@:%@", email, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodingWithLineLength:0];
    
    authString = [NSString stringWithFormat: @"Basic %@", authString];
    
    [requestObj setValue:authString forHTTPHeaderField:@"Authorization"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)userResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"authenticated user: %@", inString);
	FSUser* user = [[FoursquareAPI userFromResponseXML:inString] retain];
    if (hasViewedInstructions) {
        [self setUserIconView:user];
    }
    [self setAuthenticatedUser:user];
    NSLog(@"auth'd user: %@", user);
    [user release];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    NSLog(@"******************************************************");
    NSLog(@"******************* MEMORY WARNING!!! ****************");
    NSLog(@"******************************************************");
    [super didReceiveMemoryWarning];
    instructionView = nil;
    noNetworkView = nil;
    nextWelcomeImage = nil;
    previousWelcomeImage = nil;
    welcomeImage = nil;
    splashView = nil;
    //theTableView = nil;
    
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    instructionView = nil;
    footerViewCell = nil;
}

- (void)dealloc {
    [recentCheckins release];
    [todayCheckins release];
    [yesterdayCheckins release];
    [theTableView release];
    [checkins release];
    [mapButton release];
    [instructionView release];
    [noNetworkView release];
    [footerViewCell release];
    [moreCell release];
    [userIcons release];
    [nextWelcomeImage release];
    [previousWelcomeImage release];
    [welcomeImage release];
    [splashView release];
    [dateFormatter release];
    [gregorian release];
    [super dealloc];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return [self.recentCheckins count];
	} else if (section == 1) {
        return [self.todayCheckins count];
    } else if (section == 2) {
        if (isDisplayingMore) {
            return [self.yesterdayCheckins count];
        } else {
            return 0;
        }
    } else if (section == 3) {
        return !isDisplayingMore;
    } else if (section == 4) {
        return 1;
    }
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"starting cell for row: %d", indexPath.row);
    
    //NSLog(@"section: %d, row: %d", indexPath.section, indexPath.row);
    static NSString *CellIdentifier = @"MyCell";
    
    FriendsListTableCellv2 *cell = (FriendsListTableCellv2*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[FriendsListTableCellv2 alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        cell.imageView.image = [UIImage imageNamed:@"blank_boy2.png"];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 51, 320, 1)];
        line.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.13];
        [cell addSubview:line];
        [line release];
    }
    
    FSCheckin *checkin = nil;
    if (indexPath.section == 0) {
        checkin = [self.recentCheckins objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        checkin = [self.todayCheckins objectAtIndex:indexPath.row];
    } else if (indexPath.section == 2) {
        if (isDisplayingMore) {
            checkin = [self.yesterdayCheckins objectAtIndex:indexPath.row];
        } else {
            return nil;
        }
    } else if (indexPath.section == 3) {
        return moreCell;
    } else if (indexPath.section == 4) {
        return footerViewCell;
    }
    
    cell.userIcon.urlPath = checkin.user.photo;
    cell.textLabel.text = checkin.display;
    
    if ([checkin.display rangeOfString:@"[off the grid]"].location != NSNotFound) {
        cell.detailTextLabel.text = @"...location unknown...";
    } else if (checkin.shout != nil) {
        cell.detailTextLabel.text = checkin.shout;
    } else {
        cell.detailTextLabel.text = checkin.venue.addressWithCrossstreet;
    }
    
    UILabel *numberOfTimeUnits = [[UILabel alloc] initWithFrame:CGRectMake(285, 5, 30, 20)];
    numberOfTimeUnits.text = checkin.truncatedTimeNumeral;
    numberOfTimeUnits.font = [UIFont systemFontOfSize:20.0];
    numberOfTimeUnits.textColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    cell.accessoryView = numberOfTimeUnits;
    [numberOfTimeUnits release];
    
    if (checkin.isMayor) {
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"crown_bg.png"]];
    } else {
        cell.backgroundView = nil;
    }
    
    //NSLog(@"returning cell for row: %d", indexPath.row);
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
    
	//handle off the grid checkins.
	if (user.userId != nil) {
        [theTableView deselectRowAtIndexPath:indexPath animated:YES];
        ProfileViewController *profileController = [[ProfileViewController alloc] initWithNibName:@"ProfileView" bundle:nil];
        profileController.userId = user.userId;
        [self.navigationController pushViewController:profileController animated:YES];
        [profileController release];
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor whiteColor]];  
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 24.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 4) {
        return 50;
    } else if (indexPath.section == 3) {
        return 44;
    }
    return 52;
}

// TODO: most of the below header label stuff should be pulled up into a method in KBBBaseViewController
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	// create the parent view that will hold header Label
	UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 24.0)] autorelease];
    customView.backgroundColor = [UIColor whiteColor];
    customView.alpha = 0.85;
	
	// create the button object
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor grayColor];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:12];
	headerLabel.frame = CGRectMake(10.0, 0.0, 320.0, 24.0);
    
    // damn, this is ugly.  nil should be returned before all the above code is executed.  
    // probably should extract the headerLabel construction and just have a single switch in here
    // and pass the text into the method
    // TODO: clean this crap up
    switch (section) {
        case 0:
            if ([recentCheckins count] > 0) {
                headerLabel.text = @"Recent Check-ins                                                 Mins ago";
            } else {
                [headerLabel release];
                return nil;
            }
            break;
        case 1:
            if ([todayCheckins count] > 0) {
                headerLabel.text = @"Today                                                                     Hours ago";
            } else {
                [headerLabel release];
                return nil;
            }
            break;
        case 2:
            if ([yesterdayCheckins count] > 0 && isDisplayingMore) {
                headerLabel.text = @"Older                                                                        Days ago";
            } else {
                [headerLabel release];
                return nil;
            }
            break;
        case 3:  // more cell
        case 4:  // footer cell
            [headerLabel release];
            return nil;
        default:
            headerLabel.text = @"You shouldn't see this";
            break;
    }
	[customView addSubview:headerLabel];
    [headerLabel release];
	return customView;
}

#pragma mark IBAction methods

- (void) checkin {
    PlacesListViewController *placesListController = [[PlacesListViewController alloc] initWithNibName:@"PlacesListViewController" bundle:nil];
    [self.navigationController pushViewController:placesListController animated:NO];
    [placesListController release];
}

- (void) refresh {
	[self startProgressBar:@"Retrieving friends' whereabouts..."];
	[[FoursquareAPI sharedInstance] getCheckinsWithTarget:self andAction:@selector(checkinResponseReceived:withResponseString:)];
}

- (void) flipToMap {
    FriendsMapViewController *mapViewController = [[FriendsMapViewController alloc] initWithNibName:@"FriendsMapView" bundle:nil];
    mapViewController.checkins = [[NSArray arrayWithArray:self.recentCheckins] arrayByAddingObjectsFromArray:self.todayCheckins];
    [self.navigationController pushViewController:mapViewController animated:NO];
    [mapViewController release];
}

- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
	NSArray * allCheckins = [FoursquareAPI checkinsFromResponseXML:inString];
	self.checkins = [allCheckins copy];
    allCheckins = nil;
    
    recentCheckins = [[NSMutableArray alloc] init];
    todayCheckins = [[NSMutableArray alloc] init];
    yesterdayCheckins = [[NSMutableArray alloc] init];
    userIcons = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    NSDate *oneHourFromNow = [[NSDate alloc] initWithTimeIntervalSinceNow:-60*60*1];
    NSDate *twentyfourHoursFromNow = [[NSDate alloc] initWithTimeIntervalSinceNow:-60*60*24];
    oneHourFromNow = [self convertToUTC:oneHourFromNow];
    twentyfourHoursFromNow = [self convertToUTC:twentyfourHoursFromNow];
    
    NSUInteger unitFlags = NSMinuteCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit;
    
    for (FSCheckin *checkin in checkins) {
        NSDate *date = [dateFormatter dateFromString:checkin.created];
        if ([date compare:oneHourFromNow] == NSOrderedDescending) {
            [self.recentCheckins addObject:checkin];
        } else if ([date compare:oneHourFromNow] == NSOrderedAscending && [date compare:twentyfourHoursFromNow] == NSOrderedDescending) {
            [self.todayCheckins addObject:checkin];
        } else {
            [self.yesterdayCheckins addObject:checkin];
        }
        // create dictionary of icons to help speed up the scrolling
//        CGRect frame = CGRectMake(0, 0, 36, 36);
//        KBAsyncImageView* asyncImage = [[[KBAsyncImageView alloc] initWithFrame:frame] autorelease];
//        [asyncImage loadImageFromURL:[NSURL URLWithString:checkin.user.photo] withRoundedEdges: YES];
//        [userIcons setObject:asyncImage forKey:checkin.checkinId];
        
        NSDateComponents *components = [gregorian components:unitFlags fromDate:[self convertToUTC:[NSDate date]] toDate:date options:0];
        NSInteger minutes = [components minute] * -1;
        NSInteger hours = [components hour] * -1;
        NSInteger days = [components day] * -1;
        
        if (days == 0 && hours == 0) {
            //checkin.truncatedTimeUnits = @"min.";
            checkin.truncatedTimeNumeral = [NSString stringWithFormat:@"%02d", minutes];
        } else if (days == 0) {
            //checkin.truncatedTimeUnits = @"hours";
            checkin.truncatedTimeNumeral = [NSString stringWithFormat:@"%02d", hours];
        } else {
            //checkin.truncatedTimeUnits = @"days";
            checkin.truncatedTimeNumeral = [NSString stringWithFormat:@"%02d", days];
        }
//        NSLog(@"checkin: %@", checkin);
    }
    
    NSLog(@"all checkins: %d", [self.checkins count]);
    NSLog(@"recent checkins: %d", [self.recentCheckins count]);
    NSLog(@"today checkins: %d", [self.todayCheckins count]);
    NSLog(@"yesterday checkins: %d", [self.yesterdayCheckins count]);
    
	[theTableView reloadData];
    footerViewCell.hidden = NO;
    mapButton.hidden = NO;
    if (hasViewedInstructions) {
        [self stopProgressBar];
    }
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSData *theData=[NSKeyedArchiver archivedDataWithRootObject:checkins];
    [standardUserDefaults setObject:theData forKey:@"checkinsData"];
    
    NSData *recentCheckinsData=[NSKeyedArchiver archivedDataWithRootObject:recentCheckins];
    NSData *todayCheckinsData=[NSKeyedArchiver archivedDataWithRootObject:todayCheckins];
    NSData *yesterdayCheckinsData=[NSKeyedArchiver archivedDataWithRootObject:yesterdayCheckins];
    [standardUserDefaults setObject:recentCheckinsData forKey:@"recentCheckinsData"];
    [standardUserDefaults setObject:todayCheckinsData forKey:@"todayCheckinsData"];
    [standardUserDefaults setObject:yesterdayCheckinsData forKey:@"yesterdayCheckinsData"];
    NSLog(@"finished with checkin response");
    
    if (!hasViewedInstructions) {
        //[self stopProgressBar];
        [standardUserDefaults setBool:YES forKey:@"viewedInstructions"];
        hasViewedInstructions = YES;
        //[instructionView removeFromSuperview];
    }
}

- (void) addFriend {
    FriendRequestsViewController *friendsController = [[FriendRequestsViewController alloc] initWithNibName:@"FriendRequestsViewController" bundle:nil];
    [self.navigationController pushViewController:friendsController animated:YES];
    [friendsController release];
}

- (void) viewNextWelcomeImage {
    [self stopProgressBar];
    [instructionView removeFromSuperview];
//    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
//    [standardUserDefaults setBool:YES forKey:@"viewedInstructions"];
//    hasViewedInstructions = YES;
////    if (welcomePageNum == 1) {
////        NSString *imageName = [NSString stringWithFormat:@"welcome0%d.png", welcomePageNum + 1];
////        NSLog(@"image name: %@", imageName);
////        welcomeImage.image = [UIImage imageNamed:imageName];
////        [self.view bringSubviewToFront:nextWelcomeImage];
////        [self.view bringSubviewToFront:previousWelcomeImage];
////        welcomePageNum++;
////    } else {
//        [instructionView removeFromSuperview];
//        [self stopProgressBar];
//        [self setUserIconView:[self getAuthenticatedUser]];
//        [iconImageView setHidden:NO];
//        [self doInitialDisplay];
////    }
}

- (void) viewPreviousWelcomeImage {
//    if (welcomePageNum > 1) {
//        welcomeImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"welcome0%d.png", welcomePageNum - 1]];
//        welcomePageNum--;
//    }
}

- (void) displayOlderCheckins {
    isDisplayingMore = YES;
    NSLog(@"displayolder checkins: %d", isDisplayingMore);
    [theTableView reloadData];
}

- (void) setupSplashAnimation {
    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:1];
    for (int i = 1; i < 41; i++) {
        [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"kickballLoading%02d.png", i]]];
//        [images addObject:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"kickballLoading%02d", i] ofType:@"png"]]];
    }
    
    splashView.animationImages = [[NSArray alloc] initWithArray:images];
    [images release];
    splashView.animationDuration = 1.33;
    splashView.animationRepeatCount = 1;
}

@end

