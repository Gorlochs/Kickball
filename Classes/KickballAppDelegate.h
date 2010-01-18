//
//  KickballAppDelegate.h
//  Kickball
//
//  Created by Shawn Bernard on 10/25/09.
//  Copyright Gorloch Interactive, LLC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSUser.h"

@class FriendsListViewController;

@interface KickballAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    FriendsListViewController *viewController;
    UINavigationController *navigationController;
    FSUser *user;
	NSString *deviceToken;
	NSString *deviceAlias;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FriendsListViewController *viewController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet FSUser *user;
@property (nonatomic, retain) NSString *deviceToken;
@property (nonatomic, retain) NSString *deviceAlias;

- (void) setupAuthenticatedUserAndPushNotifications;

@end
