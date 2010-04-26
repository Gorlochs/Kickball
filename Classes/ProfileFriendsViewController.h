//
//  ProfileFriendsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 1/13/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBFoursquareViewController.h"


@interface ProfileFriendsViewController : KBFoursquareViewController {
    NSString *userId;
    NSArray *friends;
    NSMutableDictionary *userIcons;
}

@property (nonatomic, retain) NSString *userId;

@end
