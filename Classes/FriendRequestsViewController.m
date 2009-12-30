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
    return 4;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
            return addressBookCell;
            break;
        case 1:
            return twitterCell;
            break;
        case 2:
            return nameCell;
            break;
        case 3:
            return phoneCell;
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
            headerLabel.text = @"From Your Address Book";
            break;
        case 1:
            headerLabel.text = @"From Twitter";
            break;
        case 2:
            headerLabel.text = @"By Name";
            break;
        case 3:
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
        [[FoursquareAPI sharedInstance] findFriendsByName:nameText.text withTarget:self andAction:@selector(searchResponseReceived:withResponseString:)];
    } else {
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Search Error" andSubtitle:@"Missing value" andMessage:@"Please fill in the name field"];
        [self displayPopupMessage:message];
        [message release];
    }
}

- (void) searchByTwitter {
    if (![twitterText.text isEqualToString:@""]) {
        [[FoursquareAPI sharedInstance] findFriendsByTwitterName:twitterText.text withTarget:self andAction:@selector(searchResponseReceived:withResponseString:)];
    } else {
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Search Error" andSubtitle:@"Missing value" andMessage:@"Please fill in the twitter field"];
        [self displayPopupMessage:message];
        [message release];
    }
    
}

- (void) searchByPhone {
    if (![phoneText.text isEqualToString:@""]) {
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
//        NSString *firstName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
//		NSString *lastName = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        NSLog(@"person: %@", person);

        NSLog(@"person name: %@ %@", ABRecordCopyValue(person, kABPersonFirstNameProperty), ABRecordCopyValue(person, kABPersonLastNameProperty));
        if (ABMultiValueGetCount(ABRecordCopyValue(person,kABPersonPhoneProperty)) > 0) {
            NSLog(@"phone property: %@", ABMultiValueCopyValueAtIndex(ABRecordCopyValue(person,kABPersonPhoneProperty) ,0));
            NSString *phone = (NSString *)ABMultiValueCopyValueAtIndex(ABRecordCopyValue(person,kABPersonPhoneProperty) ,0);
            if (phone != nil && ![phone isEqualToString:@""]) {
                NSLog(@"phone: %@", phone);
                [phones addObject:phone];
            }
            [phone release];
        }
        
    }
    NSLog(@"phones: %@", phones);
    NSLog(@"phones: %@", [phones componentsJoinedByString:@","]);
    [[FoursquareAPI sharedInstance] findFriendsByPhone:[phones componentsJoinedByString:@","] withTarget:self andAction:@selector(searchResponseReceived:withResponseString:)];
}

- (void)searchResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"search response: %@", inString);
    NSArray *users = [FoursquareAPI usersFromResponseXML:inString];
    // TODO: display users 
    [self stopProgressBar];
}

@end

