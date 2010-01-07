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
}

- (IBAction) viewFriendRequests;
- (IBAction) addFriends;

@end
