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
#import "Beacon.h"
#import "FSVenue.h"
#import "Utilities.h"
#import "EGORefreshTableHeaderView.h"
#import "FooterTabView.h"
#import "FoursquareHeaderView.h"

#define HEADER_NIB_TWITTER      @"TwitterHeaderView"
#define HEADER_NIB_FOURSQUARE   @"FoursquareHeaderView"
#define kUsernameDefaultsKey    @"FSUsername"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
extern const NSString *kickballDomain;

typedef enum {
	KBFooterTypeFoursquare = 0,
	KBFooterTypeProfile,
	KBFooterTypeFacebook,
	KBFooterTypeTwitter
} KBFooterType;

typedef enum{
	KBPageTypeFriends = 0,
	KBPageTypePlaces,
	KBPageTypeOther,	
} KBPageType;

typedef enum{
	KBPageViewTypeList = 0,
	KBPageViewTypeMap,
	KBPageViewTypeOther,	
} KBPageViewType;

@class LoginViewModalController, EGORefreshTableHeaderView;;

@interface KBBaseViewController : UIViewController {
    
    IBOutlet UITableView *theTableView;
    
    ProgressViewController *progressViewController;
    LoginViewModalController *loginViewModal;
    PopupMessageView *popupView;
    UIImageView *iconImageView;
    NSString *textViewReturnValue;
    NSTimer *progressBarTimer;
    
    KBPageType pageType;
    KBPageViewType pageViewType;
    
    BOOL hideHeader;
    BOOL hideFooter;
    BOOL hideRefresh;
    
    //EGO class stuff
    EGORefreshTableHeaderView *refreshHeaderView;
	
	//  Reloading should really be your tableviews model class
	//  Putting it here for demo purposes 
	BOOL _reloading;
    
    // bottom tab bar members
    FooterTabView *footerTabView;
    IBOutlet UIButton *optionsTab;
    IBOutlet UIButton *facebookTab;
    IBOutlet UIButton *twitterTab;
    IBOutlet UIButton *foursquareTab;
    IBOutlet UIButton *signedInUserIcon;
    KBFooterType footerType;
    NSString *headerNibName;
}

@property (nonatomic, retain) UITableView *theTableView;
@property (nonatomic, retain) LoginViewModalController *loginViewModal;
@property (nonatomic, retain) NSString *textViewReturnValue;
@property (nonatomic) BOOL hideFooter;
@property (nonatomic) BOOL hideHeader;
@property (nonatomic) BOOL hideRefresh;

@property(assign,getter=isReloading) BOOL reloading;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

- (IBAction) viewUserProfile;

- (void) setUserIconView:(FSUser*)user;
- (void) setAuthenticatedUser:(FSUser*)user;
- (FSUser*) getAuthenticatedUser;
- (void) doLoginUsername: (NSString *)fsUser andPass:(NSString *) fsPass;
- (void) startProgressBar:(NSString*)textToDisplay;
- (void) startProgressBar:(NSString*)textToDisplay withTimer:(BOOL)shouldSetTimer;
- (void) stopProgressBar;
- (void) doInitialDisplay;
- (void) displayPopupMessage:(KBMessage*)message;
- (void) displayPopupMessageForLogin:(KBMessage*)message;
- (IBAction) viewSettings;
- (void) addHeaderAndFooter:(UITableView*)tableView;
- (IBAction) displayTextView;
- (IBAction) displayTextViewForCheckin;
- (void) displayPushedVenueId;
- (void) openWebView:(NSString*)url;
- (IBAction) dismiss;
- (void) displayFoursquareErrorMessage:(NSString*)errorMessage;
- (void) stopProgressBarAndDisplayErrorMessage:(NSTimer*)theTimer;
- (void) refreshTable;
- (void) dataSourceDidFinishLoadingNewData;
- (void) displayProperProfileView:(NSString*)userId;
- (IBAction) switchToTwitter;
- (IBAction) switchToFoursquare;
- (IBAction) switchToFacebook;
- (void) setTabImages;

@end
