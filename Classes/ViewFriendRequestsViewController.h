//
//  ViewFriendRequestsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 12/6/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"


@interface ViewFriendRequestsViewController : KBBaseViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *theTableView;
    NSMutableArray *pendingFriendRequests;
}

@property (nonatomic, retain) NSMutableArray *pendingFriendRequests;

- (void) acceptFriend:(UIControl*) button;
- (void) denyFriend:(UIControl*) button;

@end
