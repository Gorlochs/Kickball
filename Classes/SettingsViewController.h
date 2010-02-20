//
//  SettingsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 12/20/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"


@interface SettingsViewController : KBBaseViewController {
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
    IBOutlet UILabel *friendRequestCount;
    NSArray *pendingFriendRequests;
    bool isPingAndUpdatesOn;
    IBOutlet UIButton *pingsAndUpdates;
}

- (IBAction) viewFriendRequests;
- (IBAction) addFriends;
- (IBAction) validateNewUsernamePassword;
- (IBAction) togglePingsAndUpdates;
- (void) setPingAndUpdatesButton;

@end
