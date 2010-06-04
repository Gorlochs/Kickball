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
#import "TipListViewController.h"
#import "KBCheckinModalViewController.h"
#import "PlacePeopleHereViewController.h"


#define PHOTOS_PER_ROW 4
#define THUMBNAIL_IMAGE_SIZE 73
#define MAX_NUM_TIPS_SHOWN 4
#define MAX_PEOPLE_HERE_SHOWN 4

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
    photoManager = [KBPhotoManager sharedInstance];
    photoManager.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayTodoTipMessage:) name:@"todoTipSent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentCheckinOverlay:) name:@"checkedIn" object:nil];
    
    isUserCheckedIn = NO;
    
    venueDetailButton.hidden = YES;
    twitterButton.enabled = NO;
    
    giftCell.firstTimePhotoButton.hidden = YES;
    
    // this is to clear out the placeholder text, which is useful in IB
    venueName.text = @"";
    venueAddress.text = @"";
    distanceAndNumCheckinsLabel.text = @"";
    smallMapView.layer.cornerRadius = 4;
    
    // pull this up into a method (or property)
    FSUser *tmpUser = [self getAuthenticatedUser];
    NSLog(@"auth'd user: %@", tmpUser);
    isPingOn = tmpUser.isPingOn;
    isTwitterOn = tmpUser.sendToTwitter && [self getAuthenticatedUser].twitter;
    isFacebookOn = tmpUser.sendToFacebook;
    [self setProperButtonStates];
    
    mayorCrown.hidden = YES;
    
    [self addHeaderAndFooter:theTableView];
    refreshHeaderView.backgroundColor = [UIColor blackColor];
    
    [self startProgressBar:@"Retrieving venue details..."];
    [[FoursquareAPI sharedInstance] getVenue:venueId withTarget:self andAction:@selector(venueResponseReceived:withResponseString:)];
    [FlurryAPI logEvent:@"Venue Detail"];
    
    [self retrievePhotos];
    [self showBackHomeButtons];
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
    
    goodies = [[[KickballAPI kickballApi] parsePhotosFromXML:[request responseString]] retain];
    

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
            ttImage.contentMode = UIViewContentModeScaleToFill;
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
    [FlurryAPI logEvent:@"View All Photos"];
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
            [self openCheckinView];
        }
        
        if (self.venue.specials != nil &&[self.venue.specials count] > 0) {
            specialsButton.hidden = NO;
        } else {
            specialsButton.hidden = YES;
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
    
//    double tmp = [[NSNumber numberWithDouble:location.longitude] doubleValue];
//    // need to shift the pin location because the pin needs to be centered in the right box 
//    // but the map extends underneath the mayor section of the table cell
//    CLLocationCoordinate2D shiftedLocation = {latitude: venueToDisplay.location.latitude , longitude: (CLLocationDegrees)(tmp - 0.0045) };
    
    fullRegion.span = fullSpan;
    fullRegion.center = location;
    region.span = span;
//    region.center = shiftedLocation;
    region.center = location;
    
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
    int distance = (int)[[KBLocationManager locationManager] distanceFromCoordinate:venueToDisplay.fullLocation];
    distanceAndNumCheckinsLabel.text = [NSString stringWithFormat:@"%d%@ Away, %d Check-ins Here", distance < 1000 ? distance : distance/1000, distance < 1000 ? @"m" : @"km", venueToDisplay.userCheckinCount];
    
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
        mayorArrow.hidden = NO;
        mayorCrown.hidden = NO;
    } else {
        noMayorImage.hidden = NO;
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
    badgeImage = nil;
    //smallMapView = nil;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
    fullMapView = nil;
    badgeImage = nil;
    smallMapView = nil;
    
    theTableView = nil;
    checkinCell = nil;
    giftCell = nil;
    mayorMapCell = nil;
    bottomButtonCell = nil;
    detailButtonCell = nil;
    
    mayorNameLabel = nil;
    mayorCheckinCountLabel = nil;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) { // checkin
        return 1; // checkin buttons pulled out of table
        //return !isUserCheckedIn;
    } else if (section == 1) { // mayor & map cell
        return ![self isNewMayor];
    } else if (section == 2) { // people here
        return [venue.currentCheckins count] <= MAX_PEOPLE_HERE_SHOWN ? [venue.currentCheckins count] : MAX_PEOPLE_HERE_SHOWN;
    } else if (section == 3) { // gift/photos
        //return [goodies count] > 0 ? 1 : 0;
        return 1;
    } else if (section == 4) { // venue buttons
        return 1;
    } else if (section == 5) { // tips
        //return [venue.tips count];
        return [venue.tips count] < MAX_NUM_TIPS_SHOWN ? [venue.tips count] : MAX_NUM_TIPS_SHOWN;
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
        //return nil;
        return checkinCell;
    } else if (indexPath.section == 1) {
        mayorMapCell.backgroundColor = [UIColor whiteColor];
        return mayorMapCell;
    } else if (indexPath.section == 2) { // people here
        if (indexPath.row <= MAX_PEOPLE_HERE_SHOWN) {
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
    } else if (indexPath.section == 3) {
        return giftCell;
    } else if (indexPath.section == 4) {
        return bottomButtonCell;
    } else if (indexPath.section == 5) {        
        FSTip *tip = (FSTip*) [venue.tips objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0];
        
        cell.detailTextLabel.numberOfLines = 2;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"blank_boy.png"];   
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        cell.textLabel.text = tip.submittedBy.firstnameLastInitial;
        cell.detailTextLabel.text = tip.text;
        
        CGRect frame = CGRectMake(0,0,36,36);
        TTImageView *ttImage = [[[TTImageView alloc] initWithFrame:frame] autorelease];
        ttImage.urlPath = tip.submittedBy.photo;
        ttImage.backgroundColor = [UIColor clearColor];
        ttImage.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
        ttImage.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
        [cell.imageView addSubview:ttImage];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 || indexPath.section > 3) {
        [cell setBackgroundColor:[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0]];  
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: // i'm here button
            return 54;
            break;
        case 1: // mayor-map cell
            return 69;
            break;
        case 2:
            return 44;
            break;
        case 3: // photos
//            if ([goodies count] == 0) {
//                return 102;
//            } else {
                return THUMBNAIL_IMAGE_SIZE;
//            }
            break;
        case 4:
            return 44;
        case 5:
            return 55;
        default:
            return 44;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if (section == 3) { // photos
//        return 40;
//    }
	return 30.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    BlackTableCellHeader *headerView = [[[BlackTableCellHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)] autorelease];
    
    switch (section) {
        case 0:
        case 1:
            return nil;
            break;
        case 2:
            if (venue.hereNow == 0 ) {
                return nil;
            } else {
                headerView.leftHeaderLabel.text = [NSString stringWithFormat:@"%d %@ Here", venue.hereNow, venue.hereNow == 1 ? @"Person" : @"People"];
                
                if (venue.hereNow > MAX_PEOPLE_HERE_SHOWN) {
                    UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    myDetailButton.frame = CGRectMake(210, 0, 92, 39);
                    myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                    myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                    [myDetailButton setImage:[UIImage imageNamed:@"placePeopleHere01.png"] forState:UIControlStateNormal];
                    [myDetailButton setImage:[UIImage imageNamed:@"placePeopleHere02.png"] forState:UIControlStateHighlighted];
                    [myDetailButton addTarget:self action:@selector(displayAllPeopleHere:) forControlEvents:UIControlEventTouchUpInside]; 
                    [headerView addSubview:myDetailButton];
                }
            }
            break;
        case 3: 
            if ([goodies count] == 0) {
                headerView.leftHeaderLabel.text = @"";
            } else {
                photoHeaderLabel.text = [NSString stringWithFormat:@"%d %@", [goodies count], [goodies count] == 1 ? @"Photo" : @"Photos"];
                return photoHeaderView;
            }
            break;
        case 4:
            return nil;
            break;
        case 5:
            if (YES) { // odd bug. you can't instantiate a new object as the first line in a case statement
                UIButton *addTipButton = [UIButton buttonWithType:UIButtonTypeCustom];
                addTipButton.frame = CGRectMake(130, 0, 92, 39);
                addTipButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                addTipButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                [addTipButton setImage:[UIImage imageNamed:@"addTip01_hdr.png"] forState:UIControlStateNormal];
                [addTipButton setImage:[UIImage imageNamed:@"addTip02_hdr.png"] forState:UIControlStateHighlighted];
                [addTipButton addTarget:self action:@selector(addTipTodo) forControlEvents:UIControlEventTouchUpInside]; 
                [headerView addSubview:addTipButton];
            }
            headerView.leftHeaderLabel.text = [NSString stringWithFormat:@"%d %@", [venue.tips count], [venue.tips count] == 1 ? @"Tip" : @"Tips"];
            
            if ([venue.tips count] > 4) {
                UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
                myDetailButton.frame = CGRectMake(210, 0, 92, 39);
                myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                [myDetailButton setImage:[UIImage imageNamed:@"profileSeeAllTips01.png"] forState:UIControlStateNormal];
                [myDetailButton setImage:[UIImage imageNamed:@"profileSeeAllTips02.png"] forState:UIControlStateHighlighted];
                [myDetailButton addTarget:self action:@selector(displayAllTips:) forControlEvents:UIControlEventTouchUpInside]; 
                [headerView addSubview:myDetailButton];
            }
            break;
        default:
            headerView.leftHeaderLabel.text = @"You shouldn't see this";
            break;
    }
    return headerView;
}

- (void) displayAllPeopleHere:(id)sender {
    PlacePeopleHereViewController *controller = [[PlacePeopleHereViewController alloc] initWithNibName:@"PlacePeopleHereViewController" bundle:nil];
    controller.checkedInUsers = venue.currentCheckins;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (void) displayAllTips:(id)sender {
    TipListViewController *tipListController = [[TipListViewController alloc] initWithNibName:@"TipListViewController" bundle:nil];
    tipListController.venue = venue;
    [self.navigationController pushViewController:tipListController animated:YES];
    [tipListController release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [self pushProfileDetailController:venue.mayor.userId];
    } else if (indexPath.section == 2) {
        FSCheckin *tmpCheckin = ((FSCheckin*)[venue.currentCheckins objectAtIndex:indexPath.row]);
        [self pushProfileDetailController:tmpCheckin.user.userId];
    } else if (indexPath.section == 5) {
        FSTip *tip = ((FSTip*)[venue.tips objectAtIndex:indexPath.row]);
        tipController = [[TipDetailViewController alloc] initWithNibName:@"TipView" bundle:nil];
        tipController.tip = tip;
        tipController.venue = venue;
        
        tipController.view.alpha = 0;
        
        [self.view addSubview:tipController.view];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.7];
        tipController.view.alpha = 1.0;        
        [UIView commitAnimations];
    }
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) pushProfileDetailController:(NSString*)profileUserId {
    [self displayProperProfileView:profileUserId];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"todoTipSent"];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"shoutAndCheckinSent"];
    
    [mayorMapCell release];
    [checkinCell release];
    [giftCell release];
    [bottomButtonCell release];
    [detailButtonCell release];
    [smallMapView release];
    [fullMapView release];
    
    [venueName release];
    [venueAddress release];
    [mayorNameLabel release];
    [mayorCheckinCountLabel release];
    
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
    
    [mayorCrown release];
    [mayorArrow release];
    [photoHeaderLabel release];
    [addPhotoButton release];
    [seeAllPhotosButton release];
    [photoHeaderView release];
    [photoImage release];
    
    [specialView release];
    [specialText release];
    [specialPlaceName release];
    [specialAddress release];
    [specialClose release];
    
    [tipController release];
    
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
    [FlurryAPI logEvent:@"call Venue"];
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

- (void) openCheckinView {
    KBCheckinModalViewController *vc = [[KBCheckinModalViewController alloc] initWithNibName:@"CheckinModalView" bundle:nil];
    vc.venue = venue;
    [self presentModalViewController:vc animated:YES];
    [vc release];
}
        
- (void) presentCheckinOverlay:(NSNotification*)inNotification {
    NSDictionary *dictionary = [inNotification userInfo];
    FSCheckin *ci = [dictionary objectForKey:@"checkin"];
    NSMutableString *checkinText = [[NSMutableString alloc] initWithCapacity:1];
    if (ci.mayor.user == nil && [ci.mayor.mayorTransitionType isEqualToString:@"nochange"]) {
        [checkinText appendFormat:[NSString stringWithFormat:@"You're still the mayor of %@! \n\n", venue.name]];
    } else if ([ci.mayor.mayorTransitionType isEqualToString:@"stolen"] || [ci.mayor.mayorTransitionType isEqualToString:@"new"]) {
        if ([[self getSingleCheckin].mayor.mayorTransitionType isEqualToString:@"stolen"]) {
            [checkinText appendFormat:[NSString stringWithFormat:@"Congrats! %@ is yours with %d check-ins and %@ lost their crown. \n\n", 
                                      ci.venue.name, 
                                      ci.mayor.numCheckins, 
                                      ci.mayor.user.firstnameLastInitial]];
        } else {
            [checkinText appendFormat:[NSString stringWithFormat:@"%@ \n\n", ci.mayor.mayorCheckinMessage]];
        }
    }
    for (FSBadge *badge in ci.badges) {
        [checkinText appendFormat:[NSString stringWithFormat:@"%@: %@ \n\n", badge.badgeName, badge.badgeDescription]];
    }
    [checkinText appendFormat:@"%@ \n\n", ci.message];
    for (FSScore *score in ci.scoring.scores) {
        [checkinText appendFormat:[NSString stringWithFormat:@"+%d %@ \n", score.points, score.message]];
    }
    NSLog(@"checkin text: %@", checkinText);
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Check-in successful" andMessage:checkinText];
    [self displayPopupMessage:message];
    [checkinText release];
    [message release];
    
    self.venueToPush = ci.venue;
    if (isPingOn) {
        [self sendPushNotification];
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

// http://developer.citysearch.com/docs/search/
- (void) doCityGridCall {
    NSString *cityGridUrl = [NSString stringWithFormat:@"http://api2.citysearch.com/search/locations?format=json&what=%@&lat=%f&lon=%f&radius=1&publisher=gorlochs&api_key=cpm3fbn4wf4ymf9hvjwuv47u",
                             [venue.name stringByReplacingOccurrencesOfString:@" " withString:@"+"],
                             venue.location.latitude,
                             venue.location.longitude];
    NSLog(@"city grid search url: %@", cityGridUrl);
    ASIHTTPRequest *cityGridRequest = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:cityGridUrl]] autorelease];
    
    [cityGridRequest setDidFailSelector:@selector(cityGridRequestWentWrong:)];
    [cityGridRequest setDidFinishSelector:@selector(cityGridRequestDidFinish:)];
    [cityGridRequest setTimeOutSeconds:500];
    [cityGridRequest setDelegate:self];
    [cityGridRequest startAsynchronous];
}

- (void) showSpecial {
    FSSpecial *special = ((FSSpecial*)[[self venue].specials objectAtIndex:0]);
    NSLog(@"specials: %@", [self venue].specials);
    NSLog(@"special: %@", special);
    specialPlaceName.text = special.venue.name;
    specialAddress.text = special.venue.addressWithCrossstreet;
    specialText.text = special.message;
    
    CGSize maximumLabelSize = CGSizeMake(246, 157);
    CGSize expectedLabelSize = [special.message sizeWithFont:specialText.font 
                                           constrainedToSize:maximumLabelSize 
                                               lineBreakMode:UILineBreakModeWordWrap]; 
    
    //adjust the label the the new height.
    CGRect newFrame = specialText.frame;
    newFrame.size.height = expectedLabelSize.height;
    specialText.frame = newFrame;

    CGRect specialFrame = specialView.frame;
    specialFrame.origin = CGPointMake(0, 119);
    specialView.frame = specialFrame;
    specialView.alpha = 0;
    [self.view addSubview:specialView];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.7];
    specialView.alpha = 1.0;
    [UIView commitAnimations];
}

- (void) closeSpecialView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.7];
    specialView.alpha = 0.0;
    [UIView commitAnimations];
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
    closeMapButton.frame = CGRectMake(276, 123, 45, 45);
    fullMapView.alpha = 0;
    fullMapView.frame = CGRectMake(0, 118, 320, 343);
    [self.view addSubview:fullMapView];
    [self.view addSubview:closeMapButton];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    fullMapView.alpha = 1.0;
    closeMapButton.alpha = 1.0;
    
    [UIView commitAnimations];
    [FlurryAPI logEvent:@"View Venue Map"];
}

- (void) addTipTodo {
    tipController = [[CreateTipTodoViewController alloc] initWithNibName:@"CreateTipTodoViewController" bundle:nil];
    tipController.venue = venue;
    [self presentModalViewController:tipController animated:YES];
    //[tipController release];
}

- (void) markVenueWrongAddress {
    [FlurryAPI logEvent:@"Wrong Address"];
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
    [FlurryAPI logEvent:@"Mark Venue Closed"];
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

#pragma mark CityGrid methods

- (void) cityGridRequestWentWrong:(ASIHTTPRequest *) request {
    NSLog(@"BOOOOOOOOOOOO!");
}

- (void) cityGridRequestDidFinish:(ASIHTTPRequest *) request {
    SBJSON *parser = [[SBJSON new] autorelease];
    NSLog(@"city grid response: %@", [request responseString]);
    id dict = [parser objectWithString:[request responseString] error:NULL];
    NSArray *array = (NSArray*)[[dict objectForKey:@"jsonResponse"] objectForKey:@"results"];
    NSLog(@"array of results: %@", array);
    NSMutableArray *objArray = [[NSMutableArray alloc] initWithCapacity:[array count]];
    bool isMatched = NO;
    for (NSDictionary *dict in array) {
        GAPlace *place = [[GAPlace alloc] init];
        NSLog(@"location: %@", [dict objectForKey:@"location"]);
        place.guid = [[dict objectForKey:@"location"] objectForKey:@"id"];
        place.name = [[dict objectForKey:@"location"] objectForKey:@"name"];
        NSDictionary *tmp = [[dict objectForKey:@"location"] objectForKey:@"address"];
        place.address = [NSString stringWithFormat:@"%@, %@, %@", [tmp objectForKey:@"street"], [tmp objectForKey:@"city"], [tmp objectForKey:@"state"]];
        [objArray addObject:place];
        
        // TODO: we can reverse the below comparison, too. compare each result to the 4sq venue name
        // removing 'The' and all spaces from both words, then doing a string compare.  Should probably remove all non alphanumeric characters, too
        if ([[[place.name stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"The"]] stringByReplacingOccurrencesOfString:@" " withString:@""] 
             rangeOfString:[[venue.name stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"The"]] stringByReplacingOccurrencesOfString:@" " withString:@""] options:NSCaseInsensitiveSearch].location != NSNotFound) {
            GeoApiDetailsViewController *vc = [[GeoApiDetailsViewController alloc] initWithNibName:@"GeoApiDetailsView" bundle:nil];
            [FlurryAPI logEvent:@"GeoAPI call found proper venue"];
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
        [FlurryAPI logEvent:@"GeoAPI could not find proper venue - going to list view"];
        vc.geoAPIResults = objArray;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
        NSLog(@"dictionary?: %@", [(NSDictionary*)dict objectForKey:@"entity"]);   
    }
    [objArray release];
    [self stopProgressBar];
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
            [FlurryAPI logEvent:@"GeoAPI call found proper venue"];
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
        [FlurryAPI logEvent:@"GeoAPI could not find proper venue - going to list view"];
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
    
    self.photoImage = [photoManager imageByScalingToSize:initialImage toSize:CGSizeMake(480.0, round(480.0/roundedFloat))];
    
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
    [photoManager uploadImage:UIImageJPEGRepresentation(self.photoImage, 1.0) 
             filename:@"gift.jpg" 
            withWidth:self.photoImage.size.width 
            andHeight:self.photoImage.size.height
           andMessage:message ? message : @""
       andOrientation:self.photoImage.imageOrientation
             andVenue:venue];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"attachMessageToPhoto"];
}

#pragma mark
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [FlurryAPI logEvent:@"Choose Photo: Library"];
        [self getPhoto:UIImagePickerControllerSourceTypePhotoLibrary];
    } else if (buttonIndex == 1) {
        [FlurryAPI logEvent:@"Choose Photo: New"];
        [self getPhoto:UIImagePickerControllerSourceTypeCamera];
    }
}

#pragma mark -

- (void) getPhoto:(UIImagePickerControllerSourceType)sourceType {
	UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    picker.sourceType = sourceType;
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

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

- (void) photoUploadFinished:(ASIHTTPRequest *) request {
    [self stopProgressBar];
    NSLog(@"YAY! Image uploaded!");
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Kickball Message" andMessage:@"Image upload has been completed!"];
    [self displayPopupMessage:message];
    [message release];
    
    // NOTE: the self.photoMessageToPush is being set above in the returnFromMessageView: method
    self.venueToPush = self.venue;
    self.hasPhoto = YES;
    //[self sendPushNotification];
    [FlurryAPI logEvent:@"Image Upload Completed"];
}

- (void) photoQueueFinished:(ASIHTTPRequest *) request {
    [self stopProgressBar];
    NSLog(@"YAY! Image queue is complete!");
    
    // TODO: this should probably capture the response, parse it into a KBGoody, then add it to the goodies object - it would save an API hit
    
    [self retrievePhotos];
}

- (void) photoUploadFailed:(ASIHTTPRequest *) request {
    [self stopProgressBar];
    NSLog(@"Uhoh, it did fail!");
}

#pragma mark 
#pragma mark table refresh methods

- (void) refreshTable {
    [[FoursquareAPI sharedInstance] getVenue:venueId withTarget:self andAction:@selector(venueResponseReceivedWithRefresh:withResponseString:)];
}

- (void)venueResponseReceivedWithRefresh:(NSURL *)inURL withResponseString:(NSString *)inString {
    [self venueResponseReceived:inURL withResponseString:inString];
	[self dataSourceDidFinishLoadingNewData];
}

@end

