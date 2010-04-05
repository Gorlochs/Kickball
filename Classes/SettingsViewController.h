//
//  SettingsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 12/20/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"


@interface SettingsViewController : KBBaseViewController <UITextFieldDelegate> {
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
    IBOutlet UILabel *friendRequestCount;
    NSArray *pendingFriendRequests;
    bool isPingAndUpdatesOn;
    IBOutlet UIButton *pingsAndUpdates;
    IBOutlet UIToolbar *toolbar;
    IBOutlet UISegmentedControl *cityRadiusControl;
}

- (IBAction) viewFriendRequests;
- (IBAction) addFriends;
- (IBAction) validateNewUsernamePassword;
- (IBAction) togglePingsAndUpdates;
- (void) setPingAndUpdatesButton;
- (IBAction) cancelEdit;
- (void) animateToolbar:(CGRect)toolbarFrame;
- (IBAction) chooseCityRadius;

@end
