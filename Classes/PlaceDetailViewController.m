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
#import "KBPhotoViewController.h"
#import "KBLocationManager.h"
#import "KBStats.h"
#import "KickballAPI.h"
#import "BlackTableCellHeader.h"

static inline double radians (double degrees) {return degrees * M_PI/180;}

#define PHOTOS_PER_ROW 5
#define THUMBNAIL_IMAGE_SIZE 64

@interface PlaceDetailViewController (Private)

- (BOOL) uploadImage:(NSData *)imageData filename:(NSString *)filename;
- (void) venueResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;
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
@synthesize photoImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad {
    hideFooter = YES;
    pageType = KBPageTypeOther;
    pageViewType = KBPageViewTypeList;
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayTodoTipMessage:) name:@"todoTipSent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkinAndShoutToVenue:) name:@"shoutAndCheckinSent" object:nil];
    
    isUserCheckedIn = NO;
    
    venueDetailButton.hidden = YES;
    twitterButton.enabled = NO;
    
    giftCell.firstTimePhotoButton.hidden = YES;
    
    // this is to clear out the placeholder text, which is useful in IB
    venueName.text = @"";
    venueAddress.text = @"";
    distanceAndNumCheckinsLabel.text = @"";
    
    // pull this up into a method (or property)
    FSUser *tmpUser = [self getAuthenticatedUser];
    NSLog(@"auth'd user: %@", tmpUser);
    signedInUserIcon.imageView.image = [[Utilities sharedInstance] getCachedImage:tmpUser.photo];
    signedInUserIcon.hidden = NO;
    isPingOn = tmpUser.isPingOn;
    isTwitterOn = tmpUser.sendToTwitter && [self getAuthenticatedUser].twitter;
    isFacebookOn = tmpUser.sendToFacebook;
    [self setProperButtonStates];
    
    mayorCrown.hidden = YES;
    
    [self addHeaderAndFooter:theTableView];
    
    [self startProgressBar:@"Retrieving venue details..."];
    [[FoursquareAPI sharedInstance] getVenue:venueId withTarget:self andAction:@selector(venueResponseReceived:withResponseString:)];
    [[Beacon shared] startSubBeaconWithName:@"Venue Detail"];
    
    [self retrievePhotos];
}

- (void) retrievePhotos {
    // get gift info
    NSString *gorlochUrlString = [NSString stringWithFormat:@"%@/gifts/venue/%@.xml", kickballDomain, venueId];
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
    
    goodies = [[KickballAPI kickballApi] parsePhotosFromXML:[request responseString]];
    

    if ([goodies count] > 0) {
        giftCell.firstTimePhotoButton.hidden = YES;

        int i = 0;
        int x = 0;
        int y = 0;
        
        
        NSMutableArray *tempTTPhotoArray = [[NSMutableArray alloc] initWithCapacity:[goodies count]];
        for (KBGoody *goody in goodies) {
            NSLog(@"goody %d", i);
            NSString *caption = nil;
            if (goody.messageText != nil && ![goody.messageText isEqualToString:@"testing"]) {
                caption = [NSString stringWithFormat:@"%@ \n %@ @ %@ on %@", goody.messageText, goody.ownerName, goody.venueName, [[[KickballAPI kickballApi] photoDateFormatter] stringFromDate:goody.createdAt]];
            } else {
                caption = [NSString stringWithFormat:@"%@ @ %@ on %@", goody.ownerName, goody.venueName, [[[KickballAPI kickballApi] photoDateFormatter] stringFromDate:goody.createdAt]];
            }
            
            MockPhoto *photo = [[MockPhoto alloc] initWithURL:goody.largeImagePath smallURL:goody.mediumImagePath size:[goody largeImageSize] caption:caption];
            [tempTTPhotoArray addObject:photo];
            [photo release];
            
            CGRect frame = CGRectMake(x*THUMBNAIL_IMAGE_SIZE, y*THUMBNAIL_IMAGE_SIZE, THUMBNAIL_IMAGE_SIZE, THUMBNAIL_IMAGE_SIZE);
            TTImageView *ttImage = [[TTImageView alloc] initWithFrame:frame];
            ttImage.urlPath = goody.thumbnailImagePath;
            ttImage.clipsToBounds = YES;
            ttImage.contentMode = UIViewContentModeCenter;
            [giftCell addSubview:ttImage];
            
            UIButton *button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
            button.frame = frame;
            button.tag = i++;
            button.showsTouchWhenHighlighted = YES;
            [button addTarget:self action:@selector(displayImages:) forControlEvents:UIControlEventTouchUpInside]; 
            [giftCell addSubview:button];
            [button release];
            [ttImage release];
            x++;
            if (x%PHOTOS_PER_ROW == 0) {
                x = 0;
                y++;
            }
            if (i >= PHOTOS_PER_ROW) {
                break;
            }
        }
        [giftCell sendSubviewToBack:giftCell.bgImage];
        
        photoSource = [[MockPhotoSource alloc] initWithType:MockPhotoSourceNormal title:venue.name photos:tempTTPhotoArray photos2:nil];
        [tempTTPhotoArray release];
        giftCell.firstTimePhotoButton.hidden = YES;
        seeAllPhotosButton.hidden = NO;
        addPhotoButton.hidden = NO;
        photoHeaderLabel.hidden = NO;
    } else {
        giftCell.firstTimePhotoButton.hidden = NO;
        seeAllPhotosButton.hidden = YES;
        addPhotoButton.hidden = YES;
        photoHeaderLabel.hidden = YES;
    }
    [theTableView reloadData];
}

- (void) displayImages:(id)sender {
    int buttonPressedIndex = ((UIButton *)sender).tag;
    KBPhotoViewController *photoController = [[KBPhotoViewController alloc] initWithPhotoSource:photoSource];
    photoController.centerPhoto = [photoSource photoAtIndex:buttonPressedIndex];  // sets the photo displayer to the correct image
    photoController.goodies = goodies;
    [self.navigationController pushViewController:photoController animated:YES];
    [photoController release];
}

- (void) displayAllImages {
    [[Beacon shared] startSubBeaconWithName:@"View All Photos"];
    KBPhotoViewController *photoController = [[KBPhotoViewController alloc] initWithPhotoSource:photoSource];
    photoController.goodies = goodies;
    [self.navigationController pushViewController:photoController animated:YES];
    [photoController release];
}


- (void) displayTodoTipMessage:(NSNotification *)inNotification {
    KBMessage *msg = [[KBMessage alloc] initWithMember:@"Kickball Notification" andMessage:@"Your todo/tip was sent"];
    [self displayPopupMessage:msg];
    [msg release];
}

- (void)venueResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    //NSLog(@"instring for venue detail: %@", inString);
    NSString *errorMessage = [FoursquareAPI errorFromResponseXML:inString];
    [self stopProgressBar];
    if (errorMessage) {
        [self displayFoursquareErrorMessage:errorMessage];
    } else {
        NSLog(@"venue response string: %@", inString);
        self.venue = [FoursquareAPI venueFromResponseXML:inString];
        [self prepViewWithVenueInfo:self.venue];

        [theTableView reloadData];
        
        if (doCheckin) {
            [self checkinToVenue];
        }
        
        if (self.venue.specials != nil &&[self.venue.specials count] > 0) {
            specialsButton.hidden = NO;
        }
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
    // need to shift the pin location because the pin needs to be centered in the right box 
    // but the map extends underneath the mayor section of the table cell
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
    distanceAndNumCheckinsLabel.text = [NSString stringWithFormat:@"%dm Away, %d Check-ins Here", venueToDisplay.distanceFromUser, venueToDisplay.userCheckinCount];
    
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
    fullMapView = nil;
    badgeCell = nil;
    newMayorCell = nil;
    pointsCell = nil;
    stillTheMayorCell = nil;
    badgeImage = nil;
    //smallMapView = nil;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
    fullMapView = nil;
    badgeCell = nil;
    newMayorCell = nil;
    pointsCell = nil;
    stillTheMayorCell = nil;
    badgeImage = nil;
    smallMapView = nil;
    
    theTableView = nil;
    checkinCell = nil;
    giftCell = nil;
    mayorMapCell = nil;
    pointsCell = nil;
    badgeCell = nil;
    newMayorCell = nil;
    stillTheMayorCell = nil;
    bottomButtonCell = nil;
    detailButtonCell = nil;
    shoutCell = nil;
    
    mayorNameLabel = nil;
    mayorCheckinCountLabel = nil;
    badgeLabel = nil;
    badgeTitleLabel = nil;
    newMayorshipLabel = nil;
    stillTheMayorLabel = nil;
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
        return 0; // checkin buttons pulled out of table
        //return !isUserCheckedIn;
    } else if (section == 5) { // mayor & map cell
        return ![self isNewMayor];
    } else if (section == 6) { // gift
        return 1;
    } else if (section == 7) { // people here
        return [venue.currentCheckins count];
    } else if (section == 8) { // tips
        return [venue.tips count];
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
        return nil;
        //return checkinCell;
    } else if (indexPath.section == 5) {
        mayorMapCell.backgroundColor = [UIColor whiteColor];
        return mayorMapCell;
    } else if (indexPath.section == 6) {
        return giftCell;
    } else if (indexPath.section == 7) {
        if (indexPath.row < [venue.currentCheckins count]) {
            cell.detailTextLabel.numberOfLines = 1;
            cell.detailTextLabel.text = nil;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
            FSCheckin *currentCheckin = ((FSCheckin*)[venue.currentCheckins objectAtIndex:indexPath.row]);
            cell.textLabel.text = currentCheckin.user.firstnameLastInitial;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"blank_boy.png"];
            
            CGRect frame = CGRectMake(0,0,36,36);
            TTImageView *ttImage = [[[TTImageView alloc] initWithFrame:frame] autorelease];
            ttImage.urlPath = currentCheckin.user.photo;
            ttImage.backgroundColor = [UIColor clearColor];
            ttImage.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
            ttImage.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
            [cell.imageView addSubview:ttImage];
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
    if (indexPath.section != 5) {
        [cell setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];  
    }
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
        case 5: // mayor-map cell
            return 69;
        case 6: // photos
            if ([goodies count] == 0) {
                return 102;
            } else {
                return THUMBNAIL_IMAGE_SIZE;
            }
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
    if (section == 6) { // photos
        return 38;
    }
	return 30.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    BlackTableCellHeader *headerView = [[BlackTableCellHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    
    switch (section) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
            [headerView release];
            return nil;
            break;
        case 6:
            if ([goodies count] == 0) {
                [headerView release];
                return nil;
            } else {
                photoHeaderLabel.text = [NSString stringWithFormat:@"%d %@", [goodies count], [goodies count] == 1 ? @"Photo" : @"Photos"];
                return photoHeaderView;   
            }
            break;
        case 7:
            if (venue.hereNow == 0 ) {
                [headerView release];
                return nil;
            } else {
                headerView.leftHeaderLabel.text = [NSString stringWithFormat:@"%d %@ Here", venue.hereNow, venue.hereNow == 1 ? @"Person" : @"People"];
            }
            break;
        case 8:
            if ([venue.tips count] == 0) {
                [headerView release];
                return nil;
            } else {
                headerView.leftHeaderLabel.text = [NSString stringWithFormat:@"%d %@", [venue.tips count], [venue.tips count] == 1 ? @"Tip" : @"Tips"];
            }
            break;
        case 9:  
            [headerView release];
            return nil;
            break;
        default:
            headerView.leftHeaderLabel.text = @"You shouldn't see this";
            break;
    }
    return headerView;
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
    [self displayProperProfileView:profileUserId];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"todoTipSent"];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"shoutAndCheckinSent"];
    
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
    [photoSource release];
    
    [mayorOverlay release];
    [mayorCrown release];
    [mayorArrow release];
    [photoHeaderLabel release];
    [addPhotoButton release];
    [seeAllPhotosButton release];
    [photoHeaderView release];
    [photoImage release];
    
    [super dealloc];
}

#pragma mark IBAction methods

- (void) viewPhotos {
    KBPhotoViewController *photoController = [[KBPhotoViewController alloc] initWithPhotoSource:photoSource];
    //photoController.centerPhoto 
    [self.navigationController pushViewController:photoController animated:YES];
    [photoController release]; 
}

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
    [imagePickerController release];
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
                                                toFacebook:isPingOn ? isFacebookOn : NO
                                                withTarget:self 
                                                 andAction:@selector(checkinResponseReceived:withResponseString:)];
    [[Beacon shared] startSubBeaconWithName:@"Check in and shout to Venue"];
}

- (void) checkinToVenue {
    [self startProgressBar:@"Checking in to this venue..."];
    [[FoursquareAPI sharedInstance] doCheckinAtVenueWithId:venue.venueid 
                                                  andShout:nil 
                                                   offGrid:doCheckin ? NO : !isPingOn
                                                 toTwitter:isTwitterOn
                                                toFacebook:isPingOn ? isFacebookOn : NO
                                                withTarget:self 
                                                 andAction:@selector(checkinResponseReceived:withResponseString:)];
    [[Beacon shared] startSubBeaconWithName:@"Check in to Venue"];
}

- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSString *errorMessage = [FoursquareAPI errorFromResponseXML:inString];
    [self stopProgressBar];
    if (errorMessage) {
        [self displayFoursquareErrorMessage:errorMessage];
    } else {
        NSLog(@"instring: %@", inString);
        self.checkin = [FoursquareAPI checkinFromResponseXML:inString];
        NSLog(@"checkin: %@", checkin);
        isUserCheckedIn = YES;
        [theTableView reloadData];
        FSCheckin *ci = [self getSingleCheckin];
        [[KBStats stats] checkinStat:ci];
        if (ci.specials != nil) {
            specialsButton.hidden = NO;
        }
        
        NSMutableString *checkinText = [[NSMutableString alloc] initWithCapacity:1];
        for (FSScore *score in ci.scoring.scores) {
            [checkinText appendFormat:[NSString stringWithFormat:@"+%d %@ \n", score.points, score.message]];
        }
        if (checkinText == nil || [checkinText isEqualToString:@""]) {
            [checkinText appendString:ci.message];
        }
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Check-in successful" andMessage:checkinText];
        [self displayPopupMessage:message];
        [checkinText release];
        [message release];
        
        self.venueToPush = ci.venue;
        if (isPingOn) {
            [self sendPushNotification];
        }
    }
}

- (void) togglePingsAndTwitter {
    if (isTwitterOn && isPingOn) {
        isTwitterOn = NO;
    } else if (isPingOn) {
        isPingOn = NO;
    } else {
        isTwitterOn = YES && [self getAuthenticatedUser].twitter;
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
    [picker dismissModalViewControllerAnimated:NO];
    
    UIImage *initialImage = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
    float initialHeight = initialImage.size.height;
    float initialWidth = initialImage.size.width;
    
    float ratio = 1.0f;
    if (initialHeight > initialWidth) {
        ratio = initialHeight/initialWidth;
    } else {
        ratio = initialWidth/initialHeight;
    }
    NSString *roundedFloatString = [NSString stringWithFormat:@"%.1f", ratio];
    float roundedFloat = [roundedFloatString floatValue];
    
    self.photoImage = [self imageByScalingToSize:initialImage toSize:CGSizeMake(480.0, round(480.0/roundedFloat))];
    
    NSLog(@"image picker info: %@", info);
    
//    NSLog(@"image height: %f", photoImage.size.height);
//    NSLog(@"image width: %f", photoImage.size.width);
//    NSLog(@"image orientation: %d", photoImage.imageOrientation);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnFromMessageView:) name:@"attachMessageToPhoto" object:nil];
    
    photoMessageViewController = [[PhotoMessageViewController alloc] initWithNibName:@"PhotoMessageViewController" bundle:nil];
    [self.navigationController presentModalViewController:photoMessageViewController animated:YES];
    //[photoMessageViewController release];
}

- (void) returnFromMessageView:(NSNotification *)inNotification {
    NSString *message = [[inNotification userInfo] objectForKey:@"message"];
    self.photoMessageToPush = message;
    [photoMessageViewController dismissModalViewControllerAnimated:NO];
    [self startProgressBar:@"Uploading photo..." withTimer:NO];
    // TODO: we'd have to confirm success to the user.
    //       we also need to send a notification to the gift recipient
    [self uploadImage:UIImageJPEGRepresentation(self.photoImage, 1.0) 
             filename:@"gift.jpg" 
            withWidth:self.photoImage.size.width 
            andHeight:self.photoImage.size.height
           andMessage:message ? message : @""
       andOrientation:self.photoImage.imageOrientation];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"attachMessageToPhoto"];
}

#pragma mark
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[Beacon shared] startSubBeaconWithName:@"Choose Photo: Library"];
        [self getPhoto:UIImagePickerControllerSourceTypePhotoLibrary];
    } else if (buttonIndex == 1) {
        [[Beacon shared] startSubBeaconWithName:@"Choose Photo: New"];
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
    actionSheet.tag = 0;
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (void) getPhoto:(UIImagePickerControllerSourceType)sourceType {
	UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    picker.sourceType = sourceType;
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

- (void) imageRequestDidFinish:(ASIHTTPRequest *) request {
    [self stopProgressBar];
    NSLog(@"YAY! Image uploaded!");
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Kickball Message" andMessage:@"Image upload has been completed!"];
    [self displayPopupMessage:message];
    [message release];
    
    // NOTE: the self.photoMessageToPush is being set above in the returnFromMessageView: method
    self.venueToPush = self.venue;
    self.hasPhoto = YES;
    [self sendPushNotification];
    [[Beacon shared] startSubBeaconWithName:@"Image Upload Completed"];
}

- (void) imageQueueDidFinish:(ASIHTTPRequest *) request {
    [self stopProgressBar];
    NSLog(@"YAY! Image queue is complete!");
    
    // TODO: this should probably capture the response, parse it into a KBGoody, then add it to the goodies object - it would save an API hit
    
    [self retrievePhotos];
}

- (void) imageRequestDidFail:(ASIHTTPRequest *) request {
    [self stopProgressBar];
    NSLog(@"Uhoh, it did fail!");
}

- (void) imageRequestWentWrong:(ASIHTTPRequest *) request {
    [self stopProgressBar];
    NSLog(@"Uhoh, request went wrong!");
}

-(UIImage*)imageByScalingToSize:(UIImage*)image toSize:(CGSize)targetSize {
	UIImage* sourceImage = image; 
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
    
	CGImageRef imageRef = [sourceImage CGImage];
	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
	
	if (bitmapInfo == kCGImageAlphaNone) {
		bitmapInfo = kCGImageAlphaNoneSkipLast;
	}
	
	CGContextRef bitmap;
	
	if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
		bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
	} else {
		bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
	}	
	
	
	// In the right or left cases, we need to switch scaledWidth and scaledHeight,
	// and also the thumbnail point
	if (sourceImage.imageOrientation == UIImageOrientationLeft) {
		CGContextRotateCTM (bitmap, radians(90));
		CGContextTranslateCTM (bitmap, 0, -targetHeight);
		
	} else if (sourceImage.imageOrientation == UIImageOrientationRight) {
		CGContextRotateCTM (bitmap, radians(-90));
		CGContextTranslateCTM (bitmap, -targetWidth, 0);
		
	} else if (sourceImage.imageOrientation == UIImageOrientationUp) {
		// NOTHING
	} else if (sourceImage.imageOrientation == UIImageOrientationDown) {
		CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
		CGContextRotateCTM (bitmap, radians(-180.));
	}
	
	CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage* newImage = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);
	CGImageRelease(ref);
	
	return newImage; 
}

// TODO: set max file size    
- (BOOL)uploadImage:(NSData *)imageData filename:(NSString *)filename withWidth:(float)width andHeight:(float)height 
         andMessage:(NSString*)message andOrientation:(UIImageOrientation)orientation {
    
    NSNumber *tagKey = [NSNumber numberWithInteger:1];

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
    
    // Return if there is no image
    if(imageData != nil){
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/gifts.xml", kickballDomain]];
        request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
        [request setPostValue:venueId forKey:@"gift[venue_id]"];
        [request setPostValue:[self getAuthenticatedUser].userId forKey:@"gift[owner_id]"];
        //        [request setPostValue:@"" forKey:@"gift[recipient_id]"];
        [request setPostValue:@"1" forKey:@"gift[is_public]"];
        [request setPostValue:@"0" forKey:@"gift[is_banned]"];
        [request setPostValue:@"0" forKey:@"gift[is_flagged]"];
        [request setPostValue:venue.name forKey:@"gift[venue_name]"];
        [request setPostValue:[NSString stringWithFormat:@"%f", [[KBLocationManager locationManager] latitude]] forKey:@"gift[latitude]"];
        [request setPostValue:[NSString stringWithFormat:@"%f", [[KBLocationManager locationManager] longitude]] forKey:@"gift[longitude]"];
        [request setPostValue:[NSString stringWithFormat:@"%d", (int)height]  forKey:@"gift[photo_height]"];
        [request setPostValue:[NSString stringWithFormat:@"%d", (int)width] forKey:@"gift[photo_width]"];
        [request setPostValue:[self getAuthenticatedUser].firstnameLastInitial forKey:@"gift[owner_name]"];
        [request setPostValue:message ? message : @"" forKey:@"gift[message_text]"];
        [request setPostValue:[tagKey stringValue] forKey:@"gift[iphone_orientation]"];
        [request setData:imageData withFileName:filename andContentType:@"image/jpeg" forKey:@"gift[photo]"];
        [request setDidFailSelector:@selector(imageRequestWentWrong:)];
        [request setTimeOutSeconds:500];
        [networkQueue addOperation:request];
        //queueCount++;
    }
    [networkQueue go];
    
    [self uploadFacebookPhoto:imageData withCaption:message];
    return YES;
}

- (void) uploadFacebookPhoto:(NSData*)img withCaption:(NSString*)caption {
    NSDictionary *params = nil;
    if (caption) {
        params = [NSDictionary dictionaryWithObjectsAndKeys:caption, @"caption", nil];
    }
    [[FBRequest requestWithDelegate:self] call:@"facebook.photos.upload" params:params dataParam:(NSData*)img];
}

- (void)request:(FBRequest*)request didLoad:(id)result {
    if ([request.method isEqualToString:@"facebook.photos.upload"]) {
        NSDictionary* photoInfo = result;
        NSString* pid = [photoInfo objectForKey:@"pid"];
        NSLog(@"facebook photo uploaded: %@", photoInfo);
        NSLog(@"facebook photo uploaded. pid: %@", pid);
    }
}

@end

