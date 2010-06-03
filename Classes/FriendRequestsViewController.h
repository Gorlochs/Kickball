//
//  FriendRequestsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 12/6/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractFacebookViewController.h"

@interface FriendRequestsViewController : AbstractFacebookViewController {
    IBOutlet UIButton *addressBookSearchButton;
    IBOutlet UIButton *twitterSearchButton;
    IBOutlet UIButton *nameSearchButton;
    IBOutlet UIButton *phoneSearchButton;
    IBOutlet UIButton *facebookSearchButton;
}

- (IBAction) searchAddressBook;
- (IBAction) searchByName;
- (IBAction) searchByTwitter;
- (IBAction) searchByPhone;
- (IBAction) searchFacebook;

@end
