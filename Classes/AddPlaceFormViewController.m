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
    venueName.text = newVenueName;
    FSUser *user = [self getAuthenticatedUser];
    NSLog(@"user checkin venue: %@", user.checkin.venue);
    city.text = user.checkin.venue.city;
    state.text = user.checkin.venue.venueState;
    [[Beacon shared] startSubBeaconWithName:@"Add Venue Form View"];
    //[address becomeFirstResponder];
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
}

- (void) viewTipsForAddingNewPlace {
    AddPlaceTipsViewController *tipController = [[AddPlaceTipsViewController alloc] initWithNibName:@"AddPlaceTipsViewController" bundle:nil];
    [self.navigationController pushViewController:tipController animated:YES];
    [tipController release];
}

- (void) saveVenueAndCheckin {
    if (![address.text isEqualToString:@""] && ![city.text isEqualToString:@""] && ![state.text isEqualToString:@""]) {
        [self startProgressBar:@"Adding new venue and checking you in..."];
        [[FoursquareAPI sharedInstance] addNewVenue:newVenueName 
                                          atAddress:address.text 
                                     andCrossstreet:crossstreet.text 
                                            andCity:city.text 
                                           andState:state.text 
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
    NSLog(@"new venue instring: %@", inString);
	FSVenue *venue = [FoursquareAPI venueFromResponseXML:inString];
    [self stopProgressBar];
    
    // TODO: we should think about removing the Add Venue pages from the stack so users can't use the BACK button to return to them
    PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];    
    placeDetailController.venueId = venue.venueid;
    placeDetailController.doCheckin = YES;
    [self.navigationController pushViewController:placeDetailController animated:YES];
    [placeDetailController release];
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
    NSLog(@"text field did begin editing: %@", textField);
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
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    } else {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"text field did end editing: %@", textField);
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"text field should return: %@", textField);
    bool shouldReturn = NO;
    if (textField == address) {
        [crossstreet becomeFirstResponder];
    } else if (textField == crossstreet) {
        [city becomeFirstResponder];
    } else if (textField == city) {
        [state becomeFirstResponder];
    } else if (textField == state) {
        [zip becomeFirstResponder];
    } else if (textField == zip) {
        [twitter becomeFirstResponder];
    } else if (textField == twitter) {
        [phone becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        shouldReturn = YES;
    }
    return shouldReturn;
}

@end

