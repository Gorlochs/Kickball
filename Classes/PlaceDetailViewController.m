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
#import "PlacePeopleHereViewController.h"
#import "KBThumbnailViewController.h"

#define PHOTOS_PER_ROW 4
#define THUMBNAIL_IMAGE_SIZE 73
#define MAX_NUM_TIPS_SHOWN 4
#define MAX_PEOPLE_HERE_SHOWN 4

@interface PlaceDetailViewController (Private)

- (BOOL) uploadImage:(NSData *)imageData filename:(NSString *)filename;
- (void) venueResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;
- (void) prepViewWithVenueInfo:(FSVenue*)venueToDisplay;
- (void) pushProfileDetailController:(NSString*)profileUserId;
- (void) presentCheckinOverlayWithCheckin:(FSCheckin*)aCheckin;

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
    
    [super viewDidLoad];
    photoManager = [KBPhotoManager sharedInstance];
    photoManager.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayTodoTipMessage:) name:@"todoTipSent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentCheckinOverlay:) name:@"checkedIn" object:nil];
    
    isUserCheckedIn = NO;
    
    venueDetailButton.hidden = YES;
    twitterButton.enabled = NO;
    
	
	specialText.font = [UIFont systemFontOfSize:14.0];
	specialText.textColor = [UIColor colorWithRed:0.0 green:86.0/255.0 blue:136.0/255.0 alpha:1.0];
    
    // this is to clear out the placeholder text, which is useful in IB
    venueName.text = @"";
    venueAddress.text = @"";
    distanceAndNumCheckinsLabel.text = @"";
    smallMapView.layer.cornerRadius = 4;
    
    // pull this up into a method (or property)
    FSUser *tmpUser = [self getAuthenticatedUser];
    DLog(@"auth'd user: %@", tmpUser);
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
	
    pageType = KBPageTypePlaces;
    pageViewType = KBPageViewTypeList;
    [self setProperFoursquareButtons];
}

- (void) retrievePhotos {
    // get gift info
    NSString *gorlochUrlString = [NSString stringWithFormat:@"%@/gifts/venue/%@.xml", kickballDomain, venueId];
    DLog(@"url: %@", gorlochUrlString);
    ASIHTTPRequest *gorlochRequest = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:gorlochUrlString]] autorelease];
            
    [gorlochRequest setDidFailSelector:@selector(venueRequestWentWrong:)];
    [gorlochRequest setDidFinishSelector:@selector(venueRequestDidFinish:)];
    [gorlochRequest setTimeOutSeconds:500];
    [gorlochRequest setDelegate:self];
    [gorlochRequest startAsynchronous];
}


- (void) venueRequestWentWrong:(ASIHTTPRequest *) request {
    DLog(@"BOOOOOOOOOOOO!");
}

- (void) venueRequestDidFinish:(ASIHTTPRequest *) request {
    
    goodies = [[[KickballAPI kickballApi] parsePhotosFromXML:[request responseString]] retain];
    

    if ([goodies count] > 0) {

        int i = 0;
        int x = 0;
        int y = 0;
        
        NSMutableArray *tempTTPhotoArray = [[NSMutableArray alloc] initWithCapacity:[goodies count]];
        for (KBGoody *goody in goodies) {
            DLog(@"goody %d", i);
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
        seeAllPhotosButton.hidden = NO;
        addPhotoButton.hidden = NO;
        photoHeaderLabel.hidden = NO;
    } else {
        //seeAllPhotosButton.hidden = YES;
        //addPhotoButton.hidden = YES;
        //photoHeaderLabel.hidden = YES;
    }
    [theTableView reloadData];
}

- (void) displayImages:(id)sender {
    int buttonPressedIndex = ((UIButton *)sender).tag;
    MockPhotoSource *thePhotoSource = [[KickballAPI kickballApi] convertGoodiesIntoPhotoSource:goodies withTitle:venue.name];
    KBPhotoViewController *photoController = [[KBPhotoViewController alloc] initWithPhotoSource:thePhotoSource];
    photoController.centerPhoto = [thePhotoSource photoAtIndex:buttonPressedIndex];  // sets the photo displayer to the correct image
    photoController.goodies = goodies;
    [self.navigationController pushViewController:photoController animated:YES];
    [photoController release];
}

//- (void) displayAllImages {
//    [FlurryAPI logEvent:@"View All Photos"];
//    MockPhotoSource *thePhotoSource = [[KickballAPI kickballApi] convertGoodiesIntoPhotoSource:goodies withTitle:venue.name];
//    KBPhotoViewController *photoController = [[KBPhotoViewController alloc] initWithPhotoSource:thePhotoSource];
//    photoController.goodies = goodies;
//    [self.navigationController pushViewController:photoController animated:YES];
//    [photoController release];
//}

- (void) displayTodoTipMessage:(NSNotification *)inNotification {
    KBMessage *msg = [[KBMessage alloc] initWithMember:@"Kickball Notification" andMessage:@"Your todo/tip was sent"];
    [self displayPopupMessage:msg];
    [msg release];
}

- (void)venueResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    //DLog(@"instring for venue detail: %@", inString);
    NSString *errorMessage = [FoursquareAPI errorFromResponseXML:inString];
    [self stopProgressBar];
    if (errorMessage) {
        [self displayFoursquareErrorMessage:errorMessage];
    } else {
        DLog(@"venue response string: %@", inString);
        self.venue = [FoursquareAPI venueFromResponseXML:inString];
        [self prepViewWithVenueInfo:self.venue];
		imHereButton.enabled = YES;

        [theTableView reloadData];
        
        if (self.venue.specials != nil &&[self.venue.specials count] > 0) {
            specialsButton.hidden = NO;
        } else {
            specialsButton.hidden = YES;
        }
		
        if (doCheckin) {
			[self startProgressBar:@"Checking into this venue..."];
			[[FoursquareAPI sharedInstance] doCheckinAtVenueWithId:venue.venueid 
														  andShout:@""
														   offGrid:NO
														withTarget:self 
														 andAction:@selector(checkinResponseReceived:withResponseString:)];
        }
    }
}

- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    DLog(@"instring: %@", inString);
    FSCheckin *theCheckin = [[FoursquareAPI checkinFromResponseXML:inString] retain];
	[self stopProgressBar];
	
	// it was either this or pull out the 
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:theCheckin, nil] 
                                                         forKeys:[NSArray arrayWithObjects:@"checkin", nil]];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"checkedIn" object:self userInfo:userInfo];
    
	self.venueToPush = theCheckin.venue;
	[theCheckin release];
    if ([self getAuthenticatedUser].isPingOn) {
        [self sendPushNotification];
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
	
	if ([venueToDisplay.currentCheckins count] > 0) {

		//create base container based on how many people
		UIView *roundedRect;
		UIView *peopleHereContainer;
		peopleHereCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"peopleHere"];
		switch ([venueToDisplay.currentCheckins count]) {
			case 1:
			case 2:
				peopleHereContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
				[peopleHereContainer setBackgroundColor:[UIColor clearColor]];
				roundedRect = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 47)];
				[[roundedRect layer] setCornerRadius:3.0f];
				[roundedRect setBackgroundColor:[UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0]];  
				[peopleHereContainer addSubview:roundedRect];
				[roundedRect release];
				break;
			default:
				peopleHereContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 107)];
				roundedRect = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 95)];
				[[roundedRect layer] setCornerRadius:3.0f];
				[roundedRect setBackgroundColor:[UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0]];  
				[peopleHereContainer addSubview:roundedRect];
				[roundedRect release];
				break;
		}
		UIView *horizontalSplitter;
		UIView *verticalSplitter;
		FSCheckin *currentCheckin;
		currentCheckin = nil;
		switch ([venueToDisplay.currentCheckins count]) {
			case 1:
				
				//populate with poeople
				//person 1
				currentCheckin = ((FSCheckin*)[venueToDisplay.currentCheckins objectAtIndex:0]);
				[self addPersonHere:peopleHereContainer :currentCheckin :1];
				break;
			case 2:
				horizontalSplitter = [[UIView alloc] initWithFrame:CGRectMake(145, 0, 1, 47)];
				[horizontalSplitter setBackgroundColor:[UIColor grayColor]];
				[peopleHereContainer addSubview:horizontalSplitter];
				[horizontalSplitter release];
				
				//populate with poeople
				//person 1
				currentCheckin = ((FSCheckin*)[venueToDisplay.currentCheckins objectAtIndex:0]);
				[self addPersonHere:peopleHereContainer :currentCheckin :21];
				
				//person 2
				currentCheckin = ((FSCheckin*)[venueToDisplay.currentCheckins objectAtIndex:1]);
				[self addPersonHere:peopleHereContainer :currentCheckin :22];
				break;
			case 3:
				horizontalSplitter = [[UIView alloc] initWithFrame:CGRectMake(145, 0, 1, 48)];
				[horizontalSplitter setBackgroundColor:[UIColor grayColor]];
				[peopleHereContainer addSubview:horizontalSplitter];
				[horizontalSplitter release];
				verticalSplitter = [[UIView alloc] initWithFrame:CGRectMake(0, 48, 290, 1)];
				[verticalSplitter setBackgroundColor:[UIColor grayColor]];
				[peopleHereContainer addSubview:verticalSplitter];
				[verticalSplitter release];
				
				//populate with poeople
				//person 1
				currentCheckin = ((FSCheckin*)[venueToDisplay.currentCheckins objectAtIndex:0]);
				[self addPersonHere:peopleHereContainer :currentCheckin :21];
				
				//person 2
				currentCheckin = ((FSCheckin*)[venueToDisplay.currentCheckins objectAtIndex:1]);
				[self addPersonHere:peopleHereContainer :currentCheckin :22];
				
				//person 3
				currentCheckin = ((FSCheckin*)[venueToDisplay.currentCheckins objectAtIndex:2]);
				[self addPersonHere:peopleHereContainer :currentCheckin :3];
				break;
			default:
				horizontalSplitter = [[UIView alloc] initWithFrame:CGRectMake(145, 0, 1, 95)];
				[horizontalSplitter setBackgroundColor:[UIColor grayColor]];
				[peopleHereContainer addSubview:horizontalSplitter];
				[horizontalSplitter release];
				verticalSplitter = [[UIView alloc] initWithFrame:CGRectMake(0, 48, 290, 1)];
				[verticalSplitter setBackgroundColor:[UIColor grayColor]];
				[peopleHereContainer addSubview:verticalSplitter];
				[verticalSplitter release];
				
				//populate with poeople
				//person 1
				currentCheckin = ((FSCheckin*)[venueToDisplay.currentCheckins objectAtIndex:0]);
				[self addPersonHere:peopleHereContainer :currentCheckin :21];
				
				//person 2
				currentCheckin = ((FSCheckin*)[venueToDisplay.currentCheckins objectAtIndex:1]);
				[self addPersonHere:peopleHereContainer :currentCheckin :22];
				
				//person 3
				currentCheckin = ((FSCheckin*)[venueToDisplay.currentCheckins objectAtIndex:2]);
				[self addPersonHere:peopleHereContainer :currentCheckin :23];
				
				//person 4
				currentCheckin = ((FSCheckin*)[venueToDisplay.currentCheckins objectAtIndex:3]);
				[self addPersonHere:peopleHereContainer :currentCheckin :24];
				
				break;
		}
		[peopleHereCell.contentView setBackgroundColor:[UIColor blackColor]];
		[peopleHereCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
		[peopleHereCell.contentView addSubview:peopleHereContainer];
		[peopleHereContainer release];
	}
}

-(void)addPersonHere:(UIView*)container :(FSCheckin*)person :(int)position {
	CGRect headRect,nameRect,accessoryRect,touchRect;
	int personTag;	
	switch (position) {
		case 1:
			nameRect = CGRectMake(48, 8, 75, 30);
			headRect = CGRectMake(8, 8, 32, 32);
			personTag = 1;
			touchRect = CGRectMake(0, 0, 290, 47);
			accessoryRect = CGRectMake(270, 17, 9, 12);
			break;
		case 3:
			nameRect = CGRectMake(48, 55, 75, 30);
			headRect = CGRectMake(8, 55, 32, 32);
			personTag = 3;
			touchRect = CGRectMake(0, 48, 290, 47);
			accessoryRect = CGRectMake(270, 64, 9, 12);
			break;
		case 21:
			nameRect = CGRectMake(48, 8, 75, 30);
			headRect = CGRectMake(8, 8, 32, 32);
			personTag = 1;
			touchRect = CGRectMake(0, 0, 145, 47);
			accessoryRect = CGRectMake(125, 17, 9, 12);
			break;
		case 22:
			nameRect = CGRectMake(192, 8, 75, 30);
			headRect = CGRectMake(152, 8, 32, 32);
			personTag = 2;
			touchRect = CGRectMake(148, 0, 145, 47);
			accessoryRect = CGRectMake(270, 17, 9, 12);
			break;
		case 23:
			nameRect = CGRectMake(48, 55, 75, 30);
			headRect = CGRectMake(8, 55, 32, 32);
			personTag = 3;
			touchRect = CGRectMake(0, 48, 145, 47);
			accessoryRect = CGRectMake(125, 64, 9, 12);
			break;
		default:
			nameRect = CGRectMake(192, 55, 75, 30);
			headRect = CGRectMake(152, 55, 32, 32);
			personTag = 4;
			touchRect = CGRectMake(148, 48, 145, 47);
			accessoryRect = CGRectMake(270, 64, 9, 12);
			break;
	}
	UILabel *hereName = [[UILabel alloc] initWithFrame:nameRect];
	[hereName setBackgroundColor:[UIColor clearColor]];
	[hereName setFont:[UIFont boldSystemFontOfSize:15]];
	[hereName setTextColor:[UIColor blackColor]];
	[hereName setText:person.user.firstnameLastInitial]; 
	[container addSubview:hereName];
	[hereName release];
	hereName = nil;
	TTImageView *hereHead = [[TTImageView alloc] initWithFrame:headRect];
	hereHead.urlPath = person.user.photo;
	hereHead.backgroundColor = [UIColor clearColor];
	hereHead.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
	hereHead.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
	[container addSubview:hereHead];
	[hereHead release];
	hereHead = nil;
	UIImageView *accessory = [[UIImageView alloc] initWithFrame:accessoryRect];
	[accessory setImage:[UIImage imageNamed:@"cellArrow.png"]];
	[container addSubview:accessory];
	[accessory release];
	UIButton *touchMe = [UIButton buttonWithType:UIButtonTypeCustom];
	[touchMe setFrame:touchRect];
	[touchMe setAdjustsImageWhenHighlighted:YES];
	[touchMe addTarget:self action:@selector(touchedPersonHere:) forControlEvents:UIControlEventTouchUpInside];
	[touchMe setTag:personTag];
	[container addSubview:touchMe];
	
}
-(void)touchedPersonHere:(id)sender {
	FSCheckin *tmpCheckin = ((FSCheckin*)[venue.currentCheckins objectAtIndex:[sender tag]-1]);
	[self pushProfileDetailController:tmpCheckin.user.userId];
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
		//**previous*** return [venue.currentCheckins count] <= MAX_PEOPLE_HERE_SHOWN ? [venue.currentCheckins count] : MAX_PEOPLE_HERE_SHOWN;
        return [venue.currentCheckins count] > 0 ? 1 : 0;
    } else if (section == 3) { // gift/photos
        return [goodies count] > 0 ? 1 : 0;
        //return 1;
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
        return mayorMapCell;
    } else if (indexPath.section == 2) { // people here
		return peopleHereCell;
    } else if (indexPath.section == 3) {
		UIImageView *roundedTopCorners = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"roundedTop.png"]];
		roundedTopCorners.frame = CGRectMake(0, 0, roundedTopCorners.frame.size.width, roundedTopCorners.frame.size.height);
		[giftCell addSubview:roundedTopCorners];
		
		UIImageView *roundedBottomCorners = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"roundedBottom.png"]];
		roundedBottomCorners.frame = CGRectMake(0, giftCell.frame.size.height - 3, roundedBottomCorners.frame.size.width, roundedBottomCorners.frame.size.height);
		[giftCell addSubview:roundedBottomCorners];
		[giftCell bringSubviewToFront:roundedTopCorners];
		[giftCell bringSubviewToFront:roundedBottomCorners];
		
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
	if (indexPath.row == 0) {
		UIImageView *roundedTopCorners = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"roundedTop.png"]];
		roundedTopCorners.frame = CGRectMake(0, 0, roundedTopCorners.frame.size.width, roundedTopCorners.frame.size.height);
		[cell addSubview:roundedTopCorners];
		[cell bringSubviewToFront:roundedTopCorners];
	}
	if (indexPath.row == [theTableView numberOfRowsInSection:indexPath.section] - 1 && indexPath.section == 5) {
		UIImageView *roundedBottomCorners = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"roundedBottom.png"]];
		roundedBottomCorners.frame = CGRectMake(0, 52, roundedBottomCorners.frame.size.width, roundedBottomCorners.frame.size.height);
		[cell addSubview:roundedBottomCorners];
		[cell bringSubviewToFront:roundedBottomCorners];
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 || indexPath.section > 3) {
        [cell setBackgroundColor:[UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0]];  
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
        case 2: //people here
			if ([venue.currentCheckins count]<=2) {
				return 60;
			}else {
				return 107;
			}
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
	return 39.0;  //changed to 39 since all the 'view all' buttons are 39
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    BlackTableCellHeader *tableCellHeader = [[[BlackTableCellHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)] autorelease];
    
    switch (section) {
        case 0:
        case 1:
            return nil;
            break;
        case 2:
            if (venue.hereNow == 0 ) {
                return nil;
            } else {
                tableCellHeader.leftHeaderLabel.text = [NSString stringWithFormat:@"%d %@ Here", venue.hereNow, venue.hereNow == 1 ? @"Person" : @"People"];
                
                if (venue.hereNow > MAX_PEOPLE_HERE_SHOWN) {
                    UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    myDetailButton.frame = CGRectMake(210, 0, 92, 39);
                    myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                    myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                    [myDetailButton setImage:[UIImage imageNamed:@"placePeopleHere01.png"] forState:UIControlStateNormal];
                    [myDetailButton setImage:[UIImage imageNamed:@"placePeopleHere02.png"] forState:UIControlStateHighlighted];
                    [myDetailButton addTarget:self action:@selector(displayAllPeopleHere:) forControlEvents:UIControlEventTouchUpInside]; 
                    [tableCellHeader addSubview:myDetailButton];
                }
            }
            break;
        case 3: 
            if ([goodies count] == 0) {
                //tableCellHeader.leftHeaderLabel.text = @"";
				seeAllPhotosButton.hidden = YES;
				CGRect frame = addPhotoButton.frame;
				frame.origin = CGPointMake(230, addPhotoButton.frame.origin.y);
				addPhotoButton.frame = frame;
			}
//            } else {
                photoHeaderLabel.text = [NSString stringWithFormat:@"%d %@", [goodies count], [goodies count] == 1 ? @"Photo" : @"Photos"];
                return photoHeaderView;
//            }
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
                [tableCellHeader addSubview:addTipButton];
				tableCellHeader.leftHeaderLabel.text = [NSString stringWithFormat:@"%d %@", [venue.tips count], [venue.tips count] == 1 ? @"Tip" : @"Tips"];
				
				if ([venue.tips count] > 4) {
					UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
					myDetailButton.frame = CGRectMake(210, 0, 92, 39);
					myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
					myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
					[myDetailButton setImage:[UIImage imageNamed:@"profileSeeAllTips01.png"] forState:UIControlStateNormal];
					[myDetailButton setImage:[UIImage imageNamed:@"profileSeeAllTips02.png"] forState:UIControlStateHighlighted];
					[myDetailButton addTarget:self action:@selector(displayAllTips:) forControlEvents:UIControlEventTouchUpInside]; 
					[tableCellHeader addSubview:myDetailButton];
				} else {
					CGRect frame = addTipButton.frame;
					frame.origin = CGPointMake(213, addTipButton.frame.origin.y);
					addTipButton.frame = frame;
				}
            }
            break;
        default:
            tableCellHeader.leftHeaderLabel.text = @"You shouldn't see this";
            break;
    }
    return tableCellHeader;
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
        //FSCheckin *tmpCheckin = ((FSCheckin*)[venue.currentCheckins objectAtIndex:indexPath.row]);
        //[self pushProfileDetailController:tmpCheckin.user.userId];
		[theTableView deselectRowAtIndexPath:indexPath animated:NO];
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
	[imHereButton release];
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
    [checkinViewController release];
	
	[peopleHereCell release];
    
    [super dealloc];
}

#pragma mark IBAction methods

//- (void) viewPhotos {
//    MockPhotoSource *thePhotoSource = [[KickballAPI kickballApi] convertGoodiesIntoPhotoSource:goodies withTitle:venue.name];
//    KBPhotoViewController *photoController = [[KBPhotoViewController alloc] initWithPhotoSource:thePhotoSource];
//    [self.navigationController pushViewController:photoController animated:YES];
//    [photoController release]; 
//}

- (void) viewThumbnails {
    MockPhotoSource *thePhotoSource = [[KickballAPI kickballApi] convertGoodiesIntoPhotoSource:goodies withTitle:venue.name];
	KBThumbnailViewController *thumbsController = [[KBThumbnailViewController alloc] init];
    DLog(@"photosource: %@", thePhotoSource);
	thumbsController.title = venue.name;
	thumbsController.photoSource = thePhotoSource;
    thumbsController.navigationBarStyle = UIBarStyleBlackOpaque;
    thumbsController.statusBarStyle = UIStatusBarStyleBlackOpaque;
    [self.navigationController pushViewController:thumbsController animated:YES];
    [thumbsController release]; 
}

- (void) callVenue {
    DLog(@"phone number to call: %@", [NSString stringWithFormat:@"tel:%@", venue.phone]);
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
    checkinViewController = [[KBCheckinModalViewController alloc] initWithNibName:@"CheckinModalView" bundle:nil];
    checkinViewController.venue = venue;
    [self presentModalViewController:checkinViewController animated:YES];
}
        
- (void) presentCheckinOverlay:(NSNotification*)inNotification {
    NSDictionary *dictionary = [inNotification userInfo];
	[self presentCheckinOverlayWithCheckin:[dictionary objectForKey:@"checkin"]];
}

- (void) presentCheckinOverlayWithCheckin:(FSCheckin*)aCheckin {
    NSMutableString *checkinText = [[NSMutableString alloc] initWithCapacity:1];
    if (aCheckin.mayor.user == nil && [aCheckin.mayor.mayorTransitionType isEqualToString:@"nochange"]) {
        [checkinText appendFormat:[NSString stringWithFormat:@"You're still the mayor of %@! \n\n", venue.name]];
    } else if ([aCheckin.mayor.mayorTransitionType isEqualToString:@"stolen"] || [aCheckin.mayor.mayorTransitionType isEqualToString:@"new"]) {
        if ([[self getSingleCheckin].mayor.mayorTransitionType isEqualToString:@"stolen"]) {
            [checkinText appendFormat:[NSString stringWithFormat:@"Congrats! %@ is yours with %d check-ins and %@ lost their crown. \n\n", 
                                      aCheckin.venue.name, 
                                      aCheckin.mayor.numCheckins, 
                                      aCheckin.mayor.user.firstnameLastInitial]];
        } else {
            [checkinText appendFormat:[NSString stringWithFormat:@"%@ \n\n", aCheckin.mayor.mayorCheckinMessage]];
        }
    }
    for (FSBadge *badge in aCheckin.badges) {
        [checkinText appendFormat:[NSString stringWithFormat:@"%@: %@ \n\n", badge.badgeName, badge.badgeDescription]];
    }
    [checkinText appendFormat:@"%@ \n\n", aCheckin.message];
    for (FSScore *score in aCheckin.scoring.scores) {
        [checkinText appendFormat:[NSString stringWithFormat:@"+%d %@ \n", score.points, score.message]];
    }
    DLog(@"checkin text: %@", checkinText);
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Check-in successful" andMessage:checkinText];
    [self displayPopupMessage:message];
    [checkinText release];
    [message release];
    
    self.venueToPush = aCheckin.venue;
}

- (void) setProperButtonStates {
    if (isTwitterOn && isPingOn) {
        DLog(@"twitter and ping is on");
        [pingAndTwitterToggleButton setImage:[UIImage imageNamed:@"ping01b.png"] forState:UIControlStateNormal];
        [pingAndTwitterToggleButton setImage:[UIImage imageNamed:@"ping02b.png"] forState:UIControlStateHighlighted];
    } else if (isPingOn) {
        DLog(@"ping is on");
        [pingAndTwitterToggleButton setImage:[UIImage imageNamed:@"ping03b.png"] forState:UIControlStateNormal];
        [pingAndTwitterToggleButton setImage:[UIImage imageNamed:@"ping04b.png"] forState:UIControlStateHighlighted];
    } else {
        DLog(@"everything is off");
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
    DLog(@"city grid search url: %@", cityGridUrl);
    ASIHTTPRequest *cityGridRequest = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:cityGridUrl]] autorelease];
    
    [cityGridRequest setDidFailSelector:@selector(cityGridRequestWentWrong:)];
    [cityGridRequest setDidFinishSelector:@selector(cityGridRequestDidFinish:)];
    [cityGridRequest setTimeOutSeconds:500];
    [cityGridRequest setDelegate:self];
    [cityGridRequest startAsynchronous];
}

- (void) showSpecial {
    if ([self.venue.specials count] > 1) {
        nextSpecialButton.hidden = NO;
    }
    [self showSpecial:0];
}

- (void) showSpecial:(int)specialIndex {
    FSSpecial *special = ((FSSpecial*)[[self venue].specials objectAtIndex:specialIndex]);
    //DLog(@"specials: %@", [self venue].specials);
    DLog(@"special: %@", special);
    if (special.venue) {
        specialPlaceName.text = special.venue.name;
        specialAddress.text = special.venue.addressWithCrossstreet;   
    } else {
        specialPlaceName.text = venue.name;
        specialAddress.text = venue.addressWithCrossstreet;
    }
    specialText.text = special.messageText;
    
//    CGSize maximumLabelSize = CGSizeMake(246, 157);
//    CGSize expectedLabelSize = [special.messageText sizeWithFont:specialText.font 
//                                           constrainedToSize:maximumLabelSize 
//                                               lineBreakMode:UILineBreakModeWordWrap];
//    DLog(@"expected label size: %f", expectedLabelSize.height);
//    
//    //adjust the label the the new height.
//    CGRect newFrame = specialText.frame;
//    newFrame.size.height = expectedLabelSize.height;
//    specialText.frame = newFrame;

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

- (void) showNextSpecial {
    [self showSpecial:++currentSpecial];
    previousSpecialButton.hidden = NO;
    if (currentSpecial < [self.venue.specials count] - 1) {
        nextSpecialButton.hidden = NO;
    } else {
        nextSpecialButton.hidden = YES;
    }
}

- (void) showPreviousSpecial {
    [self showSpecial:--currentSpecial];
    nextSpecialButton.hidden = NO;
    if (currentSpecial == 0) {
        previousSpecialButton.hidden = YES;
    }
}

- (void) closeSpecialView {
    currentSpecial = 0;
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
    DLog(@"flag venue closed response: %@", inString);
    
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
    DLog(@"BOOOOOOOOOOOO!");
}

- (void) cityGridRequestDidFinish:(ASIHTTPRequest *) request {
    SBJSON *parser = [[SBJSON new] autorelease];
    DLog(@"city grid response: %@", [request responseString]);
    id dict = [parser objectWithString:[request responseString] error:NULL];
    NSArray *array = (NSArray*)[[dict objectForKey:@"jsonResponse"] objectForKey:@"results"];
    DLog(@"array of results: %@", array);
    NSMutableArray *objArray = [[NSMutableArray alloc] initWithCapacity:[array count]];
    bool isMatched = NO;
    for (NSDictionary *dict in array) {
        GAPlace *place = [[GAPlace alloc] init];
        DLog(@"location: %@", [dict objectForKey:@"location"]);
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
        DLog(@"dictionary?: %@", [(NSDictionary*)dict objectForKey:@"entity"]);   
    }
    [objArray release];
    [self stopProgressBar];
}

#pragma mark GeoAPI Delegate methods

// TODO: neaten this mess up
- (void)receivedResponseString:(NSString *)responseString {
//    DLog(@"geoapi response string: %@", responseString);
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
        DLog(@"dictionary?: %@", [(NSDictionary*)dict objectForKey:@"entity"]);   
    }
    [objArray release];
    [self stopProgressBar];
}

- (void)requestFailed:(NSError *)error {
    // TODO: probably want to pop up error message for user
    DLog(@"geoapi error string: %@", error);
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
    
    DLog(@"image picker info: %@", info);
    
//    DLog(@"image height: %f", photoImage.size.height);
//    DLog(@"image width: %f", photoImage.size.width);
//    DLog(@"image orientation: %d", photoImage.imageOrientation);
    
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
    DLog(@"YAY! Image uploaded!");
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
    DLog(@"YAY! Image queue is complete!");
    
    // TODO: this should probably capture the response, parse it into a KBGoody, then add it to the goodies object - it would save an API hit
    
    [self retrievePhotos];
}

- (void) photoUploadFailed:(ASIHTTPRequest *) request {
    [self stopProgressBar];
    DLog(@"Uhoh, it did fail!");
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

