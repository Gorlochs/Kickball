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
#import "FriendRequestsViewController.h"
#import "KickballAppDelegate.h"

@interface FriendsListViewController (Private)

- (NSDate*) convertToUTC:(NSDate*)sourceDate;
- (void) addAuthToWebRequest:(NSMutableURLRequest*)requestObj email:(NSString*)email password:(NSString*)password;

@end


@implementation FriendsListViewController

@synthesize checkins, recentCheckins, todayCheckins, yesterdayCheckins;


- (void)viewDidLoad {
    [super viewDidLoad];
//    [self setupSplashAnimation];
//    [self showSplash];
//}
//
//-(void)showSplash {
//    UIViewController *modalViewController = [[UIViewController alloc] init];
//    modalViewController.view = splashView;
//    //[self presentModalViewController:modalViewController animated:NO];
//    [self.view addSubview:splashView];
//    //[UIView setAnimationDidStopSelector:@selector(hideSplash:finished:context:)];
//    [self performSelector:@selector(hideSplash) withObject:nil afterDelay:2.05];
//    [splashView startAnimating];
//}
//
////- (void)hideSplash:(NSString*)animationID finished:(BOOL)finished context:(void *)context {
//- (void) hideSplash {
//    [splashView stopAnimating];
//    //[[self modalViewController] dismissModalViewControllerAnimated:NO];
//    [splashView removeFromSuperview];

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
    
//    mayorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"crown.png"]];
    
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
    NSLog(@"hasViewedInstructions: %d", hasViewedInstructions);
    if (!hasViewedInstructions) {
        //[self startProgressBar:@"Loading Everything..."];
        [iconImageView setHidden:YES];
        [self.view addSubview:instructionView];
        [self.view bringSubviewToFront:nextWelcomeImage];
        [self.view bringSubviewToFront:previousWelcomeImage];
    } else {
        nextWelcomeImage = nil;
        previousWelcomeImage = nil;
        welcomeImage = nil;
        instructionView = nil;
        [[Beacon shared] startSubBeaconWithName:@"Initial Friends List Display"];
        [self startProgressBar:@"Retrieving friends' whereabouts..."]; 
        
        [[FoursquareAPI sharedInstance] getCheckinsWithTarget:self andAction:@selector(checkinResponseReceived:withResponseString:)];
        
        if (![self getAuthenticatedUser]) {
            [[FoursquareAPI sharedInstance] getUser:nil withTarget:self andAction:@selector(userResponseReceived:withResponseString:)];
        }
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
	FSUser* user = [FoursquareAPI userFromResponseXML:inString];
    if (hasViewedInstructions) {
        [self setUserIconView:user];
    }
    [self setAuthenticatedUser:user];
    NSLog(@"auth'd user: %@", user);
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
    
    //NSLog(@"section: %d, row: %d", indexPath.section, indexPath.row);
    static NSString *CellIdentifier = @"MyCell";
    
//    FriendsListTableCell *cell = (FriendsListTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    if (cell == nil) {
//        // TODO: I'm not sure that this is the best way to do this with 3.x - there might be a better way to do it now
//        UIViewController *vc = [[UIViewController alloc]initWithNibName:@"FriendsListTableCellView" bundle:nil];
//        cell = (FriendsListTableCell*) vc.view;
//        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
//        cell.checkinDisplayLabel.highlightedTextColor = [UIColor whiteColor];
//        cell.addressLabel.highlightedTextColor = [UIColor whiteColor];
//        cell.timeUnits.highlightedTextColor = [UIColor whiteColor];
//        cell.numberOfTimeUnits.highlightedTextColor = [UIColor whiteColor];
//        cell.profileIcon.layer.masksToBounds = YES;
//        cell.profileIcon.layer.cornerRadius = 4.0;
//        //cell.profileIcon.layer.borderWidth = 1.0;
//        [vc release];
//    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    UIImageView *mayorView = nil; //[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 51, 320, 1)];
        line.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.13];
        [cell addSubview:line];
        [line release];
        
//        [cell addSubview:mayorView];
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

    // create icon image
//	NSString * path = checkin.user.photo;
//	if (path) {
//        cell.profileIcon.image = [userIcons objectForKey:checkin.user.userId];
//    }
    cell.imageView.image = [userIcons objectForKey:checkin.user.userId];
//    float sw=32/cell.imageView.image.size.width;
//    float sh=32/cell.imageView.image.size.height;
//    cell.imageView.transform=CGAffineTransformMakeScale(sw,sh);
//    cell.imageView.layer.masksToBounds = YES;
//    cell.imageView.layer.cornerRadius = 8.0;
    
    cell.textLabel.text = checkin.display;
    if ([checkin.display rangeOfString:@"[off the grid]"].location != NSNotFound) {
        cell.detailTextLabel.text = @"...location unknown...";
    } else if (checkin.shout != nil) {
        cell.detailTextLabel.text = checkin.shout;
    } else {
        cell.detailTextLabel.text = checkin.venue.venueAddress;
    }
    
//	cell.checkinDisplayLabel.text = checkin.display;
//    // TODO: check to see if there is a better way to check for [off the grid]
//    if ([checkin.display rangeOfString:@"[off the grid]"].location != NSNotFound) {
//        cell.addressLabel.text = @"...location unknown...";
//    } else if (checkin.shout != nil) {
//        cell.addressLabel.text = checkin.shout;
//    } else {
//        cell.addressLabel.text = checkin.venue.venueAddress;
//    }
//    
//    [cell showHideMayorImage:checkin.isMayor];
//    
//    cell.timeUnits.text = [cachedTimeUnitsLabel objectForKey:checkin.checkinId];
//    cell.numberOfTimeUnits.text = [cachedTimeLabel objectForKey:checkin.checkinId];
//    UIImageView *mayorView = nil;   
    if (checkin.isMayor) {
//        mayorView = [[UIImageView alloc] initWithImage:mayorImage];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"01.png"]];
//        [cell addSubview:mayorImageView];
        //[mayorView release];
    } else {
        cell.backgroundView = nil;
//        [mayorImageView removeFromSuperview];
        //mayorView = [[UIImageView alloc] initWithFrame:CGRectZero];
        //[cell addSubview:mayorView];
        //[mayorView release];
    }
//    mayorView.hidden = !checkin.isMayor;
//    NSLog(@"checkin user: %@", checkin.user.firstnameLastInitial);
//    NSLog(@"!isMayor: %d", !checkin.isMayor);
//    NSLog(@"mayorView.hidden: %d", mayorView.hidden);
    
    UILabel *timeUnitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(281, 35, 30, 12)];
    timeUnitsLabel.text = checkin.truncatedTimeUnits;
    timeUnitsLabel.font = [UIFont systemFontOfSize:11.0];
    timeUnitsLabel.textColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    [cell addSubview:timeUnitsLabel];
    [timeUnitsLabel release];
    
    UILabel *numberOfTimeUnits = [[UILabel alloc] initWithFrame:CGRectMake(285, 5, 30, 20)];
    numberOfTimeUnits.text = checkin.truncatedTimeNumeral;
    numberOfTimeUnits.font = [UIFont boldSystemFontOfSize:24.0];
    numberOfTimeUnits.textColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    cell.accessoryView = numberOfTimeUnits;
    [numberOfTimeUnits release];
    
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
            if ([yesterdayCheckins count] > 0 && isDisplayingMore) {
                headerLabel.text = @"Older";
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

- (void) refresh {
	[self startProgressBar:@"Retrieving friends' whereabouts..."];
	[[FoursquareAPI sharedInstance] getCheckinsWithTarget:self andAction:@selector(checkinResponseReceived:withResponseString:)];
}

- (void) flipToMap {
    FriendsMapViewController *mapViewController = [[FriendsMapViewController alloc] initWithNibName:@"FriendsMapView" bundle:nil];
    mapViewController.checkins = [[NSArray arrayWithArray:self.recentCheckins] arrayByAddingObjectsFromArray:self.todayCheckins];
    [self.navigationController pushViewController:mapViewController animated:YES];
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
    
    NSDate *threeHoursFromNow = [[NSDate alloc] initWithTimeIntervalSinceNow:-60*60*3];
    NSDate *twentyfourHoursFromNow = [[NSDate alloc] initWithTimeIntervalSinceNow:-60*60*24];
    threeHoursFromNow = [self convertToUTC:threeHoursFromNow];
    twentyfourHoursFromNow = [self convertToUTC:twentyfourHoursFromNow];
    
    NSUInteger unitFlags = NSMinuteCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit;
    
    for (FSCheckin *checkin in checkins) {
        NSDate *date = [dateFormatter dateFromString:checkin.created];
        if ([date compare:threeHoursFromNow] == NSOrderedDescending) {
            [self.recentCheckins addObject:checkin];
        } else if ([date compare:threeHoursFromNow] == NSOrderedAscending && [date compare:twentyfourHoursFromNow] == NSOrderedDescending) {
            [self.todayCheckins addObject:checkin];
        } else {
            [self.yesterdayCheckins addObject:checkin];
        }
        // create dictionary of icons to help speed up the scrolling
        if (checkin.user && checkin.user.photo && checkin.user.userId) {
            UIImage *img = [[Utilities sharedInstance] getCachedImage:checkin.user.photo];
         
            CGSize newSize = CGSizeMake(36.0, 36.0);
            UIGraphicsBeginImageContext( newSize );
            [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
            UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            [userIcons setObject:[Utilities makeRoundCornerImage:newImage cornerwidth:4 cornerheight:4] forKey:checkin.user.userId];
        }
        
        NSDateComponents *components = [gregorian components:unitFlags fromDate:[self convertToUTC:[NSDate date]] toDate:date options:0];
        NSInteger minutes = [components minute] * -1;
        NSInteger hours = [components hour] * -1;
        NSInteger days = [components day] * -1;
        
        if (days == 0 && hours == 0) {
            checkin.truncatedTimeUnits = @"min.";
            checkin.truncatedTimeNumeral = [NSString stringWithFormat:@"%02d", minutes];
        } else if (days == 0) {
            checkin.truncatedTimeUnits = @"hours";
            checkin.truncatedTimeNumeral = [NSString stringWithFormat:@"%02d", hours];
        } else {
            checkin.truncatedTimeUnits = @"days";
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
}

- (void) addFriend {
    FriendRequestsViewController *friendsController = [[FriendRequestsViewController alloc] initWithNibName:@"FriendRequestsViewController" bundle:nil];
    [self.navigationController pushViewController:friendsController animated:YES];
    [friendsController release];
}

- (void) viewNextWelcomeImage {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:YES forKey:@"viewedInstructions"];
    hasViewedInstructions = YES;
//    if (welcomePageNum == 1) {
//        NSString *imageName = [NSString stringWithFormat:@"welcome0%d.png", welcomePageNum + 1];
//        NSLog(@"image name: %@", imageName);
//        welcomeImage.image = [UIImage imageNamed:imageName];
//        [self.view bringSubviewToFront:nextWelcomeImage];
//        [self.view bringSubviewToFront:previousWelcomeImage];
//        welcomePageNum++;
//    } else {
        [instructionView removeFromSuperview];
        [self stopProgressBar];
        [self setUserIconView:[self getAuthenticatedUser]];
        [iconImageView setHidden:NO];
        [self doInitialDisplay];
//    }
}

- (void) viewPreviousWelcomeImage {
    if (welcomePageNum > 1) {
        welcomeImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"welcome0%d.png", welcomePageNum - 1]];
        welcomePageNum--;
    }
}

- (void) displayOlderCheckins {
    isDisplayingMore = YES;
    NSLog(@"displayolder checkins: %d", isDisplayingMore);
    [theTableView reloadData];
}

- (void) setupSplashAnimation {
    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:1];
    for (int i = 1; i < 61; i++) {
        [images addObject:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"kickballLoading%02d", i] ofType:@"png"]]];
    }
    
//    splashView.animationImages = [NSArray arrayWithObjects:
//                                    [UIImage imageNamed:@"kickballLoading01.png"],
//                                    [UIImage imageNamed:@"kickballLoading02.png"],
//                                    [UIImage imageNamed:@"kickballLoading03.png"],
//                                    [UIImage imageNamed:@"kickballLoading04.png"],
//                                    [UIImage imageNamed:@"kickballLoading05.png"],
//                                    [UIImage imageNamed:@"kickballLoading06.png"],
//                                    [UIImage imageNamed:@"kickballLoading07.png"],
//                                  [UIImage imageNamed:@"kickballLoading08.png"],
//                                  [UIImage imageNamed:@"kickballLoading09.png"],
//                                  [UIImage imageNamed:@"kickballLoading10.png"],
//                                  [UIImage imageNamed:@"kickballLoading11.png"],
//                                  [UIImage imageNamed:@"kickballLoading12.png"],
//                                  [UIImage imageNamed:@"kickballLoading13.png"],
//                                  [UIImage imageNamed:@"kickballLoading14.png"],
//                                  [UIImage imageNamed:@"kickballLoading15.png"],
//                                  [UIImage imageNamed:@"kickballLoading16.png"],
//                                  [UIImage imageNamed:@"kickballLoading17.png"],
//                                  [UIImage imageNamed:@"kickballLoading18.png"],
//                                  [UIImage imageNamed:@"kickballLoading19.png"],
//                                  [UIImage imageNamed:@"kickballLoading20.png"],
//                                  [UIImage imageNamed:@"kickballLoading21.png"],
//                                  [UIImage imageNamed:@"kickballLoading22.png"],
//                                  [UIImage imageNamed:@"kickballLoading23.png"],
//                                  [UIImage imageNamed:@"kickballLoading24.png"],
//                                  [UIImage imageNamed:@"kickballLoading25.png"],
//                                  [UIImage imageNamed:@"kickballLoading26.png"],
//                                  [UIImage imageNamed:@"kickballLoading27.png"],
//                                  [UIImage imageNamed:@"kickballLoading28.png"],
//                                  [UIImage imageNamed:@"kickballLoading29.png"],
//                                  [UIImage imageNamed:@"kickballLoading30.png"],
//                                  [UIImage imageNamed:@"kickballLoading31.png"],
//                                  [UIImage imageNamed:@"kickballLoading32.png"],
//                                  [UIImage imageNamed:@"kickballLoading33.png"],
//                                  [UIImage imageNamed:@"kickballLoading34.png"],
//                                  [UIImage imageNamed:@"kickballLoading35.png"],
//                                  [UIImage imageNamed:@"kickballLoading36.png"],
//                                  [UIImage imageNamed:@"kickballLoading37.png"],
//                                  [UIImage imageNamed:@"kickballLoading38.png"],
//                                  [UIImage imageNamed:@"kickballLoading39.png"],
//                                  [UIImage imageNamed:@"kickballLoading40.png"],
//                                  [UIImage imageNamed:@"kickballLoading41.png"],
//                                  [UIImage imageNamed:@"kickballLoading42.png"],
//                                  [UIImage imageNamed:@"kickballLoading43.png"],
//                                  [UIImage imageNamed:@"kickballLoading44.png"],
//                                  [UIImage imageNamed:@"kickballLoading45.png"],
//                                  [UIImage imageNamed:@"kickballLoading46.png"],
//                                  [UIImage imageNamed:@"kickballLoading47.png"],
//                                  [UIImage imageNamed:@"kickballLoading48.png"],
//                                  [UIImage imageNamed:@"kickballLoading49.png"],
//                                  [UIImage imageNamed:@"kickballLoading50.png"],
//                                  [UIImage imageNamed:@"kickballLoading51.png"],
//                                  [UIImage imageNamed:@"kickballLoading52.png"],
//                                  [UIImage imageNamed:@"kickballLoading53.png"],
//                                  [UIImage imageNamed:@"kickballLoading54.png"],
//                                  [UIImage imageNamed:@"kickballLoading55.png"],
//                                  [UIImage imageNamed:@"kickballLoading56.png"],
//                                  [UIImage imageNamed:@"kickballLoading57.png"],
//                                  [UIImage imageNamed:@"kickballLoading58.png"],
//                                  [UIImage imageNamed:@"kickballLoading59.png"],
//                                  [UIImage imageNamed:@"kickballLoading60.png"],
//                                  [UIImage imageNamed:@"kickballLoading61.png"],
//                                  [UIImage imageNamed:@"kickballLoading62.png"],
//                                  [UIImage imageNamed:@"kickballLoading63.png"],
//                                  [UIImage imageNamed:@"kickballLoading64.png"],
//                                  [UIImage imageNamed:@"kickballLoading65.png"],
//                                  [UIImage imageNamed:@"kickballLoading66.png"],
//                                  [UIImage imageNamed:@"kickballLoading67.png"],
//                                  [UIImage imageNamed:@"kickballLoading68.png"],
//                                  [UIImage imageNamed:@"kickballLoading69.png"],
//                                  [UIImage imageNamed:@"kickballLoading70.png"],
//                                  [UIImage imageNamed:@"kickballLoading71.png"],
//                                  [UIImage imageNamed:@"kickballLoading72.png"],
//                                  [UIImage imageNamed:@"kickballLoading73.png"],
//                                  [UIImage imageNamed:@"kickballLoading74.png"],
//                                  [UIImage imageNamed:@"kickballLoading75.png"],
//                                  [UIImage imageNamed:@"kickballLoading76.png"],
//                                  [UIImage imageNamed:@"kickballLoading77.png"],
//                                  [UIImage imageNamed:@"kickballLoading78.png"],
//                                  [UIImage imageNamed:@"kickballLoading79.png"],
//                                  [UIImage imageNamed:@"kickballLoading80.png"],
//                                  [UIImage imageNamed:@"kickballLoading81.png"],
//                                  [UIImage imageNamed:@"kickballLoading82.png"],
//                                  [UIImage imageNamed:@"kickballLoading83.png"],
//                                  [UIImage imageNamed:@"kickballLoading84.png"],
//                                  [UIImage imageNamed:@"kickballLoading85.png"],
//                                  [UIImage imageNamed:@"kickballLoading86.png"],
//                                  [UIImage imageNamed:@"kickballLoading87.png"],
//                                  [UIImage imageNamed:@"kickballLoading88.png"],
//                                  [UIImage imageNamed:@"kickballLoading89.png"],
//                                  [UIImage imageNamed:@"kickballLoading90.png"],
//                                  [UIImage imageNamed:@"kickballLoading91.png"],
//                                  [UIImage imageNamed:@"kickballLoading92.png"],
//                                  [UIImage imageNamed:@"kickballLoading93.png"],
//                                  [UIImage imageNamed:@"kickballLoading94.png"],
//                                  [UIImage imageNamed:@"kickballLoading95.png"],
//                                  [UIImage imageNamed:@"kickballLoading96.png"],
//                                  [UIImage imageNamed:@"kickballLoading97.png"],
//                                  [UIImage imageNamed:@"kickballLoading98.png"],
//                                  [UIImage imageNamed:@"kickballLoading99.png"],
//                                  [UIImage imageNamed:@"kbLOADER100.png"],
//                                  [UIImage imageNamed:@"kbLOADER101.png"],
//                                  [UIImage imageNamed:@"kbLOADER102.png"],
//                                  [UIImage imageNamed:@"kbLOADER103.png"],
//                                  [UIImage imageNamed:@"kbLOADER104.png"],
//                                  [UIImage imageNamed:@"kbLOADER105.png"],
//                                  [UIImage imageNamed:@"kbLOADER106.png"],
//                                  [UIImage imageNamed:@"kbLOADER107.png"],
//                                  [UIImage imageNamed:@"kbLOADER108.png"],
//                                  [UIImage imageNamed:@"kbLOADER109.png"],
//                                  [UIImage imageNamed:@"kbLOADER110.png"],
//                                  [UIImage imageNamed:@"kbLOADER111.png"],
//                                                nil];
    
    splashView.animationImages = [[NSArray alloc] initWithArray:images];
    [images release];
    splashView.animationDuration = 2.0;
    splashView.animationRepeatCount = 0;
}

@end

