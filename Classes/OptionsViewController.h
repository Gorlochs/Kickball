//
//  OptionsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/16/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"


@interface OptionsViewController : KBBaseViewController {
    IBOutlet UILabel *friendRequestCount;
    NSArray *pendingFriendRequests;
}

- (IBAction) viewFriendRequests;
- (IBAction) addFriends;

@end
