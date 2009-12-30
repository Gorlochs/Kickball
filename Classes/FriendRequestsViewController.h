//
//  FriendRequestsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 12/6/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "KBBaseViewController.h"

@interface FriendRequestsViewController : KBBaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    IBOutlet UITableView *theTableView;
    IBOutlet UITableViewCell *addressBookCell;
    IBOutlet UITableViewCell *twitterCell;
    IBOutlet UITableViewCell *nameCell;
    IBOutlet UITableViewCell *phoneCell;
    
    IBOutlet UIButton *addressBookSearchButton;
    IBOutlet UIButton *twitterSearchButton;
    IBOutlet UIButton *nameSearchButton;
    IBOutlet UIButton *phoneSearchButton;
    
    IBOutlet UITextField *twitterText;
    IBOutlet UITextField *nameText;
    IBOutlet UITextField *phoneText;
    
    NSArray *friendRequests;
    CGFloat animatedDistance;
}

- (IBAction) searchAddressBook;
- (IBAction) searchByName;
- (IBAction) searchByTwitter;
- (IBAction) searchByPhone;
- (void) didTapFriendizeButton: (UIControl *) button withEvent: (UIEvent *) event;

@end
