//
//  AddPlaceFormViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 12/14/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "AddPlaceFormViewController.h"
#import "FoursquareAPI.h"
#import "PlaceDetailViewController.h"
#import "FSCheckin.h"


@implementation AddPlaceFormViewController

@synthesize newVenue;


- (void)viewDidLoad {
    self.hideFooter = YES;
    self.hideHeader = YES;
    self.hideRefresh = YES;
    
    [super viewDidLoad];
    
    [FlurryAPI logEvent:@"Add Venue Form View"];
    
    toolbar.frame = CGRectMake(0, 436, 320, 44);
    [self.view addSubview:toolbar];
    toolbar.hidden = YES;
    
    address.text = newVenue.venueAddress;
    crossstreet.text = newVenue.crossStreet;
    city.text = newVenue.city;
    phone.text = newVenue.phone;
    twitter.text = newVenue.twitter;
    zip.text = newVenue.zip;
    state.text = newVenue.venueState;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [tableCell release];
    [newVenue release];
    
    [address release];
    [crossstreet release];
    [city release];
    [state release];
    [zip release];
    [phone release];
    [twitter release];
    [country release];
    
    [venueName release];
    [toolbar release];
    
    [super dealloc];
}

#pragma mark IBAction methods

- (void) clearFields {
    address.text = @"";
    crossstreet.text = @"";
    city.text = @"";
    phone.text = @"";
    twitter.text = @"";
    zip.text = @"";
    state.text = @"";
    country.text = @"";
}

- (void) cancelEditing {
    [address resignFirstResponder];
    [crossstreet resignFirstResponder];
    [city resignFirstResponder];
    [phone resignFirstResponder];
    [twitter resignFirstResponder];
    [zip resignFirstResponder];
    [state resignFirstResponder];
    [country resignFirstResponder];
    
    // slide toolbar downward with keyboard
    CGRect toolbarFrame = toolbar.frame;
    toolbarFrame.origin.y = 500;
        
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [toolbar setFrame:toolbarFrame];
    
    [UIView commitAnimations];
}

- (void) backToAddAVenue {
    // FIXME: send the address data back to the main page
    newVenue.venueAddress = address.text;
    newVenue.crossStreet = crossstreet.text;
    newVenue.phone = phone.text;
    newVenue.city = city.text;
    newVenue.venueState = state.text;
    newVenue.zip = zip.text;
    newVenue.twitter = twitter.text;
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:newVenue, nil] 
                                                         forKeys:[NSArray arrayWithObjects:@"updatedVenue", nil]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"venueAddressUpdate" object:nil userInfo:userInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

// this is hacky, too. There should be an array of textfields and then just advance to the next one or something
// but I'm tired of all this shit, so I'm doing it the 'easy' way
- (void) editNextField {
    if ([address isFirstResponder]) {
        [crossstreet becomeFirstResponder];
    } else if ([crossstreet isFirstResponder]) {
        [phone becomeFirstResponder];
    } else if ([city isFirstResponder]) {
        [state becomeFirstResponder];
    } else if ([state isFirstResponder]) {
        [zip becomeFirstResponder];
    } else if ([zip isFirstResponder]) {
        [country becomeFirstResponder];
    } else if ([country isFirstResponder]) {
        [phone becomeFirstResponder];
    } else if ([phone isFirstResponder]) {
        [twitter becomeFirstResponder];
    } else {
        [self cancelEditing];
    }
}

- (void) editPreviousField {
    if ([address isFirstResponder]) {
        [self cancelEditing];
    } else if ([crossstreet isFirstResponder]) {
        [address becomeFirstResponder];
    } else if ([city isFirstResponder]) {
        [crossstreet becomeFirstResponder];
    } else if ([state isFirstResponder]) {
        [city becomeFirstResponder];
    } else if ([zip isFirstResponder]) {
        [state becomeFirstResponder];
    } else if ([country isFirstResponder]) {
        [zip becomeFirstResponder];
    } else if ([phone isFirstResponder]) {
        [country becomeFirstResponder];
    } else if ([twitter isFirstResponder]) {
        [phone becomeFirstResponder];
    }
}
//
//- (void) saveVenueAndCheckin {
//    if (![address.text isEqualToString:@""]) {
//        FSUser *user = [self getAuthenticatedUser];
//        
//        [self startProgressBar:@"Adding new venue and checking you in..."];
//        [[FoursquareAPI sharedInstance] addNewVenue:newVenue.name
//                                          atAddress:address.text 
//                                     andCrossstreet:crossstreet.text 
//                                            andCity:user.checkin.venue != nil && user.checkin.venue.city != nil ? user.checkin.venue.city : @""
//                                           andState:user.checkin.venue != nil && user.checkin.venue.venueState != nil ? user.checkin.venue.venueState : @""
//                                     andOptionalZip:zip.text 
//                                  andRequiredCityId:city.text 
//                                   andOptionalPhone:phone.text 
//                                         withTarget:self 
//                                          andAction:@selector(newVenueResponseReceived:withResponseString:)];
//    } else {
//        KBMessage *msg = [[KBMessage alloc] initWithMember:@"Form Error!" andMessage:@"All the required fields need to be filled in"];
//        [self displayPopupMessage:msg];
//        [msg release];
//    }
//}
//
//- (void)newVenueResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
//    BOOL hasError = [inString rangeOfString:@"<error>"].location != NSNotFound;
//    if (hasError) {
//        KBMessage *msg = [[KBMessage alloc] initWithMember:@"Foursquare Error" andMessage:@"The venue could not be created, possibly because it is a duplicate venue."];
//        [self displayPopupMessage:msg];
//        [msg release];
//    } else {
//        DLog(@"new venue instring: %@", inString);
//        FSVenue *venue = [FoursquareAPI venueFromResponseXML:inString];
//        
//        // TODO: we should think about removing the Add Venue pages from the stack so users can't use the BACK button to return to them
//        PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView_v2" bundle:nil];    
//        placeDetailController.venueId = venue.venueid;
//        placeDetailController.doCheckin = YES;
//        [self.navigationController pushViewController:placeDetailController animated:YES];
//        [placeDetailController release]; 
//    }
//    [self stopProgressBar];
//}
//
//- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
//    DLog(@"new checkin instring: %@", inString);
//	NSArray *checkins = [FoursquareAPI checkinFromResponseXML:inString];
//    FSCheckin *checkin = [checkins objectAtIndex:0];
//    DLog(@"venueless checkin: %@", checkins);
//    [self stopProgressBar];
//    
//    // TODO: we should probably take the user off this page.
//    KBMessage *msg = [[KBMessage alloc] initWithMember:@"Check-in Successful" andMessage:checkin.message];
//    [self displayPopupMessage:msg];
//    [msg release];
//}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //DLog(@"text field did begin editing: %@", textField);
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0) {
        heightFraction = 0.0;
    } else if (heightFraction > 1.0) {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    } else {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
//    DLog(@"animated distance: %f", animatedDistance);
//    DLog(@"viewframe origin y: %f", viewFrame.origin.y);
    
//    // toolbar stuff
//    toolbar.hidden = NO;
//    CGRect toolbarFrame = toolbar.frame;
//    
//    // SUPER HACK!!!
//    if (textField == address) {
//        toolbarFrame.origin.y = 241;
//    } else if (textField == crossstreet) {
//        toolbarFrame.origin.y = 288;
//    } else if (textField == city) {
//        toolbarFrame.origin.y = 300;
//    } else if (textField == state) {
//        toolbarFrame.origin.y = 337;
//    } else if (textField == country) {
//        toolbarFrame.origin.y = 337;
//    } else if (textField == zip) {
//        toolbarFrame.origin.y = 337;
//    } else if (textField == phone) {
//        toolbarFrame.origin.y = 337;
//    } else if (textField == twitter) {
//        toolbarFrame.origin.y = 330;
//    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    //[toolbar setFrame:toolbarFrame];
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //DLog(@"text field did end editing: %@", textField);
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // TODO: go from textfield to textfield
    if (textField == address) {
        [crossstreet becomeFirstResponder];
    } else if (textField == crossstreet) {
        [city becomeFirstResponder];
    } else if (textField == city) {
        [state becomeFirstResponder];
    } else if (textField == state) {
        [zip becomeFirstResponder];
    } else if (textField == zip) {
        [country becomeFirstResponder];
    } else if (textField == country) {
        [phone becomeFirstResponder];
    } else if (textField == phone) {
        [twitter becomeFirstResponder];
    } else {
        [self cancelEditing];
    }
    return YES;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableCell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 313;
}

@end

