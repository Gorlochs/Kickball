//
//  PlaceDetailViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 10/28/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PlaceDetailViewController.h"
#import "ProfileViewController.h"
#import "PlaceTwitterViewController.h"
#import "FoursquareAPI.h"
#import "VenueAnnotation.h"
#import "GAConnectionManager.h"
#import "SBJSON.h"
#import "GeoApiTableViewController.h"
#import "GeoApiDetailsViewController.h"
#import "GAPlace.h"
#import "TipDetailViewController.h"
#import "FSTip.h"
#import "Utilities.h"
#import "FSBadge.h"
#import "FSSpecial.h"
#import "CreateTipTodoViewController.h"
#import "ASIFormDataRequest.h"
#import "KickballAppDelegate.h"
#import "KBPin.h"
#import "NSString+hmac.h"
#import "ASINetworkQueue.h"
#import "KBGoody.h"
#import "KBAsyncImageView.h"

@interface PlaceDetailViewController (Private)

- (BOOL)uploadImage:(NSData *)imageData filename:(NSString *)filename;
- (void)venueResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;
- (void) prepViewWithVenueInfo:(FSVenue*)venueToDisplay;
- (void) pushProfileDetailController:(NSString*)profileUserId;

@end


@implementation PlaceDetailViewController

@synthesize mayorMapCell;
@synthesize venue;
@synthesize checkin;
@synthesize venueId;
@synthesize checkinCell;
@synthesize giftCell;
@synthesize doCheckin;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

// FIXME: add a check to make sure that a valid venueId exists, since this page will crap out if it doesn't.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayTodoTipMessage:) name:@"todoTipSent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkinAndShoutToVenue:) name:@"shoutAndCheckinSent" object:nil];
    
    isUserCheckedIn = NO;
    
    venueDetailButton.hidden = YES;
    twitterButton.enabled = NO;
    
    // this is to clear out the placeholder text, which is useful in IB
    venueName.text = @"";
    venueAddress.text = @"";
    
    // pull this up into a method (or property)
    FSUser *tmpUser = [self getAuthenticatedUser];
    NSLog(@"auth'd user: %@", tmpUser);
    signedInUserIcon.imageView.image = [[Utilities sharedInstance] getCachedImage:tmpUser.photo];
    signedInUserIcon.hidden = NO;
    isPingOn = tmpUser.isPingOn;
    isTwitterOn = tmpUser.sendToTwitter;
    [self setProperButtonStates];
//    [self setProperTwitterButtonState];
//    [self setProperPingButtonState];
//    twitterButton.selected = isTwitterOn;
//    pingToggleButton.selected = isPingOn;
    
    [self addHeaderAndFooter:theTableView];
    //theTableView.separatorColor = [UIColor blackColor];
    
    [self startProgressBar:@"Retrieving venue details..."];
    [[FoursquareAPI sharedInstance] getVenue:venueId withTarget:self andAction:@selector(venueResponseReceived:withResponseString:)];
    [[Beacon shared] startSubBeaconWithName:@"Venue Detail"];
    
    // get gift info
    NSString *gorlochUrlString = [NSString stringWithFormat:@"http://kickball.gorlochs.com/kickball/gifts/venue/%@.xml", venueId];
    NSLog(@"url: %@", gorlochUrlString);
    ASIHTTPRequest *gorlochRequest = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:gorlochUrlString]] autorelease];
            
    [gorlochRequest setDidFailSelector:@selector(venueRequestWentWrong:)];
    [gorlochRequest setDidFinishSelector:@selector(venueRequestDidFinish:)];
    [gorlochRequest setTimeOutSeconds:500];
    [gorlochRequest setDelegate:self];
    [gorlochRequest startAsynchronous];
}


- (void) venueRequestWentWrong:(ASIHTTPRequest *) request {
    NSLog(@"BOOOOOOOOOOOO!");
}

- (void) venueRequestDidFinish:(ASIHTTPRequest *) request {
    NSLog(@"YAY! Venue queue is complete! response: %@", [request responseString]);
    
    goodies = [[NSMutableArray alloc] initWithCapacity:1];
    
    CXMLDocument *rssParser = [[[CXMLDocument alloc] initWithXMLString:[request responseString] options:0 error:nil] autorelease];
    
    // Create a new Array object to be used with the looping of the results from the rssParser
    NSArray *resultNodes = NULL;
    
    // Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
    resultNodes = [rssParser nodesForXPath:@"//gift" error:nil];
    
    // Loop through the resultNodes to access each items actual data
    for (CXMLElement *resultElement in resultNodes) {
        
        KBGoody *goody = [[KBGoody alloc] init];
        
        // Loop through the children of the current  node
        for (int counter = 0; counter < [resultElement childCount]; counter++) {
            
            // TODO: we can also just pass in the resultElement into a KBGoody constructor and let the object take care of the object construction
//            NSLog(@"resultsElement stringValue: %@", [[resultElement childAtIndex:counter] stringValue]);
//            NSLog(@"resultsElement name: %@", [[resultElement childAtIndex:counter] name]);
            
            NSString *name = [[resultElement childAtIndex:counter] name];
            NSString *value = [[resultElement childAtIndex:counter] stringValue];
            if ([name isEqualToString:@"is-banned"]) {
                goody.isBanned = [value boolValue];
            } else if ([name isEqualToString:@"is-public"]) {
                goody.isPublic = [value boolValue];
            } else if ([name isEqualToString:@"message-text"]) {
                goody.messageText = value;
            } else if ([name isEqualToString:@"name"]) {
                
            } else if ([name isEqualToString:@"owner-id"]) {
                goody.ownerId = value;
            } else if ([name isEqualToString:@"photo-file-name"]) {
                goody.imageName = value;
            } else if ([name isEqualToString:@"recipient-id"]) {
                goody.recipientId = value;
            } else if ([name isEqualToString:@"uuid"]) {
                goody.goodyId = value;
            } else if ([name isEqualToString:@"venue-id"]) {
                goody.venueId = value;
            }
        }
        
        [goodies addObject:goody];
        [goody release];
        
        // Add the blogItem to the global blogEntries Array so that the view can access it.
        //[blogEntries addObject:[blogItem copy]];
    }
    if ([goodies count] > 0) {
        firstTimePhotoButton.hidden = YES;
        
        int i = 0;
        for (KBGoody *goody in goodies) {
            CGRect frame = CGRectMake(0, i*72, 72, 72);
            KBAsyncImageView* asyncImage = [[[KBAsyncImageView alloc] initWithFrame:frame] autorelease];
            NSLog(@"********** mediumimage path: %@", goody.mediumImagePath);
            asyncImage.contentMode = UIViewContentModeCenter;
            asyncImage.clipsToBounds = YES;
            [asyncImage loadImageFromURL:[NSURL URLWithString:goody.mediumImagePath] withRoundedEdges:NO];
            [photoView addSubview:asyncImage];
            i++;
        }
    }
    //[theTableView reloadData];
    NSLog(@"goodies: %@", goodies);
    NSLog(@"goodies count: %d", [goodies count]);
}

- (void) displayTodoTipMessage:(NSNotification *)inNotification {
    KBMessage *msg = [[KBMessage alloc] initWithMember:@"Kickball Notification" andMessage:@"Your todo/tip was sent"];
    [self displayPopupMessage:msg];
    [msg release];
}

- (void)venueResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"venue response string: %@", inString);
	self.venue = [FoursquareAPI venueFromResponseXML:inString];
    [self prepViewWithVenueInfo:self.venue];

	[theTableView reloadData];
    [self stopProgressBar];
    
    if (doCheckin) {
        [self checkinToVenue];
    }
    
    if (self.venue.specials != nil &&[self.venue.specials count] > 0) {
        specialsButton.hidden = NO;
    }
}


- (void) prepViewWithVenueInfo:(FSVenue*)venueToDisplay {
    MKCoordinateRegion region;
    MKCoordinateRegion fullRegion;
    MKCoordinateSpan span;
    MKCoordinateSpan fullSpan;
    span.latitudeDelta = 0.002;
    span.longitudeDelta = 0.002;
    fullSpan.latitudeDelta = 0.02;
    fullSpan.longitudeDelta = 0.02;
    
    CLLocationCoordinate2D location = venueToDisplay.location;
    
    double tmp = [[NSNumber numberWithDouble:location.longitude] doubleValue];
    CLLocationCoordinate2D shiftedLocation = {latitude: venueToDisplay.location.latitude , longitude: (CLLocationDegrees)(tmp - 0.0045) };
    
    fullRegion.span = fullSpan;
    fullRegion.center = location;
    region.span = span;
    region.center = shiftedLocation;
    
    [smallMapView setRegion:region animated:NO];
    [smallMapView regionThatFits:region];
    [smallMapView setShowsUserLocation:YES];
    [fullMapView setRegion:fullRegion animated:NO];
    [fullMapView regionThatFits:fullRegion];
    [fullMapView setShowsUserLocation:YES];
    
    VenueAnnotation *venueAnnotation = [[VenueAnnotation alloc] initWithCoordinate:location];
    [smallMapView addAnnotation:venueAnnotation];
    [fullMapView addAnnotation:venueAnnotation];
    [venueAnnotation release];
    
    venueName.text = venueToDisplay.name;
    venueAddress.text = venueToDisplay.addressWithCrossstreet;
    
    venueDetailButton.hidden = NO;
    
    if (!venueToDisplay.phone) {
        phoneButton.hidden = YES;
    }
    
    if (venueToDisplay.mayor != nil) {
        mayorMapCell.imageView.image = [[Utilities sharedInstance] getCachedImage:venueToDisplay.mayor.photo];
        float sw=45/mayorMapCell.imageView.image.size.width;
        float sh=45/mayorMapCell.imageView.image.size.height;
        mayorMapCell.imageView.transform=CGAffineTransformMakeScale(sw,sh);
        mayorMapCell.imageView.layer.masksToBounds = YES;
        mayorMapCell.imageView.layer.cornerRadius = 4.0;
        
        mayorNameLabel.text = venueToDisplay.mayor.firstnameLastInitial;
        mayorCheckinCountLabel.text = [NSString stringWithFormat:@"Mayor, %d check-ins", venueToDisplay.mayorCount];
        noMayorImage.hidden = YES;
        mayorOverlay.hidden = NO;
        mayorArrow.hidden = NO;
        mayorCrown.hidden = NO;
    } else {
        noMayorImage.hidden = NO;
        mayorOverlay.hidden = YES;
        mayorArrow.hidden = YES;
        mayorCrown.hidden = YES;
    }
    
    if (venueToDisplay.twitter != nil && ![venueToDisplay.twitter isEqualToString:@""]) {
        twitterButton.enabled = YES;
    } else {
        twitterButton.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
    theTableView = nil;
    mayorMapCell = nil;
    checkinCell = nil;
    giftCell = nil;
    smallMapView = nil;
    venueName = nil;
    venueAddress = nil;
    mayorNameLabel = nil;
    twitterButton = nil;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    theTableView = nil;
    mayorMapCell = nil;
    checkinCell = nil;
    giftCell = nil;
    smallMapView = nil;
    venueName = nil;
    venueAddress = nil;
    mayorNameLabel = nil;
    twitterButton = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 10;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) { // shout
        return isUserCheckedIn;
    } else if (section == 1) { // points
        return isUserCheckedIn;
    } else if (section == 2) { // badge
        return isUserCheckedIn && [[self getSingleCheckin].badges count] > 0;
    } else if (section == 3) { // checkin mayor
        return [self hasMayorCell];
    } else if (section == 4) { // checkin
        return !isUserCheckedIn;
    } else if (section == 5) { // mayor & map cell
        return ![self isNewMayor];
    } else if (section == 6) { // gift
        //return 0;  // photos being moved out of the table
        return (goodies != nil && [goodies count] > 0);
        //return isUserCheckedIn;
    } else if (section == 7) { // people here
        return [venue.currentCheckins count] + 1;
    } else if (section == 8) { // tips
        return [venue.tips count];
        //return [venue.currentCheckins count];  // WTF? Where did this come from?
    } else if (section == 9) { // bottom button row
        return 1;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
        line.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.13];
        [cell addSubview:line];
        [line release];
    }
    
    
    // Set up the cell...
    if (indexPath.section == 0) {
        return shoutCell;
    } else if (indexPath.section == 1) {
        return pointsCell;
    } else if (indexPath.section == 2) {
        FSBadge *badge = (FSBadge*)[[self getSingleCheckin].badges objectAtIndex:0];
        badgeImage.image = [[Utilities sharedInstance] getCachedImage:badge.icon];
        badgeLabel.text = badge.badgeDescription;
        badgeLabel.numberOfLines = 2;
        badgeTitleLabel.text = badge.badgeName;
        return badgeCell;
    } else if (indexPath.section == 3) {
        if ([self getSingleCheckin].mayor.user == nil
                && [[self getSingleCheckin].mayor.mayorTransitionType isEqualToString:@"nochange"]) {
            
            newMayorshipLabel.text = [NSString stringWithFormat:@"You're still the mayor of %@!", venue.name];
            return newMayorCell;
        } else if ([[self getSingleCheckin].mayor.mayorTransitionType isEqualToString:@"stolen"] || [[self getSingleCheckin].mayor.mayorTransitionType isEqualToString:@"new"]) {
            if ([[self getSingleCheckin].mayor.mayorTransitionType isEqualToString:@"stolen"]) {
                //newMayorshipLabel.text = [NSString stringWithFormat:@"%@ (Crown stolen from %@)", [self getSingleCheckin].mayor.mayorCheckinMessage, [self getSingleCheckin].mayor.user.firstnameLastInitial];
                newMayorshipLabel.text = [NSString stringWithFormat:@"Congrats! %@ is yours with %d check-ins and %@ lost their crown.", 
                                          [self getSingleCheckin].venue.name, 
                                          [self getSingleCheckin].mayor.numCheckins, 
                                          [self getSingleCheckin].mayor.user.firstnameLastInitial];
            } else {
                newMayorshipLabel.text = [self getSingleCheckin].mayor.mayorCheckinMessage;
            }
            return newMayorCell;
        }
    } else if (indexPath.section == 4) {
        return checkinCell;
    } else if (indexPath.section == 5) {
        mayorMapCell.backgroundColor = [UIColor whiteColor];
        return mayorMapCell;
    } else if (indexPath.section == 6) {
        // photos have been moved out of the table
        int i = 0;
        for (KBGoody *goody in goodies) {
            CGRect frame = CGRectMake(0, i*74, 74, 74);
            KBAsyncImageView* asyncImage = [[[KBAsyncImageView alloc] initWithFrame:frame] autorelease];
            NSLog(@"********** mediumimage path: %@", goody.mediumImagePath);
            asyncImage.contentMode = UIViewContentModeCenter;
            asyncImage.clipsToBounds = YES;
            [asyncImage loadImageFromURL:[NSURL URLWithString:goody.mediumImagePath] withRoundedEdges:NO];
            [giftCell addSubview:asyncImage];
            i++;
        }
        return giftCell;
    } else if (indexPath.section == 7) {
        if (indexPath.row < [venue.currentCheckins count]) {
            cell.detailTextLabel.numberOfLines = 1;
            cell.detailTextLabel.text = nil;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
            FSCheckin *currentCheckin = ((FSCheckin*)[venue.currentCheckins objectAtIndex:indexPath.row]);
            cell.textLabel.text = currentCheckin.user.firstnameLastInitial;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            NSLog(@"currentcheckin user: %@", currentCheckin.user);
            cell.imageView.image = [[Utilities sharedInstance] getCachedImage:currentCheckin.user.photo];
            float sw=32/cell.imageView.image.size.width;
            float sh=32/cell.imageView.image.size.height;
            cell.imageView.transform=CGAffineTransformMakeScale(sw,sh);
            cell.imageView.layer.masksToBounds = YES;
            cell.imageView.layer.cornerRadius = 8.0;
        } else {
            return detailButtonCell;
        }
    } else if (indexPath.section == 8) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        FSTip *tip = (FSTip*) [venue.tips objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ says,", tip.submittedBy.firstnameLastInitial];
        //cell.detailTextLabel.numberOfLines = 2;
        cell.detailTextLabel.text = tip.text;
        cell.imageView.image = nil;
    } else if (indexPath.section == 9) {
        return bottomButtonCell;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor whiteColor]];  
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 44;
        case 1:
            return 36;
        case 2:
            return 66;
        case 3:
            return 221;
        case 4:
            return 37;
        case 5:
            return 69; // mayor-map cell
        case 6:
            return 74; // photos
        case 7:
            return 44;
        case 8:
            return 44;
        case 9:
            return 44;
        default:
            return 44;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 24.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
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
    
    switch (section) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
            [headerLabel release];
            return nil;
            break;
        case 6:
            if (goodies != nil && [goodies count] > 0) {
                headerLabel.text = [NSString stringWithFormat:@"%d %@", [goodies count], [goodies count] == 1 ? @"Photo" : @"Photos"];
            } else {
                [headerLabel release];
                return nil;
            }
            break;
        case 7:
            if ([venue.currentCheckins count] == 0 ) {
                [headerLabel release];
                return nil;
            } else {
                headerLabel.text = [NSString stringWithFormat:@"%d %@ Here", [venue.currentCheckins count], [venue.currentCheckins count] == 1 ? @"Person" : @"People"];
            }
            break;
        case 8:
            if ([venue.tips count] == 0) {
                [headerLabel release];
                return nil;
            } else {
                headerLabel.text = [NSString stringWithFormat:@"%d %@", [venue.tips count], [venue.tips count] == 1 ? @"Tip" : @"Tips"];
            }
            break;
        case 9:  
            [headerLabel release];
            return nil;
            break;
        default:
            headerLabel.text = @"You shouldn't see this";
            break;
    }
    [customView addSubview:headerLabel];
    [headerLabel release];
    return customView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 5) {
        [self pushProfileDetailController:venue.mayor.userId];
    } else if (indexPath.section == 7) {
        if (indexPath.row < [venue.currentCheckins count]) {
            FSCheckin *tmpCheckin = ((FSCheckin*)[venue.currentCheckins objectAtIndex:indexPath.row]);
            [self pushProfileDetailController:tmpCheckin.user.userId];
        }
    } else if (indexPath.section == 8) {
        FSTip *tip = ((FSTip*)[venue.tips objectAtIndex:indexPath.row]);
        TipDetailViewController *tipController = [[TipDetailViewController alloc] initWithNibName:@"TipView" bundle:nil];
        tipController.tip = tip;
        tipController.venue = venue;
        [self.navigationController pushViewController:tipController animated:YES];
        [tipController release];
    }
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) pushProfileDetailController:(NSString*)profileUserId {
    ProfileViewController *profileDetailController = [[ProfileViewController alloc] initWithNibName:@"ProfileView" bundle:nil];
    profileDetailController.userId = profileUserId;
    [self.navigationController pushViewController:profileDetailController animated:YES];
    [profileDetailController release];
}

- (void)dealloc {
    [theTableView release];
    [mayorMapCell release];
    [checkinCell release];
    [giftCell release];
    [pointsCell release];
    [badgeCell release];
    [newMayorCell release];
    [stillTheMayorCell release];
    [bottomButtonCell release];
    [detailButtonCell release];
    [shoutCell release];
    [smallMapView release];
    [fullMapView release];
    
    [venueName release];
    [venueAddress release];
    [mayorNameLabel release];
    [mayorCheckinCountLabel release];
    [badgeLabel release];
    [badgeTitleLabel release];
    [newMayorshipLabel release];
    [stillTheMayorLabel release];
    
    [badgeImage release];
    
    [twitterButton release];
    [pingAndTwitterToggleButton release];
    [venueDetailButton release];
    [specialsButton release];
    [mapButton release];
    [closeMapButton release];
    [phoneButton release];
    
    [checkin release];
    [venue release];
    [venueId release];
    [goodies release];
    
    [photoView release];
    [mayorOverlay release];
    [firstTimePhotoButton release];
    
    [super dealloc];
}

#pragma mark IBAction methods

- (void) callVenue {
    NSLog(@"phone number to call: %@", [NSString stringWithFormat:@"tel:%@", venue.phone]);
    [[Beacon shared] startSubBeaconWithName:@"call Venue"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", venue.phone]]];
}

- (void) uploadImageToServer {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:imagePickerController animated:YES];
}

- (void) showTwitterFeed {
    PlaceTwitterViewController *vc = [[PlaceTwitterViewController alloc] initWithNibName:@"PlaceTwitterViewController" bundle:nil];
    vc.twitterName = venue.twitter;
    vc.venueName = venue.name;
    [self presentModalViewController:vc animated:YES];
    [vc release];
}

- (void) checkinAndShoutToVenue:(NSNotification *)inNotification {
    NSLog(@"notification from shout %@", inNotification);
    [self startProgressBar:@"Checking in and shouting to this venue..."];
    [[FoursquareAPI sharedInstance] doCheckinAtVenueWithId:venue.venueid 
                                                  andShout:[[inNotification userInfo] objectForKey:@"shout"] 
                                                   offGrid:!isPingOn
                                                 toTwitter:[[[inNotification userInfo] objectForKey:@"isTweet"] boolValue]
                                                withTarget:self 
                                                 andAction:@selector(checkinResponseReceived:withResponseString:)];
    [[Beacon shared] startSubBeaconWithName:@"Check in and shout to Venue"];
}

- (void) checkinToVenue {
    [self startProgressBar:@"Checking in to this venue..."];
    [[FoursquareAPI sharedInstance] doCheckinAtVenueWithId:venue.venueid 
                                                  andShout:nil 
                                                   offGrid:!isPingOn
                                                 toTwitter:isTwitterOn
                                                withTarget:self 
                                                 andAction:@selector(checkinResponseReceived:withResponseString:)];
    [[Beacon shared] startSubBeaconWithName:@"Check in to Venue"];
}

- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"instring: %@", inString);
	self.checkin = [FoursquareAPI checkinFromResponseXML:inString];
    NSLog(@"checkin: %@", checkin);
    isUserCheckedIn = YES;
	[theTableView reloadData];
    FSCheckin *ci = [self getSingleCheckin];
    if (ci.specials != nil) {
        specialsButton.hidden = NO;
    }
    [self stopProgressBar];
    
    NSMutableString *checkinText = [[NSMutableString alloc] initWithCapacity:1];
    for (FSScore *score in ci.scoring.scores) {
        [checkinText appendFormat:[NSString stringWithFormat:@"+%d %@ \n", score.points, score.message]];
        NSLog(@"checkin text: %@", checkinText);
//        checkinText = [checkinText stringByAppendingString:[NSString stringWithFormat:@"+%d %@ \n", score.points, score.message]];
    }
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Check-in successful" andMessage:checkinText];
    [self displayPopupMessage:message];
    [checkinText release];
    [message release];
    
    if (isPingOn) {
        // TODO: make this asynchronous
        if ([[Utilities sharedInstance] friendsWithPingOn]) {
            NSLog(@"friends with ping on pulled from cache: %@", [[[Utilities sharedInstance] friendsWithPingOn] componentsJoinedByString:@","]);
            [self friendsReceived:nil];
        } else {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendsReceived:) name:@"friendsWithPingOnReceived" object:nil];
        }   
    }
}

- (void)friendsReceived:(NSNotification *)inNotification {
    NSMutableArray *friendIds = [[NSMutableArray alloc] initWithCapacity:1];
    for (FSUser* friend in [[Utilities sharedInstance] friendsWithPingOn]) {
        [friendIds addObject:friend.userId];
    }
    NSString *friendIdsString = [friendIds componentsJoinedByString:@","];
    [friendIds release];
    
    FSUser *user = [self getAuthenticatedUser];
    NSString *uid = user.userId;
    NSString *un = user.firstnameLastInitial;
    NSString *vn = venue.name;
    NSString *hashInput = [NSString stringWithFormat:@"%@%@%@", uid, un, vn];
    NSString *hash = [hashInput hmacSha1:kKBHashSalt];
    NSString *urlstring = @"https://www.gorlochs.com/kickball/push.php";
	
	NSURL *url = [NSURL URLWithString:urlstring];
	NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
	ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
	[request setPostValue:vn forKey:@"vn"];
	[request setPostValue:uid forKey:@"uid"];
	[request setPostValue:un forKey:@"un"];
	[request setPostValue:friendIdsString forKey:@"fids"];
	[request setPostValue:hash forKey:@"ck"];
	
	[request setDelegate:self];
	[request setDidFinishSelector: @selector(pushCompleted:)];
	[request setDidFailSelector: @selector(pushFailed:)];
	[queue addOperation:request];
}

- (void)pushCompleted:(ASIHTTPRequest *) request {
	NSString *result = request.responseString;
	NSLog(@"Response from push: %@", result);
	
}

- (void)pushFailed:(ASIHTTPRequest *) request {
	NSString *result = request.responseString;
	NSLog(@"Failure from push: %@", result);
}

- (void) togglePingsAndTwitter {
    if (isTwitterOn && isPingOn) {
        isTwitterOn = NO;
    } else if (isPingOn) {
        isPingOn = NO;
    } else {
        isTwitterOn = YES;
        isPingOn = YES;
    }
    [self setProperButtonStates];
}

- (void) setProperButtonStates {
    if (isTwitterOn && isPingOn) {
        NSLog(@"twitter and ping is on");
        [pingAndTwitterToggleButton setImage:[UIImage imageNamed:@"ping01b.png"] forState:UIControlStateNormal];
        [pingAndTwitterToggleButton setImage:[UIImage imageNamed:@"ping02b.png"] forState:UIControlStateHighlighted];
    } else if (isPingOn) {
        NSLog(@"ping is on");
        [pingAndTwitterToggleButton setImage:[UIImage imageNamed:@"ping03b.png"] forState:UIControlStateNormal];
        [pingAndTwitterToggleButton setImage:[UIImage imageNamed:@"ping04b.png"] forState:UIControlStateHighlighted];
    } else {
        NSLog(@"everything is off");
        [pingAndTwitterToggleButton setImage:[UIImage imageNamed:@"ping05b.png"] forState:UIControlStateNormal];
        [pingAndTwitterToggleButton setImage:[UIImage imageNamed:@"ping06b.png"] forState:UIControlStateHighlighted];
    }
}

- (void) doGeoAPICall {
    GAConnectionManager *connectionManager_ = [[[GAConnectionManager alloc] initWithAPIKey:@"K6afuuFTXK" delegate:self] autorelease];
    CLLocationCoordinate2D location = venue.location;

    [self startProgressBar:@"Searching for the venue..."];
    [connectionManager_ requestBusinessesNearCoords:location withinRadius:50 maxResults:30];
}

- (void) showSpecial {
    FSSpecial *special = ((FSSpecial*)[[self venue].specials objectAtIndex:0]);
    NSString *concat = special.venue.crossStreet ? [NSString stringWithFormat:@"%@\n%@", special.venue.addressWithCrossstreet, special.message] : special.message;
    KBMessage *msg = [[KBMessage alloc] initWithMember:special.venue.name andMessage:concat];
    [self displayPopupMessage:msg];
    [msg release];
}

- (FSCheckin*) getSingleCheckin {
    return (FSCheckin*) [self.checkin objectAtIndex:0];
}

- (BOOL) hasMayorCell {
    return [self isNewMayor] || ([self getSingleCheckin].mayor.user == nil && [[self getSingleCheckin].mayor.mayorTransitionType isEqualToString:@"nochange"]);
}

- (BOOL) isNewMayor {
    return [[self getSingleCheckin].mayor.mayorTransitionType isEqualToString:@"stolen"] || [[self getSingleCheckin].mayor.mayorTransitionType isEqualToString:@"new"];
}

- (void) viewVenueMap {

    closeMapButton.alpha = 0;
    closeMapButton.frame = CGRectMake(276, 146, 45, 45);
    fullMapView.alpha = 0;
    fullMapView.frame = CGRectMake(0, 141, 320, 320);
    [self.view addSubview:fullMapView];
    [self.view addSubview:closeMapButton];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    fullMapView.alpha = 1.0;
    closeMapButton.alpha = 1.0;
    
    [UIView commitAnimations];
    [[Beacon shared] startSubBeaconWithName:@"View Venue Map"];
}

- (void) addTipTodo {
    CreateTipTodoViewController *tipController = [[CreateTipTodoViewController alloc] initWithNibName:@"CreateTipTodoViewController" bundle:nil];
    tipController.venue = venue;
    [self presentModalViewController:tipController animated:YES];
    [tipController release];
}

- (void) markVenueWrongAddress {
    [[Beacon shared] startSubBeaconWithName:@"Wrong Address"];
    KBMessage *msg = [[KBMessage alloc] initWithMember:@"Sorry" andMessage:@"This functionality was not implemented in the Foursquare API. We will add it as soon as it is made available to us"];
    [self displayPopupMessage:msg];
    [msg release];
}

- (void) closeMap {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    fullMapView.alpha = 0.0;
    closeMapButton.alpha = 0.0;
    
    [UIView commitAnimations];
}

- (void) markVenueClosed {
    [self startProgressBar:@"Sending closure notification..."];
    [[FoursquareAPI sharedInstance] flagVenueAsClosed:venue.venueid withTarget:self andAction:@selector(okResponseReceived:withResponseString:)];
    [[Beacon shared] startSubBeaconWithName:@"Mark Venue Closed"];
}

- (void)okResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"flag venue closed response: %@", inString);
    
	BOOL isOK = [FoursquareAPI simpleBooleanFromResponseXML:inString];
    [self stopProgressBar];
    
    if (isOK) {
        KBMessage *msg = [[KBMessage alloc] initWithMember:@"Foursquare Notification" andMessage:@"Thank you for notifying Foursquare of the venue closure."];
        [self displayPopupMessage:msg];
        [msg release];
    }
}

#pragma mark GeoAPI Delegate methods

// TODO: neaten this mess up
- (void)receivedResponseString:(NSString *)responseString {
//    NSLog(@"geoapi response string: %@", responseString);
    SBJSON *parser = [[SBJSON new] autorelease];
    id dict = [parser objectWithString:responseString error:NULL];
    NSArray *array = [(NSDictionary*)dict objectForKey:@"entity"];
    NSMutableArray *objArray = [[NSMutableArray alloc] initWithCapacity:[array count]];
    bool isMatched = NO;
    for (NSDictionary *dict in array) {
        GAPlace *place = [[GAPlace alloc] init];
        place.guid = [dict objectForKey:@"guid"];
        place.name = [[dict objectForKey:@"view.listing"] objectForKey:@"name"];
        NSArray *tmp = [[dict objectForKey:@"view.listing"] objectForKey:@"address"];
        place.address = [NSString stringWithFormat:@"%@, %@, %@", [tmp objectAtIndex:0], [tmp objectAtIndex:1], [tmp objectAtIndex:2]];
        [objArray addObject:place];
        
        // TODO: we can reverse the below comparison, too. compare each result to the 4sq venue name
        // removing 'The' and all spaces from both words, then doing a string compare.  Should probably remove all non alphanumeric characters, too
        if ([[[place.name stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"The"]] stringByReplacingOccurrencesOfString:@" " withString:@""] 
               rangeOfString:[[venue.name stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"The"]] stringByReplacingOccurrencesOfString:@" " withString:@""] options:NSCaseInsensitiveSearch].location != NSNotFound) {
            GeoApiDetailsViewController *vc = [[GeoApiDetailsViewController alloc] initWithNibName:@"GeoApiDetailsView" bundle:nil];
            [[Beacon shared] startSubBeaconWithName:@"GeoAPI call found proper venue"];
            vc.place = place;
            [place release];
            isMatched = YES;
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
            break;
        } else { 
            // meh. not pretty.
            isMatched = NO;
            [place release];
        }
    }
    // if you don't avoid the next block, it still gets executed even if the above code pushes another view onto the navController, 
    // resulting in an extra view controller on the stack.
    if (!isMatched) {
        GeoApiTableViewController *vc = [[GeoApiTableViewController alloc] initWithNibName:@"GeoAPIView" bundle:nil];
        [[Beacon shared] startSubBeaconWithName:@"GeoAPI could not find proper venue - going to list view"];
        vc.geoAPIResults = objArray;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
        NSLog(@"dictionary?: %@", [(NSDictionary*)dict objectForKey:@"entity"]);   
    }
    [objArray release];
    [self stopProgressBar];
}

- (void)requestFailed:(NSError *)error {
    // TODO: probably want to pop up error message for user
    NSLog(@"geoapi error string: %@", error);
}

#pragma mark 
#pragma mark MapKit methods

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>) annotation{
	
    if (annotation == mapView.userLocation) {
        return nil;
    }
    
    int postag = 0;
    
	KBPin *annView=[[[KBPin alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomId"] autorelease];
	//annView.pinColor = MKPinAnnotationColorGreen;
    annView.image = [UIImage imageNamed:@"pin.png"];
    
    // add an accessory button so user can click through to the venue page
	UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
	myDetailButton.frame = CGRectMake(0, 0, 23, 23);
	myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	// Set the image for the button
	[myDetailButton setImage:[UIImage imageNamed:@"button_right.png"] forState:UIControlStateNormal];
	[myDetailButton addTarget:self action:@selector(showVenue:) forControlEvents:UIControlEventTouchUpInside]; 
	
    postag = [((VenueAnnotation*)annotation).venueId intValue];
	myDetailButton.tag  = postag;
	
	// Set the button as the callout view
	annView.rightCalloutAccessoryView = myDetailButton;
	
	//annView.animatesDrop=TRUE;
	annView.canShowCallout = YES;
	//annView.calloutOffset = CGPointMake(-5, 5);
	return annView;
}

#pragma mark Image Picker Delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // hide picker
    [picker dismissModalViewControllerAnimated:YES];
    
    // upload image
    // TODO: we'd have to confirm success to the user.
    //       we also need to send a notification to the gift recipient
    [self uploadImage:UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 1.0) filename:@"gift.jpg"];
}

#pragma mark
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self getPhoto:UIImagePickerControllerSourceTypePhotoLibrary];
    } else if (buttonIndex == 1) {
        [self getPhoto:UIImagePickerControllerSourceTypeCamera];
    }
}

#pragma mark -

- (void) choosePhotoSelectMethod {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"How would you like to select a photo?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Photo Album", @"Take New Photo", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (void) getPhoto:(UIImagePickerControllerSourceType)sourceType {
	UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    picker.sourceType = sourceType;
    [self presentModalViewController:picker animated:YES];
}

- (void) imageRequestDidFinish:(ASIHTTPRequest *) request {
    NSLog(@"YAY! Image uploaded!");
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Kickball Message" andMessage:@"Image upload has been completed!"];
    [self displayPopupMessage:message];
    [message release];
}

- (void) imageQueueDidFinish:(ASIHTTPRequest *) request {
    NSLog(@"YAY! Image queue is complete!");
}

- (void) imageRequestDidFail:(ASIHTTPRequest *) request {
    NSLog(@"Uhoh, it did fail!");
}

- (void) imageRequestWentWrong:(ASIHTTPRequest *) request {
    NSLog(@"Uhoh, request went wrong!");
}

// TODO: set max file size    
- (BOOL)uploadImage:(NSData *)imageData filename:(NSString *)filename{
    // Initilize Queue
    ASINetworkQueue *networkQueue = [[ASINetworkQueue alloc] init];
    //[networkQueue setUploadProgressDelegate:statusProgressView];
    [networkQueue setRequestDidFinishSelector:@selector(imageRequestDidFinish:)];
    [networkQueue setQueueDidFinishSelector:@selector(imageQueueDidFinish:)];
    [networkQueue setRequestDidFailSelector:@selector(imageRequestDidFail:)];
    [networkQueue setShowAccurateProgress:true];
    [networkQueue setDelegate:self];
    
    // Initilize Variables
    NSURL *url = nil;
    ASIFormDataRequest *request = nil;
    
    // Add Image
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"gift.jpg"];
    
    // Get Image
    //NSData *imageData = [[[NSData alloc] initWithContentsOfFile:dataPath] autorelease];
    
    // Return if there is no image
    if(imageData != nil){
        url = [NSURL URLWithString:@"http://kickball.gorlochs.com/kickball/gifts.xml"];
        request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
        [request setPostValue:venueId forKey:@"gift[venue_id]"];
        [request setPostValue:[self getAuthenticatedUser].userId forKey:@"gift[owner_id]"];
        //        [request setPostValue:@"" forKey:@"gift[recipient_id]"];
        [request setPostValue:@"1" forKey:@"gift[is_public]"];
        [request setPostValue:@"0" forKey:@"gift[is_banned]"];
        [request setPostValue:@"testing from the simulator (or device)" forKey:@"gift[message_text]"];
        [request setData:imageData withFileName:filename andContentType:@"image/jpeg" forKey:@"gift[photo]"];
        [request setDidFailSelector:@selector(imageRequestWentWrong:)];
        [request setTimeOutSeconds:500];
        [networkQueue addOperation:request];
        //queueCount++;
    }
    [networkQueue go];	
    return YES;
}

@end

