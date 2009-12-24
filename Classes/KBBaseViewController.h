//
//  KBBaseViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 11/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressViewController.h"
#import "FSUser.h"

@class LoginViewModalController;

@interface KBBaseViewController : UIViewController {
    IBOutlet UIButton *signedInUserIcon;
    ProgressViewController *progressViewController;
    LoginViewModalController *loginViewModal;
    
    NSTimer *touchTimer;
}

@property (nonatomic, retain) LoginViewModalController *loginViewModal;

- (IBAction) backOneView;
- (IBAction) viewUserProfile;
- (IBAction) goToHomeView;
- (void) setAuthenticatedUser:(FSUser*)user;
- (FSUser*) getAuthenticatedUser;
- (void) doLoginUsername: (NSString *)fsUser andPass:(NSString *) fsPass;
- (void) startProgressBar:(NSString*)textToDisplay;
- (void) stopProgressBar;
- (void) doInitialDisplay;
- (void) displayOverlayNavigation;

@end
