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
#import "KBUserTweetsViewController.h"
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
#import "GraphAPI.h"
#import "KBAccountManager.h"
#import "TableSectionHeaderView.h"

#define PHOTOS_PER_ROW 4
#define THUMBNAIL_IMAGE_SIZEX 80
#define THUMBNAIL_IMAGE_SIZEY 73
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
@synthesize showCheckinView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad {
    hideFooter = YES;
	theTableView.hidden = YES;
    
    [super viewDidLoad];
    checkinViewController = nil;
    photoManager = [KBPhotoManager sharedInstance];
    photoManager.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayTodoTipMessage:) name:@"todoTipSent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentCheckinOverlay:) name:@"checkedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoUploaded) name:@"photoUploaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startBusy) name:@"startBusy" object:nil];

	specialsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[specialsButton setFrame:CGRectMake(320-51, 0, 53, 57)];
	[specialsButton setImage:[UIImage imageNamed:@"place-Special01.png"] forState:UIControlStateNormal];
	[specialsButton setImage:[UIImage imageNamed:@"place-Special02.png"] forState:UIControlStateHighlighted];
	[specialsButton addTarget:self action:@selector(showSpecial) forControlEvents:UIControlEventTouchUpInside];
	[theTableView addSubview:specialsButton];
  

    
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
	//isFacebookOn = ![[KBAccountManager sharedInstance] defaultPostToFacebook];
    isFacebookOn = tmpUser.sendToFacebook;
    
    [self setProperButtonStates];
    
    mayorCrown.hidden = YES;
	fullMapView.alpha = 0.0;
    
    [self addHeaderAndFooter:theTableView];
    //refreshHeaderView.backgroundColor = [UIColor blackColor];
    
    [self startProgressBar:@"Retrieving venue details..."];
    [[FoursquareAPI sharedInstance] getVenue:venueId withTarget:self andAction:@selector(venueResponseReceived:withResponseString:)];
    [FlurryAPI logEvent:@"Venue Detail"];
    
    [self retrievePhotos];
    [self showBackHomeButtons];
	
    pageType = KBPageTypePlaces;
    pageViewType = KBPageViewTypeList;
    [self setProperFoursquareButtons];
	[centerHeaderButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
	[centerHeaderButton addTarget:self action:@selector(toggleMap) forControlEvents:UIControlEventTouchUpInside];
}

- (void) toggleMap {
	if (fullMapView.alpha < 1.0) {
		[self viewVenueMap];
	} else {
		[self closeMap];
	}
}

- (void) startBusy {
	[self startProgressBar:@""];
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
    
    goodies = [[[KickballAPI kickballApi] parsePhotosFromXML:[request responseString]] copy];
    

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
            
            CGRect frame = CGRectMake(x*THUMBNAIL_IMAGE_SIZEX, y*THUMBNAIL_IMAGE_SIZEY, THUMBNAIL_IMAGE_SIZEX, THUMBNAIL_IMAGE_SIZEY);
            TTImageView *ttImage = [[TTImageView alloc] initWithFrame:frame];
			
			UIScreen *theScreen = [UIScreen mainScreen];
			if (theScreen.scale > 1.0) {
				ttImage.urlPath = goody.mediumImagePath;
            } else {
				ttImage.urlPath = goody.thumbnailImagePath;
			}

			ttImage.clipsToBounds = YES;
            ttImage.contentMode = UIViewContentModeScaleAspectFill;
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

        [theTableView reloadData];
        
        if (self.venue.specials != nil &&[self.venue.specials count] > 0) {
            specialsButton.hidden = NO;
			[self.view bringSubviewToFront:specialsButton];
        } else {
            specialsButton.hidden = YES;
        }
        
		if (showCheckinView) {
			[self openCheckinView];
		}
				
        if (doCheckin) {
			[self startProgressBar:@"Checking into this venue..."];
			// seems idiotic, but you can turn off insta checkin to foursquare. (i agree. stupid.)
			if ([[KBAccountManager sharedInstance] defaultPostToFoursquare]) {
				//cross post to foursquare
				[[FoursquareAPI sharedInstance] doCheckinAtVenueWithId:venue.venueid 
															  andShout:@""
															   offGrid:NO
															withTarget:self 
															 andAction:@selector(checkinResponseReceived:withResponseString:)];
			}
			NSString *msg = [NSString stringWithFormat:@"I just checked into %@. %@", venue.name, [Utilities getShortenedUrlFromFoursquareVenueId:venue.venueid]];
			if ([[KBAccountManager sharedInstance] usesTwitter] && [[KBAccountManager sharedInstance] defaultPostToTwitter]) {
				//cross post to twitter
				[[[KBTwitterManager twitterManager] twitterEngine] sendUpdate:msg
																 withLatitude:[[KBLocationManager locationManager] latitude] 
																withLongitude:[[KBLocationManager locationManager] longitude]];
				
				
			}
			if ([[KBAccountManager sharedInstance] usesFacebook] && [[KBAccountManager sharedInstance] defaultPostToFacebook]) {
				//cross post to facebook
				[Utilities putGoogleMapsWallPostWithMessage:msg andVenue:venue andLink:[Utilities getShortenedUrlFromFoursquareVenueId:venue.venueid]];
				
			}
        }
		theTableView.hidden = NO;
		doCheckin = NO;
		showCheckinView = NO;
    }
}

- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    DLog(@"instring: %@", inString);
	
    FSCheckin *theCheckin = [FoursquareAPI checkinFromResponseXML:inString];
	[self stopProgressBar];
    
	self.venueToPush = theCheckin.venue;
    if ([self getAuthenticatedUser].isPingOn) {
        [self sendPushNotification];
    }
	
	[self presentCheckinOverlayWithCheckin:theCheckin];
	//[theCheckin release];
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"didCheckin" object:nil]; 
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
        
    fullRegion.span = fullSpan;
    fullRegion.center = location;
    region.span = span;
    region.center = location;
    
    [smallMapView setRegion:region animated:NO];
    [smallMapView regionThatFits:region];
    [smallMapView setShowsUserLocation:NO];
    [fullMapView setRegion:fullRegion animated:NO];
    [fullMapView regionThatFits:fullRegion];
    [fullMapView setShowsUserLocation:NO];
    
    VenueAnnotation *venueAnnotation = [[VenueAnnotation alloc] initWithCoordinate:location];
    [smallMapView addAnnotation:venueAnnotation];
    [fullMapView addAnnotation:venueAnnotation];
    [venueAnnotation release];
    
    venueName.text = venueToDisplay.name;
    venueAddress.text = venueToDisplay.addressWithCrossstreet;
    int distance = (int)[[KBLocationManager locationManager] distanceFromCoordinate:venueToDisplay.fullLocation];
    distanceAndNumCheckinsLabel.text = [NSString stringWithFormat:@"%d%@ Away, %d Check-ins Here", distance < 1000 ? distance : distance/1000, distance < 1000 ? @"m" : @"km", venueToDisplay.userCheckinCount];
    
    venueDetailButton.hidden = NO;
    
    if (!venueToDisplay.phone || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || [[[UIDevice currentDevice] model] isEqualToString:@"iPod Touch"] ) {
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
		noMayorLabel.hidden = YES;
    } else {
        noMayorImage.hidden = NO;
        mayorArrow.hidden = YES;
        mayorCrown.hidden = YES;
		noMayorLabel.hidden = NO;
    }
    
    if (venueToDisplay.twitter != nil && ![venueToDisplay.twitter isEqualToString:@""]) {
        twitterButton.enabled = YES;
    } else {
        twitterButton.enabled = NO;
    }
	
	if ([venueToDisplay.currentCheckins count] > 0) {

		//create base container based on how many people
		//UIView *roundedRect;
		UIView *peopleHereContainer;
		UIView *bottomLine;
		peopleHereCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"peopleHere"];
		switch ([venueToDisplay.currentCheckins count]) {
			case 1:
			case 2:
				peopleHereContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 47)];
				[peopleHereContainer setBackgroundColor:[UIColor colorWithWhite:0.92 alpha:1.0]];
				bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 46, 320, 1)];
				[bottomLine setBackgroundColor:[UIColor colorWithWhite:0.77 alpha:1.0]];
				[peopleHereContainer addSubview:bottomLine];
				[bottomLine release];
				break;
			default:
				peopleHereContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 95)];
				[peopleHereContainer setBackgroundColor:[UIColor colorWithWhite:0.92 alpha:1.0]];
				bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 94, 320, 1)];
				[bottomLine setBackgroundColor:[UIColor colorWithWhite:0.77 alpha:1.0]];
				[peopleHereContainer addSubview:bottomLine];
				[bottomLine release];
				break;
		}
		UIView *horizontalSplitter;
		UIView *verticalSplitter;
		FSCheckin *currentCheckin;
		currentCheckin = nil;
		switch ([venueToDisplay.currentCheckins count]) {
			case 1:
				//populate with people
				//person 1
				currentCheckin = ((FSCheckin*)[venueToDisplay.currentCheckins objectAtIndex:0]);
				[self addPersonHere:peopleHereContainer :currentCheckin :1];
				break;
			case 2:
				horizontalSplitter = [[UIView alloc] initWithFrame:CGRectMake(159, 0, 1, 47)];
				[horizontalSplitter setBackgroundColor:[UIColor colorWithWhite:0.77 alpha:1.0]];
				[peopleHereContainer addSubview:horizontalSplitter];
				[horizontalSplitter release];
				
				//populate with people
				//person 1
				currentCheckin = ((FSCheckin*)[venueToDisplay.currentCheckins objectAtIndex:0]);
				[self addPersonHere:peopleHereContainer :currentCheckin :21];
				
				//person 2
				currentCheckin = ((FSCheckin*)[venueToDisplay.currentCheckins objectAtIndex:1]);
				[self addPersonHere:peopleHereContainer :currentCheckin :22];
				break;
			case 3:
				horizontalSplitter = [[UIView alloc] initWithFrame:CGRectMake(159, 0, 1, 48)];
				[horizontalSplitter setBackgroundColor:[UIColor colorWithWhite:0.77 alpha:1.0]];
				[peopleHereContainer addSubview:horizontalSplitter];
				[horizontalSplitter release];
				verticalSplitter = [[UIView alloc] initWithFrame:CGRectMake(0, 48, 320, 1)];
				[verticalSplitter setBackgroundColor:[UIColor colorWithWhite:0.77 alpha:1.0]];
				[peopleHereContainer addSubview:verticalSplitter];
				[verticalSplitter release];
				
				//populate with people
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
				horizontalSplitter = [[UIView alloc] initWithFrame:CGRectMake(159, 0, 1, 95)];
				[horizontalSplitter setBackgroundColor:[UIColor colorWithWhite:0.77 alpha:1.0]];
				[peopleHereContainer addSubview:horizontalSplitter];
				[horizontalSplitter release];
				verticalSplitter = [[UIView alloc] initWithFrame:CGRectMake(0, 48, 320, 1)];
				[verticalSplitter setBackgroundColor:[UIColor colorWithWhite:0.77 alpha:1.0]];
				[peopleHereContainer addSubview:verticalSplitter];
				[verticalSplitter release];
				
				//populate with people
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
			nameRect = CGRectMake(48, 8, 175, 30);
			headRect = CGRectMake(8, 8, 32, 32);
			personTag = 1;
			touchRect = CGRectMake(0, 0, 320, 47);
      //			touchRect = CGRectMake(0, 0, 290, 47);
			accessoryRect = CGRectMake(298, 17, 9, 12);
			break;
		case 3:
			nameRect = CGRectMake(48, 55, 75, 30);
			headRect = CGRectMake(8, 55, 32, 32);
			personTag = 3;
			touchRect = CGRectMake(0, 48, 320, 47);
      //			touchRect = CGRectMake(0, 48, 290, 47);
			accessoryRect = CGRectMake(298, 64, 9, 12);
			break;
		case 21:
			nameRect = CGRectMake(48, 8, 75, 30);
			headRect = CGRectMake(8, 8, 32, 32);
			personTag = 1;
			touchRect = CGRectMake(0, 0, 160, 47);
      //			touchRect = CGRectMake(0, 0, 145, 47);
			accessoryRect = CGRectMake(139, 17, 9, 12);
			break;
		case 22:
			nameRect = CGRectMake(206, 8, 75, 30);
			headRect = CGRectMake(166, 8, 32, 32);
			personTag = 2;
			touchRect = CGRectMake(163, 0, 160, 47);
      //			touchRect = CGRectMake(148, 0, 145, 47);
			accessoryRect = CGRectMake(298, 17, 9, 12);
			break;
		case 23:
			nameRect = CGRectMake(48, 55, 75, 30);
			headRect = CGRectMake(8, 55, 32, 32);
			personTag = 3;
			touchRect = CGRectMake(0, 48, 160, 47);
      //			touchRect = CGRectMake(0, 48, 145, 47);
			accessoryRect = CGRectMake(139, 64, 9, 12);
			break;
		default:
			nameRect = CGRectMake(206, 55, 75, 30);
			headRect = CGRectMake(166, 55, 32, 32);
			personTag = 4;
			touchRect = CGRectMake(163, 48, 160, 47);
      //			touchRect = CGRectMake(148, 48, 145, 47);
			accessoryRect = CGRectMake(298, 64, 9, 12);
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
    //fullMapView = nil;
    badgeImage = nil;
    //smallMapView = nil;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
    fullMapView = nil;
    badgeImage = nil;
    smallMapView = nil;
    
    //theTableView = nil;
    checkinCell = nil;
    giftCell = nil;
    mayorMapCell = nil;
    bottomButtonCell = nil;
    detailButtonCell = nil;
    
    mayorNameLabel = nil;
    mayorCheckinCountLabel = nil;
}

#pragma mark -
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
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
		
		UIView *colorFill = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 55)];
		colorFill.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
		colorFill.opaque = YES;
		[cell setBackgroundView:colorFill];
		[colorFill release];
		
		UIImageView* topLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderTop.png"]];
		topLineImage.frame = CGRectMake(0, 0, 320, 1);
		[cell addSubview:topLineImage];
		[topLineImage release];
		
		// TODO: the origin.y should probably not be hard coded
		UIImageView* bottomLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderBottom.png"]];
		bottomLineImage.frame = CGRectMake(0, 54, 320, 1);
		[cell addSubview:bottomLineImage];
		[bottomLineImage release];
    }
	
    if (indexPath.section == 0) {
        return checkinCell;
    } else if (indexPath.section == 1) {
        return mayorMapCell;
    } else if (indexPath.section == 2) { // people here
		return peopleHereCell;
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
		cell.detailTextLabel.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
		cell.textLabel.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];

        
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
        [cell setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]];  
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: // i'm here button
            return 75;
            break;
        case 1: // mayor-map cell
            return 69;
            break;
        case 2: //people here
			if ([venue.currentCheckins count]<=2) {
				return 47;
			}else {
				return 95;
			}
            break;
        case 3: // photos
//            if ([goodies count] == 0) {
//                return 102;
//            } else {
                return THUMBNAIL_IMAGE_SIZEY;
//            }
            break;
        case 4:
            return 37;
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

    //BlackTableCellHeader *tableCellHeader = [[[BlackTableCellHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)] autorelease];
	//tableCellHeader.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
	TableSectionHeaderView *tableCellHeader = [[[TableSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 39)] autorelease];
	tableCellHeader.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.0];
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
				frame.origin = CGPointMake(240, 6);
				addPhotoButton.frame = frame;
				[tableCellHeader addSubview:addPhotoButton];
			} else {
				seeAllPhotosButton.hidden = NO;
				CGRect frame = addPhotoButton.frame;
				frame.origin = CGPointMake(180, 6);
				addPhotoButton.frame = frame;
				seeAllPhotosButton.frame = CGRectMake(240, 6, 77, 30);
				[tableCellHeader addSubview:addPhotoButton];
				[tableCellHeader addSubview:seeAllPhotosButton];
			}
			//photoHeaderLabel.text = [NSString stringWithFormat:@"%d %@", [goodies count], [goodies count] == 1 ? @"Photo" : @"Photos"];
			tableCellHeader.leftHeaderLabel.text = [NSString stringWithFormat:@"%d %@", [goodies count], [goodies count] == 1 ? @"Photo" : @"Photos"];
			//return photoHeaderView;
            break;
        case 4:
			tableCellHeader.leftHeaderLabel.text = @"More Info";
            break;
        case 5:
            if (YES) { // odd bug. you can't instantiate a new object as the first line in a case statement
                UIButton *addTipButton = [UIButton buttonWithType:UIButtonTypeCustom];
                addTipButton.frame = CGRectMake(180, 7, 54, 27);
                addTipButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                addTipButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                [addTipButton setImage:[UIImage imageNamed:@"place-tipsAdd01.png"] forState:UIControlStateNormal];
                [addTipButton setImage:[UIImage imageNamed:@"place-tipsAdd02.png"] forState:UIControlStateHighlighted];
                [addTipButton addTarget:self action:@selector(addTipTodo) forControlEvents:UIControlEventTouchUpInside]; 
                [tableCellHeader addSubview:addTipButton];
				tableCellHeader.leftHeaderLabel.text = [NSString stringWithFormat:@"%d %@", [venue.tips count], [venue.tips count] == 1 ? @"Tip" : @"Tips"];
				
				if ([venue.tips count] > 4) {
					UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
					myDetailButton.frame = CGRectMake(240, 7, 74, 27);
					myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
					myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
					[myDetailButton setImage:[UIImage imageNamed:@"place-tipsSeeAll01.png"] forState:UIControlStateNormal];
					[myDetailButton setImage:[UIImage imageNamed:@"place-tipsSeeAll02.png"] forState:UIControlStateHighlighted];
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
    if (indexPath.section == 1 && venue.mayor) {
        [self pushProfileDetailController:venue.mayor.userId];
    } else if (indexPath.section == 2) {
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



#pragma mark -
#pragma mark IBAction methods

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
	if (!venue.phone) {
		KBMessage *message = [[KBMessage alloc] initWithMember:@"Foursquare Message" andMessage:@"Sorry, a phone number for this venue could not be found."];
		[self displayPopupMessage:message];
		[message release];
	} else {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"You will be leaving Kickball to make a call. Are you sure?"
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:nil
														otherButtonTitles:@"Yes, open Phone app", nil];
		
		actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
		actionSheet.tag = 99;
		[actionSheet showInView:self.view];
		[actionSheet release];
	}
}

- (void) uploadImageToServer {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:imagePickerController animated:YES];
    [imagePickerController release];
}

- (void) showTwitterFeed {
	KBUserTweetsViewController *recentTweetsController = [[KBUserTweetsViewController alloc] initWithNibName:@"KBUserTweetsViewController" bundle:nil];
    recentTweetsController.username = venue.twitter;
	
    [self.navigationController pushViewController:recentTweetsController animated:YES];
    [recentTweetsController release];
}

- (void) openCheckinView {
    if (checkinViewController) [checkinViewController release];
    checkinViewController = [[KBCheckinModalViewController alloc] initWithNibName:@"CheckinModalView" bundle:nil];
    checkinViewController.venue = venue;
	checkinViewController.parentController = self;
	[checkinViewController.view setCenter:CGPointMake(160.0, 710.0)];
	[self.view setUserInteractionEnabled:NO];
	[self.view addSubview:checkinViewController.view];
	[UIView beginAnimations:@"openCheckinView" context:nil];
    [UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(checkinEnableinput)];
    checkinViewController.view.center = CGPointMake(160.0, 230.0);
	[UIView commitAnimations]; //do animation
	
    //[self presentModalViewController:checkinViewController animated:YES];
}
-(void)checkinEnableinput{
	[self.view setUserInteractionEnabled:YES];
}

-(void) closeChekinView {
	[self.view addSubview:checkinViewController.view];
	[UIView beginAnimations:@"closeCheckinView" context:nil];
	[self.view setUserInteractionEnabled:NO];
    [UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(cleanUpAfterCheckin)];
    checkinViewController.view.center = CGPointMake(160.0, 710.0);
	[UIView commitAnimations]; //do animation
}
-(void)cleanUpAfterCheckin{
	[checkinViewController removeFromSupercontroller];
	[checkinViewController release];
	checkinViewController = nil;
	[self.view setUserInteractionEnabled:YES];
}
        
- (void) presentCheckinOverlay:(NSNotification*)inNotification {
    NSDictionary *dictionary = [inNotification userInfo];
	[self presentCheckinOverlayWithCheckin:[dictionary objectForKey:@"checkin"]];
}

// TODO: probably should pull this out into a separate class
- (void) presentCheckinOverlayWithCheckin:(FSCheckin*)aCheckin {
    NSMutableString *noteworthyCheckin = [[NSMutableString alloc] initWithString:@""];
	float height = 0.0;
	float buffer = 10.0;
    
	imHereButton.enabled = NO;
	
    // create view
    UIWindow* keywindow = [[UIApplication sharedApplication] keyWindow];
    checkinView = [[UIView alloc] initWithFrame:[keywindow frame]];
    checkinView.backgroundColor = [UIColor blackColor];
    checkinView.alpha = 0.85;
    checkinView.opaque = NO;
    
    // create title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 60)];
    //    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 5, 291, 60)];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:42]];
    [titleLabel setTextColor:[UIColor colorWithRed:14/255.0 green:140/255.0 blue:192/255.0 alpha:1]];
    [titleLabel setNumberOfLines:1];
    [titleLabel setMinimumFontSize:10];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:@"Success!"];
    [checkinView addSubview:titleLabel];
	height = height + titleLabel.frame.size.height + buffer;
    [titleLabel release];
    
    // create mayorship badge
	bool showMayorBadge = NO;
	NSString *mayorText = nil;
    if (aCheckin.mayor.user == nil && [aCheckin.mayor.mayorTransitionType isEqualToString:@"nochange"]) {
        mayorText = [NSString stringWithFormat:@"You're still the mayor of %@! \n\n", venue.name];
		showMayorBadge = YES;
    } else if ([aCheckin.mayor.mayorTransitionType isEqualToString:@"stolen"] || [aCheckin.mayor.mayorTransitionType isEqualToString:@"new"]) {
        if ([[self getSingleCheckin].mayor.mayorTransitionType isEqualToString:@"stolen"]) {
            [noteworthyCheckin setString:@"I just became mayor"];
            mayorText = [NSString stringWithFormat:@"Congrats! %@ is yours with %d check-ins and %@ lost their crown. \n\n", 
                                       aCheckin.venue.name, 
                                       aCheckin.mayor.numCheckins, 
                                       aCheckin.mayor.user.firstnameLastInitial];
        } else {
            mayorText = [NSString stringWithFormat:@"%@ \n\n", aCheckin.mayor.mayorCheckinMessage];
        }
		showMayorBadge = YES;
    }
	if (showMayorBadge) {
		UIImageView *mayorBadgeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mayorBG.png"]];
        mayorBadgeImageView.frame = CGRectMake(0, 70, 320, 221);
        [checkinView addSubview:mayorBadgeImageView];
		
        IFTweetLabel *mayorLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake(17.0f, height, 300.0f, 50.0f)];
        [mayorLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [mayorLabel setTextColor:[UIColor whiteColor]];
        [mayorLabel setBackgroundColor:[UIColor clearColor]];
        [mayorLabel setNumberOfLines:0];
        [mayorLabel setText:mayorText];
		
        [checkinView addSubview:mayorLabel];
		height = height + mayorBadgeImageView.frame.size.height + buffer;
        [mayorBadgeImageView release];
        [mayorLabel release];
	}
    
    // loop through badges
    int i = 0;
    for (FSBadge *badge in aCheckin.badges) {
        if ([noteworthyCheckin length] > 0) {
            [noteworthyCheckin appendString:[NSString stringWithFormat:@" and I unlocked the %@ badge", badge.badgeName]];
        } else {
            [noteworthyCheckin appendString:[NSString stringWithFormat:@"I just unlocked the %@ badge at %@", badge.badgeName, venue.name]];
        }
        NSURL *url = [NSURL URLWithString:badge.icon];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [[UIImage alloc] initWithData:data];
        UIImageView *badgeImageView = [[UIImageView alloc] initWithImage:img];
        badgeImageView.frame = CGRectMake(0, height, 50, 50);
        //        badgeImageView.frame = CGRectMake(17, height, 50, 50);
        [checkinView addSubview:badgeImageView];
        [badgeImageView release];
		[img release];
        
        IFTweetLabel *messageLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake(75.0f, height - 10, 220.0f, 70.0f)];
        [messageLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [messageLabel setTextColor:[UIColor whiteColor]];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setNumberOfLines:0];
        [messageLabel setText:[NSString stringWithFormat:@"%@: %@ \n\n", badge.badgeName, badge.badgeDescription]];
        [checkinView addSubview:messageLabel];
		height = height + messageLabel.frame.size.height + buffer;
        [messageLabel release];
        i++;
    }
    
    // display message
    IFTweetLabel *messageLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake(17.0f, height, 280.0f, 80.0f)];
    [messageLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [messageLabel setTextColor:[UIColor whiteColor]];
    [messageLabel setBackgroundColor:[UIColor clearColor]];
    [messageLabel setNumberOfLines:0];
    [messageLabel setText:aCheckin.message];
	
	//// resize messageLabel ////
	CGSize maximumLabelSize = CGSizeMake(320, 80);
  //	CGSize maximumLabelSize = CGSizeMake(280, 80);
	CGSize expectedLabelSize = [aCheckin.message sizeWithFont:messageLabel.font 
										   constrainedToSize:maximumLabelSize 
											   lineBreakMode:UILineBreakModeClip]; 
	CGRect newFrame = messageLabel.frame;
	newFrame.size.height = expectedLabelSize.height;
	messageLabel.frame = newFrame;
		
    [checkinView addSubview:messageLabel];
	height = height + messageLabel.frame.size.height + buffer;
    [messageLabel release];
    
    // loop through scores to display points
    IFTweetLabel *scoreLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake(17.0f, height, 320, 80.0f)];
     //   IFTweetLabel *scoreLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake(17.0f, height, 280.0f, 80.0f)];
    [scoreLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [scoreLabel setTextColor:[UIColor whiteColor]];
    [scoreLabel setBackgroundColor:[UIColor clearColor]];
    [scoreLabel setNumberOfLines:0];
    [scoreLabel setText:aCheckin.message];
    NSMutableString *scoreText = [[NSMutableString alloc] initWithCapacity:1];
    for (FSScore *score in aCheckin.scoring.scores) {
        [scoreText appendString:[NSString stringWithFormat:@"+%d %@ \n", score.points, score.message]];
    }
    [scoreLabel setText:scoreText];
	
	//// resize scoreLabel ////
	CGSize maximumLabelSize2 = CGSizeMake(280, 80);
	CGSize expectedLabelSize2 = [scoreText sizeWithFont:scoreLabel.font 
											constrainedToSize:maximumLabelSize2 
												lineBreakMode:UILineBreakModeClip]; 
	CGRect newFrame2 = scoreLabel.frame;
	newFrame2.size.height = expectedLabelSize2.height;
	scoreLabel.frame = newFrame2;
	
	[scoreText release];
    [checkinView addSubview:scoreLabel];
	//height = height + scoreLabel.frame.size.height + buffer;
    [scoreLabel release];
    
    // do facebook stuff
	if (isFacebookOn && [noteworthyCheckin length] > 0) {
        [noteworthyCheckin appendString:[NSString stringWithFormat:@" at %@! %@", venue.name, [Utilities getShortenedUrlFromFoursquareVenueId:venue.venueid]]];
		GraphAPI *graph = [[FacebookProxy instance] newGraph];
		[graph putWallPost:@"me" message:noteworthyCheckin attachment:nil];
		[graph release];
	}
	[noteworthyCheckin release];
	// add close button overlay
	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[closeButton setFrame:CGRectMake(0, 0, 320, 480)];
	[closeButton addTarget:self action:@selector(checkinFadeOut) forControlEvents:UIControlEventTouchUpInside];
	[checkinView addSubview:closeButton];
//	[closeButton release];
    
    // add view to main view
    [self.view addSubview:checkinView];

    self.venueToPush = aCheckin.venue;
}

-(void) checkinFadeOut {
	[UIView beginAnimations:@"fadeOut" context:NULL];
	[UIView setAnimationDuration:0.7];
	[UIView setAnimationDelegate:self];
	checkinView.alpha = 0.0;
	[UIView commitAnimations];
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
    connectionManager_ = [[GAConnectionManager alloc] initWithAPIKey:@"K6afuuFTXK" delegate:self];
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
    closeMapButton.frame = CGRectMake(275, 123, 45, 45);
    fullMapView.alpha = 0;
    fullMapView.frame = CGRectMake(0, 117, 320, 343);
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

#pragma mark -
#pragma mark CityGrid methods

- (void) cityGridRequestWentWrong:(ASIHTTPRequest *) request {
    DLog(@"BOOOOOOOOOOOO!");
}

- (void) cityGridRequestDidFinish:(ASIHTTPRequest *) request {
    SBJSON *parser = [SBJSON new];
    DLog(@"city grid response: %@", [request responseString]);
    id dict = [parser objectWithString:[request responseString] error:NULL];
	[parser release];
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

#pragma mark -
#pragma mark GeoAPI Delegate methods

// TODO: neaten this mess up
- (void)receivedResponseString:(NSString *)responseString {
//    DLog(@"geoapi response string: %@", responseString);
    SBJSON *parser = [SBJSON new];
    id dict = [parser objectWithString:responseString error:NULL];
	[parser release];
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
    [self stopProgressBar];
}

#pragma mark 
#pragma mark MapKit methods

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>) annotation{
	
    if( [[annotation title] isEqualToString:@"Current Location"] ) {
		return nil;
	}
    
    int postag = 0;
    static NSString* annotationIdentifier = @"annotationIdentifier";
	KBPin* annView = (KBPin *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
	if (!annView)
	{
		// if an existing pin view was not available, create one
		annView = [[[KBPin alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
	//KBPin *annView=[[[KBPin alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomId"] autorelease];
	}
	//annView.pinColor = MKPinAnnotationColorGreen;
    annView.image = [UIImage imageNamed:@"place-mapPin.png"];
    
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

#pragma mark -
#pragma mark Image Picker Delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissModalViewControllerAnimated:NO];
    
    UIImage *initialImage = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
    float initialHeight = initialImage.size.height;
    float initialWidth = initialImage.size.width;
	
    DLog(@"initialImage height: %f", initialImage.size.height);
    DLog(@"initialImage width: %f", initialImage.size.width);
    
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
    
    DLog(@"image height: %f", self.photoImage.size.height);
    DLog(@"image width: %f", self.photoImage.size.width);
//    DLog(@"image orientation: %d", photoImage.imageOrientation);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnFromMessageView:) name:@"attachMessageToPhoto" object:nil];
    
    photoMessageViewController = [[PhotoMessageViewController alloc] initWithNibName:@"PhotoMessageViewController" bundle:nil];
    [self.navigationController presentModalViewController:photoMessageViewController animated:YES];
    //[photoMessageViewController release];
}

- (void) returnFromMessageView:(NSNotification *)inNotification {
    NSString *message = [[inNotification userInfo] objectForKey:@"message"];
    self.photoMessageToPush = message;
    [photoMessageViewController dismissModalViewControllerAnimated:YES];
    [self startProgressBar:@"Uploading photo..." withTimer:NO andLongerTime:NO];
	
    [photoManager uploadImage:UIImageJPEGRepresentation(self.photoImage, 1.0) 
					 filename:@"gift.jpg" 
					withWidth:self.photoImage.size.width 
					andHeight:self.photoImage.size.height
				   andMessage:message ? message : @""
			   andOrientation:self.photoImage.imageOrientation
					 andVenue:venue];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"attachMessageToPhoto" object:nil];
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
		if (actionSheet.tag == 99) {
			DLog(@"call made");
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", venue.phone]]];
		} else {
			[FlurryAPI logEvent:@"Choose Photo: Library"];
			[self getPhoto:UIImagePickerControllerSourceTypePhotoLibrary];
		}
    } else if (buttonIndex == 1) {
		if (actionSheet.tag == 99) {
			DLog(@"call cancelled");
		} else {
			[FlurryAPI logEvent:@"Choose Photo: New"];
			[self getPhoto:UIImagePickerControllerSourceTypeCamera];
		}
    }
}

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
    DLog(@"YAY! Image uploaded! %@", [request responseString]);

    
    // NOTE: the self.photoMessageToPush is being set above in the returnFromMessageView: method
    self.venueToPush = self.venue;
    self.hasPhoto = YES;
    [self sendPushNotification];
    [FlurryAPI logEvent:@"Image Upload Completed"];
	[self retrievePhotos];
}

- (void) photoQueueFinished:(ASIHTTPRequest *) request {
    [self stopProgressBar];
    DLog(@"YAY! Image queue is complete! 3");
    
    // TODO: this should probably capture the response, parse it into a KBGoody, then add it to the goodies object - it would save an API hit
    
    [self retrievePhotos];
}

- (void) photoUploadFailed:(ASIHTTPRequest *) request {
    [self stopProgressBar];
    DLog(@"Uhoh, it did fail!");
}

// this is used in the notification
- (void) photoUploaded {
	KBMessage *message = [[KBMessage alloc] initWithMember:@"Kickball Message" andMessage:@"Image upload has been completed!"];
    [self displayPopupMessage:message];
    [message release];
}

#pragma mark -
#pragma mark table refresh methods

- (void) refreshTable {
    [[FoursquareAPI sharedInstance] getVenue:venueId withTarget:self andAction:@selector(venueResponseReceivedWithRefresh:withResponseString:)];
}

- (void)venueResponseReceivedWithRefresh:(NSURL *)inURL withResponseString:(NSString *)inString {
    [self venueResponseReceived:inURL withResponseString:inString];
	[self dataSourceDidFinishLoadingNewData];
}


- (void)dealloc {
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"todoTipSent"];
        [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"shoutAndCheckinSent"];
    }
    @catch (NSException * e) {
        DLog("observer could not be removed: %@", e);
    }
    @finally {
        DLog("finally");
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	photoManager.delegate = nil;
    
    [checkin release];
    [venue release];
    [venueId release];
    [goodies release];
    [photoSource release];
    [photoImage release];
    
    [tipController release];
    [checkinViewController release];
	
	[peopleHereCell release];
	[checkinView release];
	
	if (connectionManager_) [connectionManager_ release];
    [mayorMapCell release];
	[checkinCell release];
	[giftCell release];
    [super dealloc];
}

@end

