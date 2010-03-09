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
    
    IBOutlet UIButton *addressBookSearchButton;
    IBOutlet UIButton *twitterSearchButton;
    IBOutlet UIButton *nameSearchButton;
    IBOutlet UIButton *phoneSearchButton;
    
    IBOutlet UITextField *twitterText;
    IBOutlet UITextField *nameText;
    IBOutlet UITextField *phoneText;
    
    NSArray *friendRequests;
    CGFloat animatedDistance;
    IBOutlet UIToolbar *toolbar;
}

- (IBAction) searchAddressBook;
- (IBAction) searchByName;
- (IBAction) searchByTwitter;
- (IBAction) searchByPhone;
- (void) didTapFriendizeButton: (UIControl *) button withEvent: (UIEvent *) event;
- (void) resignAllResponders;
- (void) animateToolbar:(CGRect)toolbarFrame;
- (IBAction) cancelEdit;

@end
