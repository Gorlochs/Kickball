//
//  ViewFriendRequestsTableCell.h
//  Kickball
//
//  Created by Shawn Bernard on 1/14/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ViewFriendRequestsTableCell : UITableViewCell {
    IBOutlet UIButton *acceptFriendButton;
    IBOutlet UIButton *denyFriendButton;
    IBOutlet UILabel *friendName;
}

@property (nonatomic, retain) UIButton *acceptFriendButton;
@property (nonatomic, retain) UIButton *denyFriendButton;
@property (nonatomic, retain) UILabel *friendName;

@end
