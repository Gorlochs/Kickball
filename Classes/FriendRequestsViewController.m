//
//  FriendRequestsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 12/6/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "FriendRequestsViewController.h"
#import "FoursquareAPI.h"

@implementation FriendRequestsViewController


/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

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
    return 5;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [friendRequests count];
    }
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = ((FSUser*)[friendRequests objectAtIndex:indexPath.row]).firstnameLastInitial;
            
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setImage:[UIImage imageNamed:@"profileCheckin01.png"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"profileCheckin02.png"] forState:UIControlStateHighlighted];
            btn.frame = CGRectMake(-40, 0, 80, 15);
            btn.userInteractionEnabled = YES;
            btn.tag = indexPath.row;
            [btn addTarget:self action:@selector(didTapFriendizeButton:withEvent:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = btn;
            
            break;
        case 1:
            return addressBookCell;
            break;
        case 2:
            return twitterCell;
            break;
        case 3:
            return nameCell;
            break;
        case 4:
            return phoneCell;
            break;
        default:
            break;
    }
	
    return cell;
}

- (void) didTapFriendizeButton: (UIControl *) button withEvent: (UIEvent *) event {
    NSLog(@"friendize button tapped: %d", button.tag);
    [self startProgressBar:@"Sending friend request..."];
    [[FoursquareAPI sharedInstance] doSendFriendRequest:((FSUser*)[friendRequests objectAtIndex:button.tag]).userId withTarget:self andAction:@selector(friendRequestResponseReceived:withResponseString:)];
}


- (void)friendRequestResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    FSUser *user = [FoursquareAPI userFromResponseXML:inString];
    [self stopProgressBar];
    NSLog(@"user sent a friend request: %@", user);
    
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Friend Request" andSubtitle:@"Complete!" andMessage:@"Your future buddy has been sent a friend request."];
    [self displayPopupMessage:message];
    [message release];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	// create the parent view that will hold header Label
	UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 24.0)] autorelease];
    customView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
	
	// create the button object
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor grayColor];
	headerLabel.highlightedTextColor = [UIColor grayColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:12];
	headerLabel.frame = CGRectMake(10.0, 0.0, 320.0, 24.0);
    
    switch (section) {
        case 0:
            if ([friendRequests count] > 0) {
                headerLabel.text = [NSString stringWithFormat:@"%d friend(s) found. Don't add any baddies.", [friendRequests count]];
            } else {
                [headerLabel release];
                return nil;
            }
            break;
        case 1:
            headerLabel.text = @"From Your Address Book";
            break;
        case 2:
            headerLabel.text = @"From Twitter";
            break;
        case 3:
            headerLabel.text = @"By Name";
            break;
        case 4:
            headerLabel.text = @"By Phone Number";
            break;
        default:
            headerLabel.text = @"You shouldn't see this";
            break;
    }
	[customView addSubview:headerLabel];
    [headerLabel release];
	return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 24.0;
}

- (void)dealloc {
    [theTableView release];
    [addressBookCell release];
    [twitterCell release];
    [nameCell release];
    [phoneCell release];
    
    [addressBookSearchButton release];
    [twitterSearchButton release];
    [nameSearchButton release];
    [phoneSearchButton release];
    
    [twitterText release];
    [nameText release];
    [phoneText release];
    [super dealloc];
}

#pragma mark
#pragma mark IBAction methods


- (void) searchByName {
    if (![nameText.text isEqualToString:@""]) {
        [self startProgressBar:@"Searching..."];
        [[FoursquareAPI sharedInstance] findFriendsByName:nameText.text withTarget:self andAction:@selector(searchResponseReceived:withResponseString:)];
    } else {
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Search Error" andSubtitle:@"Missing value" andMessage:@"Please fill in the name field"];
        [self displayPopupMessage:message];
        [message release];
    }
}

- (void) searchByTwitter {
    if (![twitterText.text isEqualToString:@""]) {
        [self startProgressBar:@"Searching..."];
        [[FoursquareAPI sharedInstance] findFriendsByTwitterName:twitterText.text withTarget:self andAction:@selector(searchResponseReceived:withResponseString:)];
    } else {
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Search Error" andSubtitle:@"Missing value" andMessage:@"Please fill in the twitter field"];
        [self displayPopupMessage:message];
        [message release];
    }
    
}

- (void) searchByPhone {
    if (![phoneText.text isEqualToString:@""]) {
        [self startProgressBar:@"Searching..."];
        [[FoursquareAPI sharedInstance] findFriendsByPhone:phoneText.text withTarget:self andAction:@selector(searchResponseReceived:withResponseString:)];
    } else {
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Search Error" andSubtitle:@"Missing value" andMessage:@"Please fill in the phone field"];
        [self displayPopupMessage:message];
        [message release];
    }
    
}

- (void) searchAddressBook {
    [self startProgressBar:@"Searching address book..."];
    ABAddressBookRef addressBook = ABAddressBookCreate();
    NSArray *people = (NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSMutableArray *phones = [[NSMutableArray alloc] initWithCapacity:1];
    for (int i = 0; i<[people count]; i++) {
        ABRecordRef person = [people objectAtIndex:i];
        if (ABMultiValueGetCount(ABRecordCopyValue(person,kABPersonPhoneProperty)) > 0) {
            NSString *phone = (NSString *)ABMultiValueCopyValueAtIndex(ABRecordCopyValue(person,kABPersonPhoneProperty) ,0);
            if (phone != nil && ![phone isEqualToString:@""]) {
                [phones addObject:phone];
            }
            [phone release];
        }
    }
    [[FoursquareAPI sharedInstance] findFriendsByPhone:[phones componentsJoinedByString:@","] withTarget:self andAction:@selector(searchResponseReceived:withResponseString:)];
    [phones release];
}

- (void)searchResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"search response: %@", inString);
    friendRequests = [FoursquareAPI usersFromResponseXML:inString];
    [theTableView reloadData];
    [self stopProgressBar];
}

#pragma mark
#pragma mark UITextFieldDelegate methods

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

