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
#import "AddPlaceTipsViewController.h"


@implementation AddPlaceFormViewController

@synthesize newVenueName;


- (void)viewDidLoad {
    [super viewDidLoad];
    //venueName.text = newVenueName;
    placeName.text = newVenueName;
    [[Beacon shared] startSubBeaconWithName:@"Add Venue Form View"];
    
    toolbar.frame = CGRectMake(0, 436, 320, 44);
    [self.view addSubview:toolbar];
    toolbar.hidden = YES;
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
    [newVenueName release];
    
    [address release];
    [crossstreet release];
    [city release];
    [state release];
    [zip release];
    [phone release];
    [twitter release];
    [placeName release];
    
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
    placeName.text = @"";
}

- (void) cancelEditing {
    [address resignFirstResponder];
    [crossstreet resignFirstResponder];
    [city resignFirstResponder];
    [phone resignFirstResponder];
    [twitter resignFirstResponder];
    [zip resignFirstResponder];
    [state resignFirstResponder];
    [placeName resignFirstResponder];
    
    // slide toolbar downward with keyboard
    CGRect toolbarFrame = toolbar.frame;
    toolbarFrame.origin.y = 500;
        
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [toolbar setFrame:toolbarFrame];
    
    [UIView commitAnimations];
}

// this is hacky, too. There should be an array of textfields and then just advance to the next one or something
// but I'm tired of all this shit, so I'm doing it the 'easy' way
- (void) editNextField {
    if ([placeName isFirstResponder]) {
        [address becomeFirstResponder];
    } else if ([address isFirstResponder]) {
        [crossstreet becomeFirstResponder];
    } else if ([crossstreet isFirstResponder]) {
        [phone becomeFirstResponder];
//    } else if ([city isFirstResponder]) {
//        [state becomeFirstResponder];
//    } else if ([state isFirstResponder]) {
//        [zip becomeFirstResponder];
//    } else if ([zip isFirstResponder]) {
//        [twitter becomeFirstResponder];
    } else if ([phone isFirstResponder]) {
        [twitter becomeFirstResponder];
    } else {
        [self cancelEditing];
    }
}

- (void) editPreviousField {
    if ([placeName isFirstResponder]) {
        [self cancelEditing];
    } else if ([address isFirstResponder]) {
        [placeName becomeFirstResponder];
    } else if ([crossstreet isFirstResponder]) {
        [address becomeFirstResponder];
//    } else if ([city isFirstResponder]) {
//        [crossstreet becomeFirstResponder];
//    } else if ([state isFirstResponder]) {
//        [city becomeFirstResponder];
//    } else if ([zip isFirstResponder]) {
//        [state becomeFirstResponder];
    } else if ([phone isFirstResponder]) {
        [crossstreet becomeFirstResponder];
    } else if ([twitter isFirstResponder]) {
        [phone becomeFirstResponder];
    }
}

- (void) viewTipsForAddingNewPlace {
    AddPlaceTipsViewController *tipController = [[AddPlaceTipsViewController alloc] initWithNibName:@"AddPlaceTipsViewController" bundle:nil];
    [self.navigationController pushViewController:tipController animated:YES];
    [tipController release];
}

- (void) saveVenueAndCheckin {
    if (![address.text isEqualToString:@""]) {
        FSUser *user = [self getAuthenticatedUser];
        
        [self startProgressBar:@"Adding new venue and checking you in..."];
        [[FoursquareAPI sharedInstance] addNewVenue:placeName.text 
                                          atAddress:address.text 
                                     andCrossstreet:crossstreet.text 
                                            andCity:user.checkin.venue != nil && user.checkin.venue.city != nil ? user.checkin.venue.city : @""
                                           andState:user.checkin.venue != nil && user.checkin.venue.venueState != nil ? user.checkin.venue.venueState : @""
                                     andOptionalZip:zip.text 
                                  andRequiredCityId:city.text 
                                   andOptionalPhone:phone.text 
                                         withTarget:self 
                                          andAction:@selector(newVenueResponseReceived:withResponseString:)];
    } else {
        KBMessage *msg = [[KBMessage alloc] initWithMember:@"Form Error!" andMessage:@"All the required fields need to be filled in"];
        [self displayPopupMessage:msg];
        [msg release];
    }
}

- (void)newVenueResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    BOOL hasError = [inString rangeOfString:@"<error>"].location != NSNotFound;
    if (hasError) {
        KBMessage *msg = [[KBMessage alloc] initWithMember:@"Foursquare Error" andMessage:@"The venue could not be created, possibly because it is a duplicate venue."];
        [self displayPopupMessage:msg];
        [msg release];
    } else {
        NSLog(@"new venue instring: %@", inString);
        FSVenue *venue = [FoursquareAPI venueFromResponseXML:inString];
        
        // TODO: we should think about removing the Add Venue pages from the stack so users can't use the BACK button to return to them
        PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];    
        placeDetailController.venueId = venue.venueid;
        placeDetailController.doCheckin = YES;
        [self.navigationController pushViewController:placeDetailController animated:YES];
        [placeDetailController release]; 
    }
    [self stopProgressBar];
}

- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"new checkin instring: %@", inString);
	NSArray *checkins = [FoursquareAPI checkinFromResponseXML:inString];
    FSCheckin *checkin = [checkins objectAtIndex:0];
    NSLog(@"venueless checkin: %@", checkins);
    [self stopProgressBar];
    
    // TODO: we should probably take the user off this page.
    KBMessage *msg = [[KBMessage alloc] initWithMember:@"Check-in Successful" andMessage:checkin.message];
    [self displayPopupMessage:msg];
    [msg release];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //NSLog(@"text field did begin editing: %@", textField);
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
    NSLog(@"animated distance: %f", animatedDistance);
    NSLog(@"viewframe origin y: %f", viewFrame.origin.y);
    
    // toolbar stuff
    toolbar.hidden = NO;
    CGRect toolbarFrame = toolbar.frame;
    
    // SUPER HACK!!!
    if (textField == placeName) {
        toolbarFrame.origin.y = 200;
    } else if (textField == address) {
        toolbarFrame.origin.y = 241;
    } else if (textField == crossstreet) {
        toolbarFrame.origin.y = 288;
//    } else if (textField == city) {
//        toolbarFrame.origin.y = 300;
//    } else if (textField == state || textField == zip) {
//        toolbarFrame.origin.y = 337;
    } else if (textField == twitter || textField == phone) {
        toolbarFrame.origin.y = 330;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [toolbar setFrame:toolbarFrame];
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //NSLog(@"text field did end editing: %@", textField);
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self cancelEditing];
    [self saveVenueAndCheckin];
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

