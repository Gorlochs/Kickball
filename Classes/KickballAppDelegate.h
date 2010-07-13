//
//  KickballAppDelegate.h
//  Kickball
//
//  Created by Shawn Bernard on 10/25/09.
//  Copyright Gorloch Interactive, LLC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "FSUser.h"
#import "Reachability.h"
#import "KBPushNotificationView.h"
#import "KBMessage.h"
#import "PopupMessageView.h"
#import "util.h"

#define kApplicationKey @"yRIla6gWSyWVmizCFl13Nw"
#define kApplicationSecret @"-BnhB82eSrWrGG0aXm2PLQ"

typedef enum{
	KBNavControllerTypeFoursquare = 0,
	KBNavControllerTypeTwitter,
	KBNavControllerTypeFacebook,
	KBNavControllerTypeOptions,
} KBNavControllerType;

@class FriendsListViewController, OptionsViewController, OptionsNavigationController;

@interface KickballAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UIView *flipperView;
	
    FriendsListViewController *viewController;
    UINavigationController *navigationController;
    UINavigationController *twitterNavigationController;
    UINavigationController *facebookNavigationController;
	OptionsNavigationController *optionsNavigationController;
	UINavigationController *friendRequestsNavController;
	UINavigationController *addFriendsNavController;
    FSUser *user;
	NSString *deviceToken;
	NSString *deviceAlias;
    NSString *pushNotificationUserId;
    
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
    
    KBPushNotificationView *pushView;
    NSDictionary *pushUserInfo;
    PopupMessageView *popupView;
	
	KBNavControllerType navControllerType;
	UIImageView *optionsFrame;
	UIView *optionsHeaderBg;
	UIButton *optionsLeft;
	UIButton *optionsRight;
	}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FriendsListViewController *viewController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UINavigationController *twitterNavigationController;
@property (nonatomic, retain) IBOutlet UINavigationController *facebookNavigationController;
@property (nonatomic, retain) IBOutlet UINavigationController *optionsNavigationController;
@property (nonatomic, retain) IBOutlet FSUser *user;
@property (nonatomic, retain) NSString *deviceToken;
@property (nonatomic, retain) NSString *deviceAlias;
@property (nonatomic, retain) NSString *pushNotificationUserId;
@property (nonatomic) KBNavControllerType navControllerType;

- (void) setupAuthenticatedUserAndPushNotifications;
- (void) displayPushNotificationView:(NSNotification *)inNotification;
- (void) displayPopupMessage:(KBMessage*)message;
- (void) checkForEmergencyMessage;
- (void) switchToTwitter;
- (void) switchToFoursquare;
- (void) switchToFacebook;
-(void)flipToOptions;
- (void)returnFromOptions;
void uncaughtExceptionHandler(NSException *exception);

-(void)showFriendRequests:(NSArray*)pendingRequests;
-(void)returnFromFriendRequests;
-(void)showAddFriends;
-(void)returnFromAddFriends;

-(void)showBothOptionsButts;
-(void)showNoOptionsButts;
-(void)showLeftOptionsButts;
-(void)showRightOptionsButts;
-(void)pressOptionsLeft;
-(void)pressOptionsRight;

-(void)loggedOutOfTwitter;
-(void)loggedOutOfFoursquare;
-(void)loggedInToTwitter;
-(void)loggedInToFoursquare;
@end
