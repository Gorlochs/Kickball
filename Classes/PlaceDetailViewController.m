//
//  PlaceDetailViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 10/28/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "PlaceDetailViewController.h"
#import "ProfileViewController.h"
#import "PlaceTwitterViewController.h"
#import "FoursquareAPI.h"
#import "VenueAnnotation.h"
#import "GAConnectionManager.h"
#import "SBJSON.h"
#import "GeoApiTableViewController.h"
#import "GAPlace.h"
#import "TipDetailViewController.h"
#import "FSTip.h"

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

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

// FIXME: add a check to make sure that a valid venueId exists, since this page will crap out if it doesn't.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // TODO: need a way to persist these? What is the business logic for displaying each cell?
    isUserCheckedIn = NO;
    isPingOn = YES;
    isTwitterOn = YES;
    
    venueDetailButton.hidden = YES;
    twitterButton.hidden = YES;
    
    // this is to clear out the placeholder text, which is useful in IB
    venueName.text = @"";
    venueAddress.text = @"";
    
    // pull this up into a method (or property)
    FSUser *tmpUser = [self getAuthenticatedUser];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:tmpUser.photo]];
    UIImage *img = [[UIImage alloc] initWithData:data];
    signedInUserIcon.imageView.image = [UIImage imageWithData:data];
    signedInUserIcon.hidden = NO;
    [img release];
    
    if(![[FoursquareAPI sharedInstance] isAuthenticated]){
		//run sheet to log in.
		NSLog(@"Foursquare is not authenticated");
	} else {
        [self startProgressBar:@"Retrieving venue details..."];
		[[FoursquareAPI sharedInstance] getVenue:venueId withTarget:self andAction:@selector(venueResponseReceived:withResponseString:)];
	}
}

- (void)venueResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"venue response string: %@", inString);
	self.venue = [FoursquareAPI venueFromResponseXML:inString];
    [self prepViewWithVenueInfo:self.venue];

	[theTableView reloadData];
    [self stopProgressBar];
}

- (void) prepViewWithVenueInfo:(FSVenue*)venueToDisplay {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.002;
    span.longitudeDelta = 0.002;
    
    CLLocationCoordinate2D location = mapView.userLocation.coordinate;
    
    location.latitude =  [venueToDisplay.geolat doubleValue];
    location.longitude = [venueToDisplay.geolong doubleValue];
    region.span = span;
    region.center = location;
    
    [mapView setRegion:region animated:NO];
    [mapView regionThatFits:region];
    
    VenueAnnotation *venueAnnotation = [[VenueAnnotation alloc] initWithCoordinate:location];
    [mapView addAnnotation:venueAnnotation];
    [venueAnnotation release];
    
    venueName.text = venueToDisplay.name;
    venueAddress.text = venueToDisplay.addressWithCrossstreet;
    
    venueDetailButton.hidden = NO;
    
    if (venueToDisplay.mayor != nil) {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:venueToDisplay.mayor.photo]];
        UIImage *img = [[UIImage alloc] initWithData:data];
        mayorMapCell.imageView.image = img;
        [img release];
        mayorNameLabel.text = venueToDisplay.mayor.firstnameLastInitial;
    } else {
        // TODO: get Mikula to make this all pretty and stuff
        mayorNameLabel.text = @"no mayor";
    }
    
    if (venueToDisplay.twitter != nil && ![venueToDisplay.twitter isEqualToString:@""]) {
        twitterButton.hidden = NO;
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
    mapView = nil;
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
    mapView = nil;
    venueName = nil;
    venueAddress = nil;
    mayorNameLabel = nil;
    twitterButton = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) { // points
        return isUserCheckedIn;
    } else if (section == 1) { // badge
        return isUserCheckedIn;
    } else if (section == 2) { // checkin
        return !isUserCheckedIn;
    } else if (section == 3) { // gift
        return !isUserCheckedIn;
    } else if (section == 4) { // mayor
        return 1;
    } else if (section == 5) { // people here
        return [venue.peopleHere count];
    } else if (section == 6) { // tips
        return [venue.tips count];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        // TODO: figure out why the switch doesn't work. very odd.
        if (indexPath.section == 0) {
            return pointsCell;
        } else if (indexPath.section == 1) {
            return badgeCell;
        } else if (indexPath.section == 2) {
            return checkinCell;
        } else if (indexPath.section == 3) {
            return giftCell;
        } else if (indexPath.section == 4) {
            return mayorMapCell;
        } else {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
    }
    
    // Set up the cell...
    if (indexPath.section == 0) {
        // TODO: fill in the points the user received for checking in
        return pointsCell;
    } else if (indexPath.section == 1) {
        return badgeCell;
    } else if (indexPath.section == 2) {
        return checkinCell;
    } else if (indexPath.section == 3) {
        return giftCell;
    } else if (indexPath.section == 4) {
        return mayorMapCell;
    } else if (indexPath.section == 5) {
        cell.detailTextLabel.numberOfLines = 1;
        cell.detailTextLabel.text = nil;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        FSUser *user = ((FSUser*)[venue.peopleHere objectAtIndex:indexPath.row]);
        cell.textLabel.text = user.firstnameLastInitial;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSData *data = nil;
        if (user.photo) {
            data = [NSData dataWithContentsOfURL:[NSURL URLWithString:user.photo]];
        }
        UIImage *img = [[UIImage alloc] initWithData:data];
        cell.imageView.image = img;
        [img release];
    } else if (indexPath.section == 6) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        FSTip *tip = (FSTip*) [venue.tips objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ says,", tip.submittedBy.firstnameLastInitial];
        cell.detailTextLabel.numberOfLines = 2;
        cell.detailTextLabel.text = tip.text;
        cell.imageView.image = nil;
    }
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 44;
        case 1:
            return 66;
        case 2:
            return 44;
        case 3:
            return 216;
        case 4:
            return 62;
        case 5:
            return 44;
        case 6:
            return 62;
        default:
            return 44;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 24.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // create the parent view that will hold header Label
    UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 24.0)] autorelease];
    
    // create the button object
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor blackColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor grayColor];
    headerLabel.highlightedTextColor = [UIColor grayColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:12];
    headerLabel.frame = CGRectMake(00.0, 0.0, 320.0, 24.0);
    
    // If you want to align the header text as centered
    // headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
    switch (section) {
        case 0:
        case 1:
        case 2:
        case 3:
            return nil;
            break;
        case 4:
            // TODO: fix this
            headerLabel.text = @"  Mayor                                                                    Map";
            break;
        case 5:
            headerLabel.text = [NSString stringWithFormat:@"  %d People Here", [venue.peopleHere count]];
            break;
        case 6:
            headerLabel.text = @"  Tips";
            break;
        default:
            headerLabel.text = @"You shouldn't see this";
            break;
    }
    //headerLabel.text = <Put here whatever you want to display> // i.e. array element
    [customView addSubview:headerLabel];
    [headerLabel release];
    return customView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 4) {
        [self pushProfileDetailController:venue.mayor.userId];
    } else if (indexPath.section == 5) {
        FSUser *user = ((FSUser*)[venue.peopleHere objectAtIndex:indexPath.row]);
        [self pushProfileDetailController:user.userId];
    } else if (indexPath.section == 6) {
        FSTip *tip = ((FSTip*)[venue.tips objectAtIndex:indexPath.row]);
        TipDetailViewController *tipController = [[TipDetailViewController alloc] initWithNibName:@"TipView" bundle:nil];
        tipController.tip = tip;
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
    [mapView release];
    [venueName release];
    [venueAddress release];
    [mayorNameLabel release];
    [twitterButton release];
    [venue release];
    [venueId release];
    
    [super dealloc];
}

#pragma mark IBAction methods

- (void) callVenue {
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

- (void) checkinToVenue {
    if(![[FoursquareAPI sharedInstance] isAuthenticated]){
		//run sheet to log in.
		NSLog(@"Foursquare is not authenticated");
	} else {
		[[FoursquareAPI sharedInstance] doCheckinAtVenueWithId:venue.venueid 
                                                      andShout:nil 
                                                       offGrid:!isPingOn
                                                     toTwitter:isTwitterOn
                                                    withTarget:self 
                                                     andAction:@selector(checkinResponseReceived:withResponseString:)];
	}
}

- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"instring: %@", inString);
	self.checkin = [FoursquareAPI checkinsFromResponseXML:inString];
    NSLog(@"checkin: %@", checkin);
    isUserCheckedIn = YES;
	[theTableView reloadData];
    [progressViewController.view removeFromSuperview];
}

// these two methods arte a bit counterintuitive. the selected state is currently off/false, while the unselected state is on/true
- (void) togglePing {
    isPingOn = !isPingOn;
    pingToggleButton.selected = !isPingOn;
    NSLog(@"is ping on: %d", isPingOn);
}

- (void) toggleTwitter {
    isTwitterOn = !isTwitterOn;
    twitterToggleButton.selected = !isTwitterOn;
    NSLog(@"is twitter on: %d", isTwitterOn);
}

- (void) doGeoAPICall {
    GAConnectionManager *connectionManager_ = [[GAConnectionManager alloc] initWithAPIKey:@"K6afuuFTXK" delegate:self];
    CLLocationCoordinate2D location = mapView.userLocation.coordinate;
    
    location.latitude =  [venue.geolat doubleValue];
    location.longitude = [venue.geolong doubleValue];
    [connectionManager_ requestBusinessesNearCoords:location withinRadius:200 maxResults:5];
}

#pragma mark GeoAPI Delegate methods

// TODO: neaten this mess up
- (void)receivedResponseString:(NSString *)responseString {
//    NSLog(@"geoapi response string: %@", responseString);
    SBJSON *parser = [SBJSON new];
    id dict = [parser objectWithString:responseString error:NULL];
    NSArray *array = [(NSDictionary*)dict objectForKey:@"entity"];
    NSMutableArray *objArray = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for (NSDictionary *dict in array) {
        GAPlace *place = [[GAPlace alloc] init];
        place.guid = [dict objectForKey:@"guid"];
        place.name = [[dict objectForKey:@"view.listing"] objectForKey:@"name"];
        NSArray *tmp = [[dict objectForKey:@"view.listing"] objectForKey:@"address"];
        place.address = [NSString stringWithFormat:@"%@, %@, %@", [tmp objectAtIndex:0], [tmp objectAtIndex:1], [tmp objectAtIndex:2]];
        [objArray addObject:place];
        [place release];
        //NSLog(@"name: %@", [[dict objectForKey:@"view.listing"] objectForKey:@"name"]);
    }
    GeoApiTableViewController *vc = [[GeoApiTableViewController alloc] initWithNibName:@"GeoAPIView" bundle:nil];
    vc.geoAPIResults = objArray;
    [objArray release];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
    NSLog(@"dictionary?: %@", [(NSDictionary*)dict objectForKey:@"entity"]);
}

- (void)requestFailed:(NSError *)error {
    // TODO: probably want to pop up error message for user
    NSLog(@"geoapi error string: %@", error);
}

#pragma mark Image Picker Delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // hide picker
    [picker dismissModalViewControllerAnimated:YES];
    
    // upload image
    // TODO: we'd have to confirm success to the user.
    //       we also need to send a notification to the gift recipient
    [self uploadImage:UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 1.0) filename:@"foobar2.jpg"];
}

#pragma mark private methods

// TODO: set max file size    
- (BOOL)uploadImage:(NSData *)imageData filename:(NSString *)filename{
    //TweetPhotoAppDelegate* myApp = (TweetPhotoAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString *url = [NSString stringWithFormat:@"http://www.literalshore.com/gorloch/kickball/upload.php"];
    
    NSString * boundary = @"kickballBoundaryParm";
    NSMutableData *postData = [NSMutableData dataWithCapacity:[imageData length] + 1024];
    
    NSString * venueIdString = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"venueId\"\r\n\r\n%@", venue.venueid];
    NSString * submitterIdString = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"submitterId\"\r\n\r\n%@", @"sabernar"];
    NSString * receiverIdString = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"receiverId\"\r\n\r\n%@", @""];
    NSString * isPrivateString = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"isPrivate\"\r\n\r\n%@", @"1"];
    NSString * messageString = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"message\"\r\n\r\n%@", @"test message"];
    NSString * boundaryString = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
    NSString * boundaryStringFinal = [NSString stringWithFormat:@"\r\n--%@--\r\n", boundary];
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[venueIdString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[submitterIdString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[receiverIdString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[isPrivateString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[messageString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
   
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"photo\";\r\nfilename=\"foobar.jpg\"\r\nContent-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:imageData];
    [postData appendData:[boundaryStringFinal dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [theRequest setHTTPMethod:@"POST"];
    
    [theRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue:@"www.literalshore.com" forHTTPHeaderField:@"Host"];
    NSString * dataLength = [NSString stringWithFormat:@"%d", [postData length]];
    [theRequest addValue:dataLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPBody:(NSData*)postData];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"return string: %@", returnString);
    NSLog(@"response: %@", response);
    NSLog(@"error: %@", error);
    
//    NSURLConnection * theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    if (theConnection) {
//        receivedData=[[NSMutableData data] retain];
//    }
//    else {
//        [myApp addTextToLog:@"Could not connect to the network" withCaption:@"tweetPhoto"];
//    }
    return ([returnString isEqualToString:@"OK"]);
}

@end

