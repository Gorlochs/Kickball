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

#define kApplicationKey @"yRIla6gWSyWVmizCFl13Nw"
#define kApplicationSecret @"yEjZjvUKQLCwXUC_vS_jUg"

@class FriendsListViewController;

@interface KickballAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    FriendsListViewController *viewController;
    UINavigationController *navigationController;
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
    
    MPMoviePlayerController * mMoviePlayer;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FriendsListViewController *viewController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet FSUser *user;
@property (nonatomic, retain) NSString *deviceToken;
@property (nonatomic, retain) NSString *deviceAlias;
@property (nonatomic, retain) NSString *pushNotificationUserId;

- (void) setupAuthenticatedUserAndPushNotifications;
- (void) displayPushNotificationView:(NSNotification *)inNotification;
- (void) displayPopupMessage:(KBMessage*)message;
- (void) checkForEmergencyMessage;

@end
