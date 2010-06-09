//
//  UserProfileFriendsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/15/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "UserProfileViewController.h"

typedef enum {
	KBFriendsFilterAll = 0,
	KBFriendsFilterPing,
	KBFriendsFilterNoPing,	
} KBFriendsFilterType;

@interface UserProfileFriendsViewController : UserProfileViewController {
    NSArray *friends;
	KBFriendsFilterType filterType;
	int numFriendsWithPings;
}

@end
