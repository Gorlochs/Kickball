//
//  ViewFriendRequestsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 12/6/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBFoursquareViewController.h"


@interface ViewFriendRequestsViewController : KBFoursquareViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *pendingFriendRequests;
}

@property (nonatomic, retain) NSMutableArray *pendingFriendRequests;

- (void) acceptFriend:(UIControl*) button;
- (void) denyFriend:(UIControl*) button;
-(IBAction)returnToOptions;
@end
