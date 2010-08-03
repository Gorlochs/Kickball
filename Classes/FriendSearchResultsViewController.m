//
//  FriendSearchResultsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 3/2/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "FriendSearchResultsViewController.h"
#import "FSUser.h"
#import "ProfileViewController.h"
#import "AddFriendTableCell.h"
#import "FoursquareAPI.h"
#import "KickballAppDelegate.h"
#import "FriendsListViewController.h"


@implementation FriendSearchResultsViewController

@synthesize searchType;

- (void)viewDidLoad {
    self.hideHeader = YES;
    self.hideFooter = YES;
    self.hideRefresh = YES;
    [self addHeaderAndFooter:theTableView];
    
    [super viewDidLoad];
    NSArray *people = nil;
    switch (searchType) {
        case KBFriendSearchByName:
            titleImage.image = [UIImage imageNamed:@"fullName.png"];
            break;
        case KBFriendSearchByPhone:
            titleImage.image = [UIImage imageNamed:@"phoneNumber.png"];
            break;
        case KBFriendSearchByTwitter:
            titleImage.image = [UIImage imageNamed:@"twitterFriends.png"];
            break;
            
        case KBFriendSearchByAddressBook:
            titleImage.image = [UIImage imageNamed:@"addressBook.png"];
			ABAddressBookRef addressBook = ABAddressBookCreate();
            people = (NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
			CFRelease(addressBook);
            NSMutableArray *phones = [[NSMutableArray alloc] initWithCapacity:1];
            for (int i = 0; i<[people count]; i++) {
                ABRecordRef person = [people objectAtIndex:i];
				CFTypeRef abRecord = ABRecordCopyValue(person,kABPersonPhoneProperty);
                if (ABMultiValueGetCount(abRecord) > 0) {
                    NSString *phone = (NSString *)ABMultiValueCopyValueAtIndex(abRecord, 0);
                    if (phone != nil && ![phone isEqualToString:@""]) {
                        [phones addObject:phone];
                    }
                    [phone release];
                }
				CFRelease(abRecord);
            }
            DLog(@"phones: %@", phones);
            [[FoursquareAPI sharedInstance] findFriendsByPhone:[phones componentsJoinedByString:@","] withTarget:self andAction:@selector(searchResponseReceived:withResponseString:)];
            [FlurryAPI logEvent:@"Scanning Address Book"];
            [phones release];
            [people release];
            break;
        default:
            break;
    }
    [searchBar becomeFirstResponder];
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

-(void)pressOptionsLeft{
	[[self navigationController] popViewControllerAnimated:YES];
}
-(void)pressOptionsRight{
	
}

-(IBAction)returnToOptions{
	[searchBar resignFirstResponder];
	id rootVC = [[self.navigationController viewControllers] objectAtIndex:0];
	if([rootVC isMemberOfClass:[FriendsListViewController class]]){
		[self.navigationController popToRootViewControllerAnimated:YES];
	}else {
		KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate returnFromAddFriends];
	}
}
#pragma mark -
#pragma mark other methods

- (void) back {
    [searchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) search {
    if ([searchBar.text isEqualToString:@""]) {
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Search Error" andMessage:@"Missing value. Please fill in the name field"];
        [self displayPopupMessage:message];
        [message release];
    } else {
        [searchBar resignFirstResponder];
        [self startProgressBar:@"Searching..."];
        switch (searchType) {
            case KBFriendSearchByName:
                [[FoursquareAPI sharedInstance] findFriendsByName:searchBar.text withTarget:self andAction:@selector(searchResponseReceived:withResponseString:)];
                [FlurryAPI logEvent:@"Searching For Friend By Name"];
                break;
            case KBFriendSearchByPhone:
                [[FoursquareAPI sharedInstance] findFriendsByPhone:searchBar.text withTarget:self andAction:@selector(searchResponseReceived:withResponseString:)];
                [FlurryAPI logEvent:@"Searching For Friend By Phone"];
                break;
            case KBFriendSearchByTwitter:
                [[FoursquareAPI sharedInstance] findFriendsByTwitterName:searchBar.text withTarget:self andAction:@selector(searchResponseReceived:withResponseString:)];
                [FlurryAPI logEvent:@"Searching For Friend By Twitter"];
                break;
            default:
                break;
        }
    }
}

- (void)searchResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    DLog(@"search response: %@", inString);
    
    searchResults = [[FoursquareAPI usersFromResponseXML:inString] retain];
    [theTableView reloadData];
    [self stopProgressBar];
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [searchBar resignFirstResponder];
    
    [self search];
    
    return YES;
}

#pragma mark -
#pragma mark Table view methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [searchResults count] == 0 ? 1 : [searchResults count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor whiteColor]];  
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	// create the parent view that will hold header Label
	UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 24.0)] autorelease];
    customView.backgroundColor = [UIColor whiteColor];
    customView.alpha = 0.85;
	
	// create the button object
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor grayColor];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:12];
	headerLabel.frame = CGRectMake(10.0, 0.0, 320.0, 24.0);
    
    if ([searchResults count] > 0) {
        headerLabel.text = [NSString stringWithFormat:@"%d %@ Found", [searchResults count], [searchResults count] == 1 ? @"Friend" : @"Friends"];
    } else {
        [headerLabel release];
        return nil;
    }
	[customView addSubview:headerLabel];
    [headerLabel release];
    return customView;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    AddFriendTableCell *cell = (AddFriendTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[AddFriendTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if ([searchResults count] == 0) {
        cell.nameLabel.text = @"No matching search results";
        cell.iconBackground.hidden = YES;
        cell.userIcon.hidden = YES;
        cell.addFriendButton.hidden = YES;
    } else {
        FSUser *user = (FSUser*)[searchResults objectAtIndex:indexPath.row];
        cell.nameLabel.text = user.fullname;
        cell.iconBackground.hidden = NO;
        cell.userIcon.hidden = NO;
        cell.addFriendButton.hidden = NO;
        cell.userIcon.urlPath = user.photo;
		cell.addFriendButton.tag = indexPath.row;
		[cell.addFriendButton addTarget:self action:@selector(didTapFriendizeButton:withEvent:) forControlEvents:UIControlEventTouchUpInside]; 
    }
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([searchResults count] == 0) return; //near escape from certain death!
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    [self displayProperProfileView:((FSUser*)[searchResults objectAtIndex:indexPath.row]).userId];
}

- (void) didTapFriendizeButton: (UIControl *) button withEvent: (UIEvent *) event {
    DLog(@"friendize button tapped: %d", button.tag);
    [self startProgressBar:@"Sending friend request..."];
    [[FoursquareAPI sharedInstance] doSendFriendRequest:((FSUser*)[searchResults objectAtIndex:button.tag]).userId withTarget:self andAction:@selector(friendRequestResponseReceived:withResponseString:)];
    [FlurryAPI logEvent:@"Friend Someone"];
    button.enabled = NO;
    button.alpha = 0.5;
}

- (void)friendRequestResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    FSUser *user = [FoursquareAPI userFromResponseXML:inString];
    [self stopProgressBar];
    DLog(@"user sent a friend request: %@", user);
    
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Friend Request" andMessage:@"Your future buddy has been sent a friend request."];
    [self displayPopupMessage:message];
    [message release];
}

- (void)dealloc {
    if (searchBar) [searchBar release];
    if (searchResults) [searchResults release];
    if (titleImage) [titleImage release];
    [super dealloc];
}


@end

