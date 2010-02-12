//
//  LoginViewModalController.h
//  FSApi
//
//  Created by David Evans on 10/27/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"
#import "FoursquareAPI.h"
#import "SFHFKeychainUtils.h"
#import "KBBaseViewController.h"

#define kUsernameDefaultsKey @"FSUsername"

@interface LoginViewModalController : KBBaseViewController {
	IBOutlet UITextField *usernameField;
	IBOutlet UITextField *passwordField;
    IBOutlet UIButton *forgottenPasswordButton;
	UIViewController * rootController;
}

@property (nonatomic, retain) UIViewController *rootController;
@property (nonatomic, retain) UITextField *usernameField;
@property (nonatomic, retain) UITextField *passwordField;

- (IBAction) login: (id) sender;
- (IBAction) openFoursquareForgottenPasswordWebPage;
- (IBAction) openFoursquareNewAccountWebPage;

@end
