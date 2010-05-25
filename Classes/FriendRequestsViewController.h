//
//  FriendRequestsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 12/6/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"

@interface FriendRequestsViewController : KBBaseViewController {
    IBOutlet UIButton *addressBookSearchButton;
    IBOutlet UIButton *twitterSearchButton;
    IBOutlet UIButton *nameSearchButton;
    IBOutlet UIButton *phoneSearchButton;
}

- (IBAction) searchAddressBook;
- (IBAction) searchByName;
- (IBAction) searchByTwitter;
- (IBAction) searchByPhone;
- (IBAction) searchFacebook;
- (void) didTapFriendizeButton: (UIControl *) button withEvent: (UIEvent *) event;

@end
