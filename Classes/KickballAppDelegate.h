//
//  KickballAppDelegate.h
//  Kickball
//
//  Created by Shawn Bernard on 10/25/09.
//  Copyright Gorloch Interactive, LLC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FriendsListViewController;

@interface KickballAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    FriendsListViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FriendsListViewController *viewController;

@end
