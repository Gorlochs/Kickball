//
//  FriendSearchResultsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 3/2/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "KBBaseViewController.h"

typedef enum {
	KBFriendSearchByName = 0,
	KBFriendSearchByPhone = 1,
	KBFriendSearchByTwitter = 2,
	KBFriendSearchByAddressBook = 3
} KBFriendSearchType;

@interface FriendSearchResultsViewController : KBBaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    KBFriendSearchType searchType;
    IBOutlet UITextField *searchBar;
    IBOutlet UIImageView *titleImage;
    
    NSArray *searchResults;
}

@property (nonatomic) KBFriendSearchType searchType;;

- (IBAction) back;


@end
