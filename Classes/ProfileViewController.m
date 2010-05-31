//
//  ProfileViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 10/29/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KBGenericPhotoViewController.h"
#import "ProfileViewController.h"
#import "FoursquareAPI.h"
#import "FSVenue.h"
#import "PlaceDetailViewController.h"
#import "MGTwitterEngine.h"
#import "Utilities.h"
#import "ProfileTwitterViewController.h"
#import "ProfileFriendsViewController.h"
#import "HistoryViewController.h"
#import "ASIHTTPRequest.h"
#import "KickballAPI.h"
#import "KBGoody.h"
#import "KBPhotoViewController.h"
#import "PlacesListTableViewCellv2.h"


#define BADGES_PER_ROW 4

@interface ProfileViewController (Private)

- (void)userResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;
- (void) displayActionSheet:(NSString*)title;
- (UITableViewCell*) determineWhichFriendCellToDisplay:(FSFriendStatus)status;
- (void) disableUnavailableSegments;

@end

@implementation ProfileViewController

@synthesize userId, badgeCell;
@synthesize user;

- (void)viewDidLoad {
    hideFooter = YES;
    pageType = KBPageTypeOther;
    pageViewType = KBPageViewTypeList;
    
    [super viewDidLoad];
    
    name.text = @"";
    location.text = @"";
    lastCheckinAddress.text = @"";
    
    if ([userId isEqualToString:[self getAuthenticatedUser].userId]) {
        signedInUserIcon.enabled = NO;
    }
    
    [self addHeaderAndFooter:theTableView];
    
    refreshHeaderView.backgroundColor = [UIColor blackColor];
    
    [self executeFoursquareCalls];
}

- (void) executeFoursquareCalls {
    [self startProgressBar:@"Retrieving profile..."];
    [[FoursquareAPI sharedInstance] getUser:self.userId withTarget:self andAction:@selector(userResponseReceived:withResponseString:)];
    [FlurryAPI logEvent:@"Profile"];

    [self retrieveUserPhotos];
}

- (void) photoCountRequestWentWrong:(ASIHTTPRequest *) request {
    NSLog(@"BOOOOOOOOOOOO!");
    hasPhotos = NO;
}

- (void) photoCountRequestDidFinish:(ASIHTTPRequest *) request {
    if ([request responseString]) {
        int photoCount = [[request responseString] intValue];
        if (photoCount > 0) {
            hasPhotos = YES;
        } else {
            hasPhotos = NO;
        }
    } else {
        hasPhotos = NO;
    }
}

- (void) setAllUserFields:(FSUser*)theUser {
    name.text = theUser.firstnameLastInitial;
    
    if ([theUser.checkin.display rangeOfString:@"[off the grid]"].location != NSNotFound) {
        location.text = @"[off the grid]";
        lastCheckinAddress.text = @"...location unknown...";
        hereIAmButton.enabled = NO;
        locationOverlayButton.enabled = NO;
    } else {
        if (theUser.checkin.venue) {
            location.text = theUser.checkin.venue.name;
            hereIAmButton.enabled = YES;
            if (theUser.checkin.shout) {
                lastCheckinAddress.text = theUser.checkin.shout;
            } else {
                lastCheckinAddress.text = theUser.checkin.venue.venueAddress;
            }
        } else {
            location.text = theUser.checkin.shout;
            hereIAmButton.enabled = NO;
        }
    }
    
    isPingAndUpdatesOn = theUser.sendsPingsToSignedInUser;
    if (isPingAndUpdatesOn) {
        [pingsAndUpdates setImage:[UIImage imageNamed:@"profilePings01x.png"] forState:UIControlStateNormal];
    } else {
        [pingsAndUpdates setImage:[UIImage imageNamed:@"profilePings03x.png"] forState:UIControlStateNormal];
    }
    //pingsAndUpdates.selected = user.sendsPingsToSignedInUser;
    
    // user icon
    userIcon.image = [[Utilities sharedInstance] getCachedImage:theUser.photo];
    userIcon.layer.masksToBounds = YES;
    userIcon.layer.cornerRadius = 5.0;
}

- (void) userResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSString *errorMessage = [FoursquareAPI errorFromResponseXML:inString];
    if (errorMessage) {
        [self displayFoursquareErrorMessage:errorMessage];
    } else {
        user = [[FoursquareAPI userFromResponseXML:inString] retain];

        [self setAllUserFields:user];
        
        // badges
        // I was hoping for something elegant, and it seemed like I was going to get there, but, as you can see, I didn't quite make it
        // I'm sure there's a better way to do this, but this works.
        int x = 0;
        int y = 0;
        int i = 0;
        for (FSBadge *badge in user.badges) {
            CGRect frame= CGRectMake(x*66 + 10, y*66 + 4, 74, 74);
            UIButton *btn = [[UIButton alloc] initWithFrame:frame];
            [btn setImage:[[Utilities sharedInstance] getCachedImage:badge.icon] forState:UIControlStateNormal];
            btn.tag = i++;
            [btn addTarget:self action:@selector(didTapBadge:) forControlEvents:UIControlEventTouchUpInside];
            [badgeCell addSubview:btn];
            [badgeCell bringSubviewToFront:btn];
            [btn release];

            x++;
            if (x%BADGES_PER_ROW == 0) {
                x = 0;
                y++;
            }
        }
        
        [self disableUnavailableSegments];
        
        [theTableView reloadData];
    }
    [self stopProgressBar];
}


- (void) didTapBadge: (UIControl *) button {
    FSBadge *badge = (FSBadge*)[user.badges objectAtIndex:button.tag];
    KBMessage *message = [[KBMessage alloc] initWithMember:badge.badgeName andMessage:badge.badgeDescription];
    [self displayPopupMessage:message];
    [message release];
    [FlurryAPI logEvent:@"View Badge Details"];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
    theTableView = nil;
    
    name = nil;
    lastCheckinAddress = nil;
    totalCheckins = nil;
    userIcon = nil;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    name = nil;
    lastCheckinAddress = nil;
    totalCheckins = nil;
    userIcon = nil;
}

- (void)dealloc {
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
    [totalCheckins release];
    [userIcon release];
    [pingsAndUpdates release];
    [textButton release];
    [callButton release];
    [emailButton release];
    [twitterButton release];
    [facebookButton release];
    [locationOverlayButton release];
    [hereIAmButton release];
    
    [userPhotos release];
    [profileOptionsView release];
    [profileInfoView release];
    [photoCell release];
    [checkinNotificationSwitch release];
    [photoNotificationSwitch release];
    
    [super dealloc];
}


#pragma mark
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) { // Friend/I'm Here/Friending-Status row
        if ([user.userId isEqualToString:[self getAuthenticatedUser].userId]) {
            return 0;
        } else {
            return 1;
        }
    } else if (section == 1) { // photos
        return (userPhotos != nil && [userPhotos count] > 0);
    } else if (section == 2) { // mayor
        return [user.mayorOf count];
    } else if (section == 3) { // badges
        return 1;
    } else if (section == 4) { // see friends
        return 1;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 54;
    } else if (indexPath.section == 1) {
        return 73;
    } else if (indexPath.section == 2) {
        return 44;
    } else if (indexPath.section == 3) {
        if ([user.badges count] > 0) {
            return 72 * (([user.badges count]+BADGES_PER_ROW-1)/BADGES_PER_ROW) + 10;
        } else {
            return 0;
        }
    } else if (indexPath.section == 4) {
        return 43;
    } 
    return 44;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    PlacesListTableViewCellv2 *cell = (PlacesListTableViewCellv2*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PlacesListTableViewCellv2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell adjustLabelWidth:220.0];
    }
    
    switch (indexPath.section) {
        case 0:  // add friend/follow on twitter
            return [self determineWhichFriendCellToDisplay:user.friendStatus];
            break;
        case 1:  // photos
            if (userPhotos != nil && [userPhotos count] > 0) {
                int x = 0;
                for (KBGoody *photo in userPhotos) {
                    CGRect frame = CGRectMake(x*73, 0, 73, 73);
                    TTImageView *ttImage = [[TTImageView alloc] initWithFrame:frame];
                    ttImage.urlPath = photo.thumbnailImagePath;
                    ttImage.clipsToBounds = YES;
                    ttImage.contentMode = UIViewContentModeScaleToFill;
                    [photoCell addSubview:ttImage];
                    
                    UIButton *button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
                    button.frame = frame;
                    button.tag = x++;
                    button.showsTouchWhenHighlighted = YES;
                    [button addTarget:self action:@selector(displayImages:) forControlEvents:UIControlEventTouchUpInside]; 
                    [photoCell addSubview:button];
                    [button release];
                    [ttImage release];
                }
            }
            return photoCell;
            break;
        case 2:  // mayors
            cell.venueName.text = ((FSVenue*)[user.mayorOf objectAtIndex:indexPath.row]).name;
            cell.venueAddress.text = ((FSVenue*)[user.mayorOf objectAtIndex:indexPath.row]).addressWithCrossstreet;
            cell.categoryIcon.urlPath = ((FSVenue*)[user.mayorOf objectAtIndex:indexPath.row]).primaryCategory.iconUrl;
            break;
        case 3:  // badges
            //badgeCell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wood_bg.png"]];
            return badgeCell;
            break;
        case 4:  // see friends
            if (user) {
                return friendHistoryCell;
            }
            break;
        default:
            break;
    }
    return cell;
}

- (void) displayImages:(id)sender {
    int buttonPressedIndex = ((UIButton *)sender).tag;
    MockPhotoSource *photoSource = [[KickballAPI kickballApi] convertGoodiesIntoPhotoSource:userPhotos withTitle:user.firstnameLastInitial];
    KBPhotoViewController *photoController = [[KBPhotoViewController alloc] initWithPhotoSource:photoSource];
    photoController.centerPhoto = [photoSource photoAtIndex:buttonPressedIndex];  // sets the photo displayer to the correct image
    photoController.goodies = userPhotos;
    [self.navigationController pushViewController:photoController animated:YES];
    [photoController release];
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
	return 39.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section > 1 && indexPath.section < 4) {
        [cell setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];  
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NULL;
    } else {
        BlackTableCellHeader *headerView = [[[BlackTableCellHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 36)] autorelease];
        
        switch (section) {
            case 0:
                headerView.leftHeaderLabel.text = @"";
                break;
            case 1:
                if (userPhotos != nil && [userPhotos count] > 0) {
                    headerView.leftHeaderLabel.text = [NSString stringWithFormat:@"%d %@", [userPhotos count], [userPhotos count] == 1 ? @"Photo" : @"Photos"];
                    
                    UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    myDetailButton.frame = CGRectMake(210, 0, 92, 39);
                    myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                    myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                    [myDetailButton setImage:[UIImage imageNamed:@"profileSeeAllPhotos01.png"] forState:UIControlStateNormal];
                    [myDetailButton setImage:[UIImage imageNamed:@"profileSeeAllPhotos02.png"] forState:UIControlStateHighlighted];
                    [myDetailButton addTarget:self action:@selector(displayImages:) forControlEvents:UIControlEventTouchUpInside]; 
                    [headerView addSubview:myDetailButton];
                } else {
                    return nil;
                }
                break;
            case 2:
                if ([user.mayorOf count] < 1) {
                    return nil;
                }
                headerView.leftHeaderLabel.text = [NSString stringWithFormat:@"%d Mayorship%@", [user.mayorOf count], [user.mayorOf count] > 1 ? @"s" : @""];
                break;
            case 3:
                if ([user.badges count] < 1) {
                    return nil;
                }
                headerView.leftHeaderLabel.text = [NSString stringWithFormat:@"%d Badge%@", [user.badges count], [user.badges count] > 1 ? @"s" : @""];
                break;
            case 4:
                // hack
//                if (YES) {
//                    CGRect frame = headerView.frame;
//                    frame.size = CGSizeMake(frame.size.width, 18);
//                    headerView.frame = frame;
//                }
                headerView.leftHeaderLabel.text = @"";
                break;
            default:
                headerView.leftHeaderLabel.text = @"You shouldn't see this";
                break;
        }
        return headerView;
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
        PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView_v2" bundle:nil];
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

    // FIXME: use the official twitterEngine
    //MGTwitterEngine *twitterEngine = [[[MGTwitterEngine alloc] initWithDelegate:self] autorelease];
    MGTwitterEngine *twitterEngine = [[KBTwitterManager twitterManager] twitterEngine];
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
    PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView_v2" bundle:nil];
    FSVenue *venue = user.checkin.venue;
    placeDetailController.venueId = venue.venueid;
    [self.navigationController pushViewController:placeDetailController animated:YES];
    [placeDetailController release];
}

- (void) checkinToProfilesVenue {
	PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView_v2" bundle:nil];    
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
    [FlurryAPI logEvent:@"Friend User from Profile View"];
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

- (void) retrieveUserPhotos {
    
    NSString *gorlochUrlString = [NSString stringWithFormat:@"%@/gifts/owner/%@.xml?limit=4", kickballDomain, userId];
    NSLog(@"photo url string: %@", gorlochUrlString);
    ASIHTTPRequest *gorlochRequest = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:gorlochUrlString]] autorelease];
    
    [gorlochRequest setDidFailSelector:@selector(photoRequestWentWrong:)];
    [gorlochRequest setDidFinishSelector:@selector(photoRequestDidFinish:)];
    [gorlochRequest setTimeOutSeconds:500];
    [gorlochRequest setDelegate:self];
    [gorlochRequest startAsynchronous];
}

- (void) viewYourPhotos {
//    MockPhotoSource *photoSource = [[KickballAPI kickballApi] convertGoodiesIntoPhotoSource:[[KickballAPI kickballApi] parsePhotosFromXML:[request responseString]] withTitle:@"Your Photos"];
//    KBGenericPhotoViewController *photoController = [[KBGenericPhotoViewController alloc] initWithPhotoSource:photoSource];
//    [self stopProgressBar];
//    [self.navigationController pushViewController:photoController animated:YES];
//    [photoController release];
}

- (void) photoRequestWentWrong:(ASIHTTPRequest *) request {
    NSLog(@"BOOOOOOOOOOOO!");
}

- (void) photoRequestDidFinish:(ASIHTTPRequest *) request {
    userPhotos = [[[KickballAPI kickballApi] parsePhotosFromXML:[request responseString]] retain];
    
    [theTableView reloadData];
}

- (void) showProfileOptions {
    profileOptionsView.frame = CGRectMake(0, 48, profileOptionsView.frame.size.width, profileOptionsView.frame.size.height);
    [self.view addSubview:profileOptionsView];
}

- (void) removeProfileOptions {
    [profileOptionsView removeFromSuperview];
}

- (void) showInfoOptions {
    profileInfoView.frame = CGRectMake(0, 48, profileInfoView.frame.size.width, profileInfoView.frame.size.height);
    [self.view addSubview:profileInfoView];
}

- (void) removeInfoOptions {
    [profileInfoView removeFromSuperview];
}

#pragma mark 
#pragma mark table refresh methods

- (void) refreshTable {
	[[FoursquareAPI sharedInstance] getUser:self.userId withTarget:self andAction:@selector(userResponseReceivedWithRefresh:withResponseString:)];
}

- (void)userResponseReceivedWithRefresh:(NSURL *)inURL withResponseString:(NSString *)inString {
    [self userResponseReceived:inURL withResponseString:inString];
	[self dataSourceDidFinishLoadingNewData];
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
                [FlurryAPI logEvent:@"SMS User"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", user.phone]]];
                break;
            case 1:
                [FlurryAPI logEvent:@"Phone User"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", user.phone]]];
                break;
            case 2:
                [FlurryAPI logEvent:@"Email User"];
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: [NSString stringWithFormat:@"mailto:%@", user.email]]];
                break;
            case 4:
                [FlurryAPI logEvent:@"Facebook User"];
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
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Twitter Error" andMessage:@"Sorry. It seems that Twitter is down. Try again later."];
    [self displayPopupMessage:message];
    [message release];
    NSLog(@"requestFailed: %@", connectionIdentifier);
    NSLog(@"error: %@", error);
    [self stopProgressBar];
}

@end
