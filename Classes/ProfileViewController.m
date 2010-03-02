//
//  ProfileViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 10/29/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ProfileViewController.h"
#import "FoursquareAPI.h"
#import "FSVenue.h"
#import "PlaceDetailViewController.h"
#import "MGTwitterEngine.h"
#import "Utilities.h"
#import "ProfileTwitterViewController.h"
#import "ProfileFriendsViewController.h"
#import "HistoryViewController.h"


#define BADGES_PER_ROW 5

@interface ProfileViewController (Private)

- (void)userResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;
- (void) displayActionSheet:(NSString*)title;
- (UITableViewCell*) determineWhichFriendCellToDisplay:(FSFriendStatus)status;
- (void) disableUnavailableSegments;

@end

@implementation ProfileViewController

@synthesize userId, badgeCell;


 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    name.text = @"";
    location.text = @"";
    lastCheckinAddress.text = @"";
    
    [self addHeaderAndFooter:theTableView];
    
    [self startProgressBar:@"Retrieving profile..."];
    [[FoursquareAPI sharedInstance] getUser:self.userId withTarget:self andAction:@selector(userResponseReceived:withResponseString:)];
    [[Beacon shared] startSubBeaconWithName:@"Profile"];
}

- (void)userResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
	user = [[FoursquareAPI userFromResponseXML:inString] retain];
    name.text = user.firstnameLastInitial;
    
    if ([user.checkin.display rangeOfString:@"[off the grid]"].location != NSNotFound) {
        location.text = @"[off the grid]";
        lastCheckinAddress.text = @"...location unknown...";
        hereIAmButton.enabled = NO;
        locationOverlayButton.enabled = NO;
    } else {
        if (user.checkin.shout != nil) {
            lastCheckinAddress.text = user.checkin.shout;
            hereIAmButton.enabled = NO;
        } else {
            lastCheckinAddress.text = user.checkin.venue.venueAddress;
            hereIAmButton.enabled = YES;
        }
        if (user.checkin.venue) {
            location.text = user.checkin.venue.name;
        }
    }
    
    isPingAndUpdatesOn = user.sendsPingsToSignedInUser;
    if (isPingAndUpdatesOn) {
        [pingsAndUpdates setImage:[UIImage imageNamed:@"profilePings01x.png"] forState:UIControlStateNormal];
    } else {
        [pingsAndUpdates setImage:[UIImage imageNamed:@"profilePings03x.png"] forState:UIControlStateNormal];
    }
    //pingsAndUpdates.selected = user.sendsPingsToSignedInUser;
    
    // user icon
    userIcon.image = [[Utilities sharedInstance] getCachedImage:user.photo];
    userIcon.layer.masksToBounds = YES;
    userIcon.layer.cornerRadius = 5.0;
    
    // badges
    // I was hoping for something elegant, and it seemed like I was going to get there, but, as you can see, I didn't quite make it
    // I'm sure there's a better way to do this, but this works.
    int x = 0;
    int y = 0;
    int i = 0;
    for (FSBadge *badge in user.badges) {
        CGRect frame= CGRectMake(x*60 + 15, y*60 + 10, 50, 50);
        UIButton *btn = [[UIButton alloc] initWithFrame:frame];
        [btn setImage:[[Utilities sharedInstance] getCachedImage:badge.icon] forState:UIControlStateNormal];
        btn.tag = i++;
        [btn addTarget:self action:@selector(didTapBadge:) forControlEvents:UIControlEventTouchUpInside];
        [badgeCell addSubview:btn];
        [badgeCell bringSubviewToFront:btn];

        x++;
        if (x%BADGES_PER_ROW == 0) {
            x = 0;
            y++;
        }
    }
    
    [self disableUnavailableSegments];
    
	[theTableView reloadData];
    [self stopProgressBar];
}


- (void) didTapBadge: (UIControl *) button {
    FSBadge *badge = (FSBadge*)[user.badges objectAtIndex:button.tag];
    KBMessage *message = [[KBMessage alloc] initWithMember:badge.badgeName andMessage:badge.badgeDescription];
    [self displayPopupMessage:message];
    [message release];
    [[Beacon shared] startSubBeaconWithName:@"View Badge Details"];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
    theTableView = nil;
    
    name = nil;
    lastCheckinAddress = nil;
    nightsOut = nil;
    totalCheckins = nil;
    userIcon = nil;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    name = nil;
    lastCheckinAddress = nil;
    nightsOut = nil;
    totalCheckins = nil;
    userIcon = nil;
}

- (void)dealloc {
    [theTableView release];
    [badgeCell release];
    [addFriendCell release];
    [friendActionCell release];
    [friendPendingCell release];
    [friendHistoryCell release];
    [friendHistorySplitCell release];
    [userId release];
    [user release];
    [twitterStatuses release];
    [checkin release];
    
    [name release];
    [location release];
    [lastCheckinAddress release];
    [nightsOut release];
    [totalCheckins release];
    [userIcon release];
    [pingsAndUpdates release];
    [textButton release];
    [callButton release];
    [emailButton release];
    [twitterButton release];
    [facebookButton release];
    
    [super dealloc];
}


#pragma mark
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) { // Friend/I'm Here/Friending-Status row
        if ([user.userId isEqualToString:[self getAuthenticatedUser].userId]) {
            return 0;
        } else {
            return 1;
        }
    } else if (section == 1) { // badges
        return 2;
    } else if (section == 2) {
        return [user.mayorOf count];
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 43;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            if ([user.badges count] > 0) {
                return 60 * (([user.badges count]+BADGES_PER_ROW-1)/BADGES_PER_ROW) + 10;
            } else {
                return 0;
            }
        } else if (indexPath.row == 1) {
            return 42;
        }
    }
    return 44;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if (indexPath.section == 0) {
            return [self determineWhichFriendCellToDisplay:user.friendStatus];
        } else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                return badgeCell;
            } else {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
            }
        } else {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    // Set up the cell...
    switch (indexPath.section) {
        case 0:  // add friend/follow on twitter
            return [self determineWhichFriendCellToDisplay:user.friendStatus];
            break;
        case 1:  // badges
            if (indexPath.row == 0) {
                return badgeCell;
            }
            if (user) {
                if ([user.userId isEqualToString:[self getAuthenticatedUser].userId]) {
                    return friendHistorySplitCell;
                } else {
                    return friendHistoryCell;
                }
            }
            break;
        case 2:  // mayors
            cell.textLabel.text = ((FSVenue*)[user.mayorOf objectAtIndex:indexPath.row]).name;
            break;
        default:
            break;
    }
    return cell;
}

- (UITableViewCell*) determineWhichFriendCellToDisplay:(FSFriendStatus)status {
    if (status == FSStatusFriend) {
        return friendActionCell;
    } else if (status == FSStatusNotFriend) {
        return addFriendCell;
    } else if (status == FSStatusPendingYou || status == FSStatusPendingThem) {
        return friendPendingCell;
    }
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 24.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NULL;
    } else {
        // create the parent view that will hold header Label
        UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 24.0)] autorelease];
        customView.backgroundColor = [UIColor blackColor];
        
        // create the button object
        UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor blackColor];
        headerLabel.opaque = NO;
        headerLabel.textColor = [UIColor grayColor];
        headerLabel.highlightedTextColor = [UIColor grayColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:14];
        headerLabel.frame = CGRectMake(10.0, 0.0, 320.0, 24.0);
        
        // If you want to align the header text as centered
        // headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
        switch (section) {
            case 0:
                break;
            case 1:
                if ([user.badges count] < 1) {
                    [headerLabel release];
                    return nil;
                }
                headerLabel.text = @"Badges";
                break;
            case 2:
                if ([user.mayorOf count] < 1) {
                    [headerLabel release];
                    return nil;
                }
                headerLabel.text = @"Mayor";
                break;
            default:
                headerLabel.text = @"You shouldn't see this";
                break;
        }
        [customView addSubview:headerLabel];
        [headerLabel release];
        return customView;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 1 && indexPath.row == 1) { // badge-friends section
//        ProfileFriendsViewController *profileFriendsController = [[ProfileFriendsViewController alloc] initWithNibName:@"ProfileFriendsViewController" bundle:nil];
//        profileFriendsController.userId = user.userId;
//        [theTableView deselectRowAtIndexPath:indexPath animated:YES];
//        [self.navigationController pushViewController:profileFriendsController animated:YES];
//        [profileFriendsController release];
//    } else 
    if (indexPath.section == 2) { // mayor section
        PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];
        placeDetailController.venueId = ((FSVenue*)[user.mayorOf objectAtIndex:indexPath.row]).venueid;
        [theTableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.navigationController pushViewController:placeDetailController animated:YES];
        [placeDetailController release];
    }
}

#pragma mark
#pragma mark IBAction methods

- (void) viewProfilesFriends {
    ProfileFriendsViewController *profileFriendsController = [[ProfileFriendsViewController alloc] initWithNibName:@"ProfileFriendsViewController" bundle:nil];
    profileFriendsController.userId = user.userId;
    [self.navigationController pushViewController:profileFriendsController animated:YES];
    [profileFriendsController release];
}

- (void) textProfile {
    [self displayActionSheet:@"Yes, open SMS app" withTag:0];
}

- (void) callProfile {    
    [self displayActionSheet:@"Yes, open Phone app" withTag:1];
}

- (void) emailProfile {
    [self displayActionSheet:@"Yes, open Mail app" withTag:2];
}

- (void) viewProfilesTwitterFeed {
    [self startProgressBar:@"Retrieving tweets..."];

    MGTwitterEngine *twitterEngine = [[[MGTwitterEngine alloc] initWithDelegate:self] autorelease];
    NSLog(@"twitter username: %@", user.twitter);
    NSString *twitters = [twitterEngine getUserTimelineFor:user.twitter sinceID:0 startingAtPage:0 count:20];
    NSLog(@"twitter: %@", twitters);
}

- (void) facebookProfile {
    [self displayActionSheet:@"Yes, open Facebook app" withTag:4];
}

- (void) displayActionSheet:(NSString*)title withTag:(NSInteger)tag {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"You will be leaving the Kickball app. Are you sure?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:title,nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = tag;
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (void) viewVenue {
    PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];
    FSVenue *venue = user.checkin.venue;
    placeDetailController.venueId = venue.venueid;
    [self.navigationController pushViewController:placeDetailController animated:YES];
    [placeDetailController release];
}

- (void) checkinToProfilesVenue {
    //[self startProgressBar:@"Checking in to this venue..."];
	
	PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];    
    placeDetailController.venueId = user.checkin.venue.venueid;
    placeDetailController.doCheckin = YES;
    [self.navigationController pushViewController:placeDetailController animated:YES];
    [placeDetailController release];
}

- (void) unfriend {
    // TODO: waiting for this to be implemented in the API
}

- (void) friendUser {
    [self startProgressBar:@"Sending Friend Request..."];
    [[FoursquareAPI sharedInstance] doSendFriendRequest:user.userId withTarget:self andAction:@selector(friendRequestResponseReceived:withResponseString:)];
    [[Beacon shared] startSubBeaconWithName:@"Friend User from Profile View"];
}

- (void) togglePingsAndUpdates {
    [self startProgressBar:@"Changing your ping update preferences..."];
    NSString *ping = @"on";
    if (isPingAndUpdatesOn) {
        ping = @"off";
    }
    [[FoursquareAPI sharedInstance] setPings:ping forUser:user.userId withTarget:self andAction:@selector(pingUpdateResponseReceived:withResponseString:)];
}

- (void) viewHistory {
    HistoryViewController *historyController = [[HistoryViewController alloc] initWithNibName:@"HistoryViewController" bundle:nil];
    [self.navigationController pushViewController:historyController animated:YES];
    [historyController release];
}

#pragma mark
#pragma mark private methods

- (void) disableUnavailableSegments {
    if (user.phone == nil) {
        textButton.enabled = NO;
        callButton.enabled = NO;
    }
    
    if (user.email == nil) {
        emailButton.enabled = NO;
    }
    
    if (user.twitter == nil) {
        twitterButton.enabled = NO;
    }
    
    if (user.facebook == nil) {
        facebookButton.enabled = NO;
    }
}

#pragma mark
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"clicked the 'leave' button; tag: %d", actionSheet.tag);
    if (buttonIndex == 0) {
        switch (actionSheet.tag) {
            case 0:
                [[Beacon shared] startSubBeaconWithName:@"SMS User"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", user.phone]]];
                break;
            case 1:
                [[Beacon shared] startSubBeaconWithName:@"Phone User"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", user.phone]]];
                break;
            case 2:
                [[Beacon shared] startSubBeaconWithName:@"Email User"];
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: [NSString stringWithFormat:@"mailto:%@", user.email]]];
                break;
            case 4:
                [[Beacon shared] startSubBeaconWithName:@"Facebook User"];
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: [NSString stringWithFormat:@"fb://%@", user.facebook]]];
                break;
            default:
                break;
        }
    }
}

#pragma mark
#pragma mark selectors for FoursquareAPI calls


- (void) friendRequestResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"friend request instring: %@", inString);
    FSUser *friendedUser = [FoursquareAPI userFromResponseXML:inString];
    [self stopProgressBar];
    user.friendStatus = FSStatusPendingYou;
    [theTableView reloadData];
    
    KBMessage *msg = [[KBMessage alloc] initWithMember:@"Kickball Notification" andMessage:@"Your friend request has been sent."];
    [self displayPopupMessage:msg];
    [msg release];
}

- (void) pingUpdateResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"instring: %@", inString);
	BOOL newPingSetting = [FoursquareAPI pingSettingFromResponseXML:inString];
    NSLog(@"new ping setting: %d", newPingSetting);
    user.sendsPingsToSignedInUser = !user.sendsPingsToSignedInUser;
    isPingAndUpdatesOn = !isPingAndUpdatesOn;
    //pingsAndUpdates.selected = isPingAndUpdatesOn;
    if (isPingAndUpdatesOn) {
        [pingsAndUpdates setImage:[UIImage imageNamed:@"profilePings01x.png"] forState:UIControlStateNormal];
    } else {
        [pingsAndUpdates setImage:[UIImage imageNamed:@"profilePings03x.png"] forState:UIControlStateNormal];
    }
    [self stopProgressBar];
}

- (void) checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"instring: %@", inString);
	checkin = [FoursquareAPI checkinsFromResponseXML:inString];
//    isUserCheckedIn = YES;
//	  [theTableView reloadData];
//    FSCheckin *ci = (FSCheckin*)[self.checkin objectAtIndex:0];
//    if (ci.specials != nil) {
//        specialsButton.hidden = NO;
//    }
    [self stopProgressBar];
    
    // TODO: figure out what we want to do here. How do we show points?
    KBMessage *msg = [[KBMessage alloc] initWithMember:@"Kickball Notification" andMessage:@"Thank you for checking in"];
    [self displayPopupMessage:msg];
    [msg release];
}

#pragma mark
#pragma mark MGTwitterEngineDelegate methods

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier {
    twitterStatuses = [[NSArray alloc] initWithArray:statuses];
    
    [self stopProgressBar];
    ProfileTwitterViewController *twitterController = [[ProfileTwitterViewController alloc] initWithNibName:@"ProfileTwitterViewController" bundle:nil];
    twitterController.tweets = [[[NSArray alloc] initWithArray:twitterStatuses] autorelease];
    [self presentModalViewController:twitterController animated:YES];
    [twitterController release];
    
    //[self.tableView reloadData];
    NSLog(@"statusesReceived: %@", statuses);
}

- (void)requestSucceeded:(NSString *)connectionIdentifier {
    NSLog(@"requestSucceeded: %@", connectionIdentifier);
    [self stopProgressBar];
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error {
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Twitter" andMessage:@"Sorry. It seems that Twitter is down. Try again later."];
    [self displayPopupMessage:message];
    [message release];
    NSLog(@"requestFailed: %@", connectionIdentifier);
    NSLog(@"error: %@", error);
    [self stopProgressBar];
}

@end
