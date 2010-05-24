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
#import "FriendRequestsViewController.h"
#import "KBTwitterXAuthLoginController.h"
#import "TableSectionHeaderView.h"
#import "KickballAPI.h"
#import "KBLocationManager.h"


#define SECTION_RECENT_CHECKINS 1
#define SECTION_TODAY_CHECKINS 2
#define SECTION_YESTERDAY_CHECKINS 3
#define SECTION_NONCITY_RECENT_CHECKINS 4
#define SECTION_NONCITY_TODAY_CHECKINS 5
#define SECTION_NONCITY_YESTERDAY_CHECKINS 6
#define SECTION_MORE_BUTTON 7
#define SECTION_FOOTER 8
#define SECTION_SHOUT 0

@interface FriendsListViewController (Private)

- (void) addAuthToWebRequest:(NSMutableURLRequest*)requestObj email:(NSString*)email password:(NSString*)password;
- (void) decrementActionCount;
- (void) closeUpShop;

@end


@implementation FriendsListViewController

@synthesize checkins, recentCheckins, todayCheckins, yesterdayCheckins, nonCityRecentCheckins, nonCityTodayCheckins, nonCityYesterdayCheckins;

- (void) viewDidLoad {
    
    pageType = KBPageTypeFriends;
    pageViewType = KBPageViewTypeList;
    
    [super viewDidLoad];
    
    //welcomePageNum = 1;
    isDisplayingMore = NO;
    
    gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setLocale:[NSLocale currentLocale]];
    
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
        
//		[self.loginViewModal setRootController:self];
//		[self.navigationController presentModalViewController:self.loginViewModal animated:YES];
        
	} else {
		[self doInitialDisplay];
	}
}

- (void) doInitialDisplay {
    [[Beacon shared] startSubBeaconWithName:@"Initial Friends List Display"];
    [self startProgressBar:@"Retrieving friends' whereabouts..." withTimer:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(instaCheckin:) name:@"touchAndHoldCheckin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideAppropriateTabs) name:@"hideAppropriateTabs" object:nil];
    
//    if (!hasViewedInstructions) {
//        [iconImageView setHidden:YES];
//        [self.view addSubview:instructionView];
//        [self.view bringSubviewToFront:instructionView];
//    }
    
    [[FoursquareAPI sharedInstance] getCheckinsWithTarget:self andAction:@selector(checkinResponseReceived:withResponseString:)];
    
    if (![self getAuthenticatedUser]) {
        [[FoursquareAPI sharedInstance] getUser:nil withTarget:self andAction:@selector(userResponseReceived:withResponseString:)];
    }
}

// FIXME: this needs to be pulled up
- (void) instaCheckin:(NSNotification *)inNotification {
    NSString *venueId = [[inNotification userInfo] objectForKey:@"venueIdOfCell"];
    PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView_v2" bundle:nil];    
    placeDetailController.venueId = venueId;
    placeDetailController.doCheckin = YES;
    [self.navigationController pushViewController:placeDetailController animated:YES];
    [placeDetailController release]; 
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
    //NSLog(@"authenticated user: %@", inString);
	FSUser* user = [[FoursquareAPI userFromResponseXML:inString] retain];
    if (hasViewedInstructions) {
        [self setUserIconViewCustom:user];
    }
    [self setAuthenticatedUser:user];
    [signedInUserIcon setImage:[[Utilities sharedInstance] getCachedImage:user.photo] forState:UIControlStateNormal];
    
    // shout view stuff
    facebookButton.enabled = user.facebook != nil;
    twitterButton.enabled = user.twitter != nil;
    isFacebookOn = YES;
    isTwitterOn = YES;
    isFoursquareOn = YES;
    // hack
    if (!user.sendToFacebook) {
        [self toggleFacebook];
    }
    if (!user.sendToTwitter) {
        [self toggleTwitter];
    }
    
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
    [nonCityRecentCheckins release];
    [nonCityTodayCheckins release];
    [nonCityYesterdayCheckins release];
    [theTableView release];
    [checkins release];
    [mapButton release];
    [instructionView release];
    [noNetworkView release];
    [footerViewCell release];
    [moreCell release];
    [nextWelcomeImage release];
    [previousWelcomeImage release];
    [welcomeImage release];
    [splashView release];
    [gregorian release];
    [super dealloc];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 9;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == SECTION_RECENT_CHECKINS) {
		return [self.recentCheckins count];
	} else if (section == SECTION_TODAY_CHECKINS) {
        return [self.todayCheckins count];
    } else if (section == SECTION_YESTERDAY_CHECKINS) {
        if (isDisplayingMore) {
            return [self.yesterdayCheckins count];
        } else {
            return 0;
        }
    } else if (section == SECTION_NONCITY_RECENT_CHECKINS) {
        return [self.nonCityRecentCheckins count];
    } else if (section == SECTION_NONCITY_TODAY_CHECKINS) {
        return [self.nonCityTodayCheckins count];
    } else if (section == SECTION_NONCITY_YESTERDAY_CHECKINS) {
        if (isDisplayingMore) {
            return [self.nonCityYesterdayCheckins count];
        } else {
            return 0;
        }
        //return [self.nonCityYesterdayCheckins count];
    } else if (section == SECTION_MORE_BUTTON) {
        return !isDisplayingMore;
    } else if (section == SECTION_FOOTER) {
        return 1;
    } else if (section == SECTION_SHOUT) {
        return 1;
    }
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MyCell";
    
    FriendsListTableCellv2 *cell = (FriendsListTableCellv2*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[FriendsListTableCellv2 alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.imageView.image = [UIImage imageNamed:@"blank_boy.png"];
    }
    
    FSCheckin *checkin = nil;
    if (indexPath.section == SECTION_RECENT_CHECKINS) {
        checkin = [self.recentCheckins objectAtIndex:indexPath.row];
    } else if (indexPath.section == SECTION_TODAY_CHECKINS) {
        checkin = [self.todayCheckins objectAtIndex:indexPath.row];
    } else if (indexPath.section == SECTION_YESTERDAY_CHECKINS) {
        if (isDisplayingMore) {
            checkin = [self.yesterdayCheckins objectAtIndex:indexPath.row];
        } else {
            return nil;
        }
    } else if (indexPath.section == SECTION_NONCITY_RECENT_CHECKINS) {
        checkin = [self.nonCityRecentCheckins objectAtIndex:indexPath.row];
    } else if (indexPath.section == SECTION_NONCITY_TODAY_CHECKINS) {
        checkin = [self.nonCityTodayCheckins objectAtIndex:indexPath.row];
    } else if (indexPath.section == SECTION_NONCITY_YESTERDAY_CHECKINS) {
        if (isDisplayingMore) {
            checkin = [self.nonCityYesterdayCheckins objectAtIndex:indexPath.row];
        } else {
            return nil;
        }
    } else if (indexPath.section == SECTION_MORE_BUTTON) {
        return moreCell;
    } else if (indexPath.section == SECTION_FOOTER) {
        return footerViewCell;
    } else if (indexPath.section == SECTION_SHOUT) {
        return shoutCell;
    }
    
    if (checkin.venue) {
        cell.venueId = checkin.venue.venueid;
    }
    
    cell.userIcon.urlPath = checkin.user.photo;
    cell.userName.text = checkin.user.firstnameLastInitial;
    cell.venueName.text = checkin.venue.name;
    
    if ([checkin.display rangeOfString:@"[off the grid]"].location != NSNotFound) {
        cell.venueName.text = @"[off the grid]";
        cell.venueAddress.text = @"...location unknown...";
    } else if (checkin.shout != nil && checkin.venue) {
        cell.venueAddress.text = checkin.shout;
    } else if (checkin.shout != nil && !checkin.venue) {
        cell.venueName.text = checkin.shout;
        cell.venueAddress.text = @"";
    } else {
        cell.venueAddress.text = checkin.venue.addressWithCrossstreet;
    }
    
    UILabel *numberOfTimeUnits = [[UILabel alloc] initWithFrame:CGRectMake(290, 5, 37, 20)];
    numberOfTimeUnits.text = checkin.truncatedTimeNumeral;
    numberOfTimeUnits.font = [UIFont systemFontOfSize:26.0];
    numberOfTimeUnits.shadowColor = [UIColor whiteColor];
    numberOfTimeUnits.shadowOffset = CGSizeMake(1.0, 1.0);
    numberOfTimeUnits.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    numberOfTimeUnits.backgroundColor = [UIColor clearColor];
    cell.accessoryView = numberOfTimeUnits;
    [numberOfTimeUnits release];

    // v1.1 - TODO: need transparent png for the crown image
//    if (checkin.isMayor) {
//        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"crown_bg.png"]];
//    } else {
//        cell.backgroundView = nil;
//    }
    
    //NSLog(@"returning cell for row: %d", indexPath.row);
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"row selected");
    FSUser *user = nil;
    switch (indexPath.section) {
        case SECTION_RECENT_CHECKINS: // last 3 hours
            user = ((FSCheckin*)[self.recentCheckins objectAtIndex:indexPath.row]).user;
            break;
        case SECTION_TODAY_CHECKINS: //today
            user = ((FSCheckin*)[self.todayCheckins objectAtIndex:indexPath.row]).user;
            break;
        case SECTION_YESTERDAY_CHECKINS: //yesterday
            user = ((FSCheckin*)[self.yesterdayCheckins objectAtIndex:indexPath.row]).user;
            break;
        case SECTION_NONCITY_RECENT_CHECKINS: //non-city
            user = ((FSCheckin*)[self.nonCityRecentCheckins objectAtIndex:indexPath.row]).user;
            break;
        case SECTION_NONCITY_TODAY_CHECKINS: //non-city
            user = ((FSCheckin*)[self.nonCityTodayCheckins objectAtIndex:indexPath.row]).user;
            break;
        case SECTION_NONCITY_YESTERDAY_CHECKINS: //non-city
            user = ((FSCheckin*)[self.nonCityYesterdayCheckins objectAtIndex:indexPath.row]).user;
            break;
        default:
            break;
    }
    
	//handle off the grid checkins.
	if (user.userId != nil) {
        [theTableView deselectRowAtIndexPath:indexPath animated:YES];
        [self displayProperProfileView:user.userId];
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != SECTION_FOOTER) {
        [cell setBackgroundColor:[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0]];  
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_FOOTER) {
        return 50;
    } else if (indexPath.section == SECTION_MORE_BUTTON || indexPath.section == SECTION_SHOUT) {
        return 44;
    }
    return 72;
}

// TODO: most of the below header label stuff should be pulled up into a method in KBBBaseViewController
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    TableSectionHeaderView *headerView = [[[TableSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)] autorelease];
    
    // damn, this is ugly.  nil should be returned before all the above code is executed.  
    // probably should extract the headerLabel construction and just have a single switch in here
    // and pass the text into the method
    // TODO: clean this crap up
    switch (section) {
        case SECTION_SHOUT:
            return nil;
            break;
        case SECTION_RECENT_CHECKINS:
            if ([recentCheckins count] > 0) {
                headerView.leftHeaderLabel.text = @"Recent Check-ins";
                headerView.rightHeaderLabel.text = @"Mins Ago";
            } else {
                return nil;
            }
            break;
        case SECTION_TODAY_CHECKINS:
            if ([todayCheckins count] > 0) {
                headerView.leftHeaderLabel.text = @"Today";
                headerView.rightHeaderLabel.text = @"Hours Ago";
            } else {
                return nil;
            }
            break;
        case SECTION_YESTERDAY_CHECKINS:
            if ([yesterdayCheckins count] > 0 && isDisplayingMore) {
                headerView.leftHeaderLabel.text = @"Older";
                headerView.rightHeaderLabel.text = @"Days Ago";
            } else {
                return nil;
            }
            break;
        case SECTION_NONCITY_RECENT_CHECKINS:
            if ([nonCityRecentCheckins count] > 0) {
                headerView.leftHeaderLabel.text = @"Recent Check-ins in Other Cities";
                headerView.rightHeaderLabel.text = @"Mins Ago";
            } else {
                return nil;
            }
            break;
        case SECTION_NONCITY_TODAY_CHECKINS:
            if ([nonCityTodayCheckins count] > 0) {
                headerView.leftHeaderLabel.text = @"Today's Check-ins in Other Cities";
                headerView.rightHeaderLabel.text = @"Hours Ago";
            } else {
                return nil;
            }
            break;
        case SECTION_NONCITY_YESTERDAY_CHECKINS:
            if ([nonCityYesterdayCheckins count] > 0 && isDisplayingMore) {
                headerView.leftHeaderLabel.text = @"Older Check-ins in Other Cities";
                headerView.rightHeaderLabel.text = @"Days Ago";
            } else {
                return nil;
            }
            break;
        case SECTION_MORE_BUTTON:  // more cell
        case SECTION_FOOTER:  // footer cell
            return nil;
        default:
            headerView.leftHeaderLabel.text = @"You shouldn't see this";
            break;
    }
	return headerView;
}

#pragma mark -
#pragma mark shout related methods

- (void) shout {
    [shoutText resignFirstResponder];
    [self startProgressBar:@"Shouting..."];
    actionCount = 1 + isTwitterOn + isFacebookOn;
    
    [[FoursquareAPI sharedInstance] doCheckinAtVenueWithId:nil
                                                  andShout:shoutText.text 
                                                   offGrid:!isFoursquareOn
                                                 toTwitter:NO
                                                toFacebook:NO 
                                                withTarget:self 
                                                 andAction:@selector(shoutResponseReceived:withResponseString:)];
    
    // we send twitter/facebook api calls ourself so that the tweets and posts are stamped with the Kickball brand
    if (isTwitterOn) {
        // TODO: check for twitter login
        [self.twitterEngine sendUpdate:shoutText.text
                          withLatitude:[[KBLocationManager locationManager] latitude] 
                         withLongitude:[[KBLocationManager locationManager] longitude]];
    }
    
    if (isFacebookOn) {
        // TODO: check for facebook login
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:shoutText.text, @"status", nil];
        [[FBRequest requestWithDelegate:self] call:@"facebook.status.set" params:params dataParam:nil];
    }
    
    [[Beacon shared] startSubBeaconWithName:@"checked in"];
}

// Twitter response
- (void) statusRetrieved:(NSNotification *)inNotification {
    [self decrementActionCount];
}

// Facebook response
- (void)request:(FBRequest*)request didLoad:(id)result {
    if ([request.method isEqualToString:@"facebook.status.set"]) {
        NSDictionary* info = result;
        NSLog(@"facebook status updated: %@", info);
    }
    [self decrementActionCount];
}

// 4sq response
- (void)shoutResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    //NSLog(@"instring: %@", inString);
	NSArray *checkins = [FoursquareAPI checkinsFromResponseXML:inString];
//    if ([checkins count] > 0) {
//        checkin = [checkins objectAtIndex:0];
//    }
    
    self.shoutToPush = [NSString stringWithString:shoutText.text];
    [self sendPushNotification];
    [self decrementActionCount];
}

- (void) decrementActionCount {
    actionCount--;
    if (actionCount == 0) {
        [self stopProgressBar];
        [self closeUpShop];
    }
}

- (void) closeUpShop {
    [self stopProgressBar];
    [self removeShoutView];
    
    KBMessage *msg = [[KBMessage alloc] initWithMember:@"Kickball Notification" andMessage:@"Your shout has been sent."];
    [self displayPopupMessage:msg];
    [msg release];
}

#pragma mark -
#pragma mark textfield delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [self shout];
    return YES;
}

#pragma mark IBAction methods

//- (void) refresh {
//	[self startProgressBar:@"Retrieving friends' whereabouts..."];
//	[[FoursquareAPI sharedInstance] getCheckinsWithTarget:self andAction:@selector(checkinResponseReceived:withResponseString:)];
//}

- (void) displayShoutView {
    CGRect frame = shoutView.frame;
    frame.origin = CGPointMake(0, 47);
    shoutView.frame = frame;
    [self.view addSubview:shoutView];
    [shoutText becomeFirstResponder];
}

- (void) removeShoutView {
    [shoutText resignFirstResponder];
    [shoutView removeFromSuperview];
}

- (void) flipBetweenMapAndList {
    FriendsMapViewController *mapViewController = [[FriendsMapViewController alloc] initWithNibName:@"FriendsMapView_v2" bundle:nil];
    if ([self.recentCheckins count] > 0 && [self.todayCheckins count] > 0) {
        mapViewController.checkins = [[NSArray arrayWithArray:self.recentCheckins] arrayByAddingObjectsFromArray:self.todayCheckins];
    } else if ([self.nonCityRecentCheckins count] > 0 || [self.nonCityTodayCheckins count] > 0 || [self.nonCityYesterdayCheckins count] > 0) {
        mapViewController.checkins = [[[NSArray arrayWithArray:self.nonCityRecentCheckins] arrayByAddingObjectsFromArray:self.nonCityTodayCheckins] arrayByAddingObjectsFromArray:self.nonCityYesterdayCheckins];
    }
    [self.navigationController pushViewController:mapViewController animated:NO];
    [mapViewController release];
}

- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"checkins: %@", inString);
    NSString *errorMessage = [FoursquareAPI errorFromResponseXML:inString];
    if (errorMessage) {
        [self displayFoursquareErrorMessage:errorMessage];
    } else {
        NSArray * allCheckins = [FoursquareAPI checkinsFromResponseXML:inString];
        self.checkins = [allCheckins copy];
        allCheckins = nil;
        
        recentCheckins = [[NSMutableArray alloc] init];
        todayCheckins = [[NSMutableArray alloc] init];
        yesterdayCheckins = [[NSMutableArray alloc] init];
        nonCityRecentCheckins = [[NSMutableArray alloc] init];
        nonCityTodayCheckins = [[NSMutableArray alloc] init];
        nonCityYesterdayCheckins = [[NSMutableArray alloc] init];
        
        NSDate *oneHourFromNow = [[[NSDate alloc] initWithTimeIntervalSinceNow:-60*60*1] autorelease];
        NSDate *twentyfourHoursFromNow = [[[NSDate alloc] initWithTimeIntervalSinceNow:-60*60*24] autorelease];
        oneHourFromNow = [[KickballAPI kickballApi] convertToUTC:oneHourFromNow];
        twentyfourHoursFromNow = [[KickballAPI kickballApi] convertToUTC:twentyfourHoursFromNow];
        
        NSUInteger unitFlags = NSMinuteCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit;
        
        // FIXME: this is nasty ugly. It should be done the same way that Places List is done. This is crap. -shawn-
        for (FSCheckin *checkin in checkins) {
            NSDate *date = [[[Utilities sharedInstance] foursquareCheckinDateFormatter] dateFromString:checkin.created];
            if (checkin.distanceFromLoggedInUser < [[[Utilities sharedInstance] getCityRadius] integerValue]) {
                if ([date compare:oneHourFromNow] == NSOrderedDescending) {
                    [self.recentCheckins addObject:checkin];
                } else if ([date compare:oneHourFromNow] == NSOrderedAscending && [date compare:twentyfourHoursFromNow] == NSOrderedDescending) {
                    [self.todayCheckins addObject:checkin];
                } else {
                    [self.yesterdayCheckins addObject:checkin];
                }
            } else {                
                if ([date compare:oneHourFromNow] == NSOrderedDescending) {
                    [self.nonCityRecentCheckins addObject:checkin];
                } else if ([date compare:oneHourFromNow] == NSOrderedAscending && [date compare:twentyfourHoursFromNow] == NSOrderedDescending) {
                    [self.nonCityTodayCheckins addObject:checkin];
                } else {
                    [self.nonCityYesterdayCheckins addObject:checkin];
                }
            }
            
            NSDateComponents *components = [gregorian components:unitFlags fromDate:[[KickballAPI kickballApi] convertToUTC:[NSDate date]] toDate:date options:0];
            NSInteger minutes = [components minute] * -1;
            NSInteger hours = [components hour] * -1;
            NSInteger days = [components day] * -1;
            
            if (days == 0 && hours == 0) {
                checkin.truncatedTimeNumeral = [NSString stringWithFormat:@"%02d", minutes];
            } else if (days == 0) {
                checkin.truncatedTimeNumeral = [NSString stringWithFormat:@"%02d", hours];
            } else {
                checkin.truncatedTimeNumeral = [NSString stringWithFormat:@"%02d", days];
            }
        }
        
        NSLog(@"all checkins: %d", [self.checkins count]);
        NSLog(@"recent checkins: %d", [self.recentCheckins count]);
        NSLog(@"today checkins: %d", [self.todayCheckins count]);
        NSLog(@"yesterday checkins: %d", [self.yesterdayCheckins count]);
        NSLog(@"non city recent checkins: %d", [self.nonCityRecentCheckins count]);
        NSLog(@"non city today checkins: %d", [self.nonCityTodayCheckins count]);
        NSLog(@"non city yesterday checkins: %d", [self.nonCityYesterdayCheckins count]);
        
        [theTableView reloadData];
        int sectionToScrollTo = [self.recentCheckins count] > 0 ? SECTION_RECENT_CHECKINS : ([self.todayCheckins count] > 0 ? SECTION_TODAY_CHECKINS: ([self.nonCityRecentCheckins count] > 0 ? SECTION_NONCITY_RECENT_CHECKINS : 0));
        [theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionToScrollTo] atScrollPosition:UITableViewScrollPositionTop animated:NO];

        footerViewCell.hidden = NO;
        mapButton.hidden = NO;
        //if (hasViewedInstructions) {
            [self stopProgressBar];
        //}
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
            [standardUserDefaults setBool:YES forKey:@"viewedInstructions"];
            hasViewedInstructions = YES;
        }
    }
}

- (void) addFriend {
    FriendRequestsViewController *friendsController = [[FriendRequestsViewController alloc] initWithNibName:@"FriendRequestsViewController" bundle:nil];
    [self.navigationController pushViewController:friendsController animated:YES];
    [friendsController release];
}

//- (void) displayTwitterXAuthLogin {
//    XAuthTwitterEngineViewController *twitterController = [[XAuthTwitterEngineViewController alloc] initWithNibName:@"XAuthTwitterEngineDemoViewController" bundle:nil];
//    [self presentModalViewController:twitterController animated:YES];
//    [twitterController release];
//}

- (void) setUserIconViewCustom:(FSUser*)user {
//    TTButton *imageButton = [TTButton buttonWithStyle:@"blockPhoto:"]; 
//    [imageButton setImage:user.photo forState:UIControlStateNormal]; 

//    if (user) {
//        NSLog(@"user is not null");
//        UIImage *image = [[Utilities sharedInstance] getCachedImage:user.photo];
//        iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(278, 2, 42, 42)];
//        iconImageView.image = image;
//        [image release];
//        [self.view insertSubview:iconImageView belowSubview:instructionView];
//        iconImageView.layer.masksToBounds = YES;
//        iconImageView.layer.cornerRadius = 4.0;
//        [self.view bringSubviewToFront:signedInUserIcon];
//    }
}

- (void) viewNextWelcomeImage {
//    [self stopProgressBar];
//    [instructionView removeFromSuperview];
//    [self setUserIconViewCustom:[self getAuthenticatedUser]];
//    [iconImageView setHidden:NO];
    
    
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


- (void) toggleTwitter {
    if (isTwitterOn) {
        [twitterButton setImage:[UIImage imageNamed:@"checkinTWT02.png"] forState:UIControlStateNormal];
        [twitterButton setImage:[UIImage imageNamed:@"checkinTWT01.png"] forState:UIControlStateHighlighted];
    } else {
        [twitterButton setImage:[UIImage imageNamed:@"checkinTWT01.png"] forState:UIControlStateNormal];
        [twitterButton setImage:[UIImage imageNamed:@"checkinTWT02.png"] forState:UIControlStateHighlighted];
    }
    isTwitterOn = !isTwitterOn;
}

- (void) toggleFacebook {
    if (isFacebookOn) {
        [facebookButton setImage:[UIImage imageNamed:@"checkinFB02.png"] forState:UIControlStateNormal];
        [facebookButton setImage:[UIImage imageNamed:@"checkinFB01.png"] forState:UIControlStateHighlighted];
    } else {
        [facebookButton setImage:[UIImage imageNamed:@"checkinFB01.png"] forState:UIControlStateNormal];
        [facebookButton setImage:[UIImage imageNamed:@"checkinFB02.png"] forState:UIControlStateHighlighted];
    }
    isFacebookOn = !isFacebookOn;
}

- (void) toggleFoursquare {
    if (isFoursquareOn) {
        // turn 4sq off
        [foursquareButton setImage:[UIImage imageNamed:@"checkin4SQ02.png"] forState:UIControlStateNormal];
        [foursquareButton setImage:[UIImage imageNamed:@"checkin4SQ01.png"] forState:UIControlStateHighlighted];
    } else {
        // turn 4sq on
        [foursquareButton setImage:[UIImage imageNamed:@"checkin4SQ01.png"] forState:UIControlStateNormal];
        [foursquareButton setImage:[UIImage imageNamed:@"checkin4SQ02.png"] forState:UIControlStateHighlighted];
    }
    isFoursquareOn = !isFoursquareOn;
}

#pragma mark 
#pragma mark table refresh methods

- (void) refreshTable {
	[[FoursquareAPI sharedInstance] getCheckinsWithTarget:self andAction:@selector(checkinResponseReceivedWithRefresh:withResponseString:)];
}

- (void)checkinResponseReceivedWithRefresh:(NSURL *)inURL withResponseString:(NSString *)inString {
    [self checkinResponseReceived:inURL withResponseString:inString];
	[self dataSourceDidFinishLoadingNewData];
}

@end

