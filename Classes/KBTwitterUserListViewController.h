//
//  KBTwitterUserListViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/28/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseTweetViewController.h"

typedef enum {
    KBTwitterUserFollower = 0,
    KBTwitterUserFriend
} KBTwitterUserType;


@interface KBTwitterUserListViewController : KBBaseTweetViewController {
    NSDictionary *userDictionary;
    NSMutableArray *users;
    KBTwitterUserType userType;
    NSNumber *currentCursor;
}

@property (nonatomic, retain) NSDictionary *userDictionary;
@property (nonatomic) KBTwitterUserType userType;

@end
