//
//  KBBaseViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 11/17/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressViewController.h"
#import "PopupMessageView.h"
#import "FSUser.h"
#import "KBMessage.h"
#import "KBTextViewController.h"
#import "Beacon.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@class LoginViewModalController;

@interface KBBaseViewController : UIViewController {
    IBOutlet UIButton *signedInUserIcon;
    ProgressViewController *progressViewController;
    LoginViewModalController *loginViewModal;
    PopupMessageView *popupView;
    KBTextViewController *textViewController;
    NSString *textViewReturnValue;
    UIImageView *iconImageView;
}

@property (nonatomic, retain) LoginViewModalController *loginViewModal;
@property (nonatomic, retain) NSString *textViewReturnValue;

- (void) setUserIconView:(FSUser*)user;
- (IBAction) backOneView;
- (IBAction) viewUserProfile;
- (IBAction) goToHomeView;
- (void) setAuthenticatedUser:(FSUser*)user;
- (FSUser*) getAuthenticatedUser;
- (void) doLoginUsername: (NSString *)fsUser andPass:(NSString *) fsPass;
- (void) startProgressBar:(NSString*)textToDisplay;
- (void) stopProgressBar;
- (void) doInitialDisplay;
- (void) displayPopupMessage:(KBMessage*)message;
- (IBAction) viewSettings;
- (void) addHeaderAndFooter:(UITableView*)tableView;
- (IBAction) displayTextView;
- (void) displayPushedVenueId;
- (IBAction) checkin;
- (void) openWebView:(NSString*)url;

@end
