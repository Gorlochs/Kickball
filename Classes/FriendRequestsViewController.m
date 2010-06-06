//
//  FriendRequestsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 12/6/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "FriendRequestsViewController.h"
#import "FoursquareAPI.h"
#import "FriendSearchResultsViewController.h"
#import "KBFacebookSearchViewController.h"
#import "KBAccountManager.h"


@implementation FriendRequestsViewController


- (void)viewDidLoad {
    self.hideHeader = YES;
    self.hideFooter = YES;
    [super viewDidLoad];
    [FlurryAPI logEvent:@"Search for Friends View"];
    
    if (![[KBAccountManager sharedInstance] usesFacebook]) {
        facebookSearchButton.enabled = NO;
    }
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
    [addressBookSearchButton release];
    [twitterSearchButton release];
    [nameSearchButton release];
    [phoneSearchButton release];
    [facebookSearchButton release];
    
    [super dealloc];
}

#pragma mark
#pragma mark IBAction methods


- (void) searchByName {
    FriendSearchResultsViewController *vc = [[FriendSearchResultsViewController alloc] initWithNibName:@"FriendSearchViewController" bundle:nil];
    vc.searchType = KBFriendSearchByName;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void) searchByTwitter {
    FriendSearchResultsViewController *vc = [[FriendSearchResultsViewController alloc] initWithNibName:@"FriendSearchViewController" bundle:nil];
    vc.searchType = KBFriendSearchByTwitter;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void) searchByPhone {
    FriendSearchResultsViewController *vc = [[FriendSearchResultsViewController alloc] initWithNibName:@"FriendSearchViewController" bundle:nil];
    vc.searchType = KBFriendSearchByPhone;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void) searchAddressBook {
    FriendSearchResultsViewController *vc = [[FriendSearchResultsViewController alloc] initWithNibName:@"FriendSearchResultsViewController" bundle:nil];
    vc.searchType = KBFriendSearchByAddressBook;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
//    ABAddressBookRef addressBook = ABAddressBookCreate();
//    NSArray *people = (NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
//    NSMutableArray *phones = [[NSMutableArray alloc] initWithCapacity:1];
//    for (int i = 0; i<[people count]; i++) {
//        ABRecordRef person = [people objectAtIndex:i];
//        if (ABMultiValueGetCount(ABRecordCopyValue(person,kABPersonPhoneProperty)) > 0) {
//            NSString *phone = (NSString *)ABMultiValueCopyValueAtIndex(ABRecordCopyValue(person,kABPersonPhoneProperty) ,0);
//            if (phone != nil && ![phone isEqualToString:@""]) {
//                [phones addObject:phone];
//            }
//            [phone release];
//        }
//    }
//    DLog(@"phones: %@", phones);
//    [[FoursquareAPI sharedInstance] findFriendsByPhone:[phones componentsJoinedByString:@","] withTarget:self andAction:@selector(searchResponseReceived:withResponseString:)];
//    [FlurryAPI logEvent:@"Scanning Address Book"];
//    [phones release];
//    [people release];
    //[addressBook release];
}

- (void) searchFacebook {
    KBFacebookSearchViewController *vc = [[KBFacebookSearchViewController alloc] initWithNibName:@"KBFacebookSearchViewController" bundle:nil];
    [self stopProgressBar];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

@end

