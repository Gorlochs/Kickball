//
//  LoginViewModalController.h
//  FSApi
//
//  Created by David Evans on 10/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"
#import "FoursquareAPI.h"

@interface LoginViewModalController : UIViewController {
	IBOutlet UITextField *usernameField;
	IBOutlet UITextField *passwordField;
	UIViewController * rootController;
}

@property (nonatomic, retain) UIViewController *rootController;
@property (nonatomic, retain) UITextField *usernameField;
@property (nonatomic, retain) UITextField *passwordField;

- (IBAction) login: (id) sender;

@end
