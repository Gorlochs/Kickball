//
//  AddPlaceFormViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 12/14/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "AddPlaceFormViewController.h"
#import "FoursquareAPI.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@implementation AddPlaceFormViewController

@synthesize newVenueName;


- (void)viewDidLoad {
    [super viewDidLoad];
    FSUser *user = [self getAuthenticatedUser];
    NSLog(@"user checkin venue: %@", user.checkin.venue);
    city.text = user.checkin.venue.city;
    state.text = user.checkin.venue.venueState;
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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = [NSString stringWithString:newVenueName];
            break;
        case 1:
            return addressCell;
            break;
        case 2:
            return crossstreetCell;
            break;
        case 3:
            return cityCell;
            break;
        case 4:
            return phoneCell;
            break;
        case 5:
            return twitterCell;
            break;
        default:
            break;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


- (void)dealloc {
    [theTableView release];
    
    [addressCell release];
    [crossstreetCell release];
    [cityCell release];
    [phoneCell release];
    [twitterCell release];
    [saveCell release];
    [checkedInCell release];
    
    [super dealloc];
}

#pragma mark IBAction methods

- (void) clearFields {
    addressCell.textLabel.text = @"";
    crossstreetCell.textLabel.text = @"";
    cityCell.textLabel.text = @"";
    phoneCell.textLabel.text = @"";
    twitterCell.textLabel.text = @"";
    saveCell.textLabel.text = @"";
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Kickball" 
                                                        message:@"Please fill in the required fields."
                                                       delegate:self 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)newVenueResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"new venue instring: %@", inString);
	FSVenue *venue = [FoursquareAPI venueFromResponseXML:inString];
    [self stopProgressBar];
}

- (void) doVenuelessCheckin {
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
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
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
