//
//  AddFriendTableCell.h
//  Kickball
//
//  Created by Shawn Bernard on 5/25/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"

@interface AddFriendTableCell : UITableViewCell {
    UIImageView *iconBackground;
    UILabel *nameLabel;
    UIButton *addFriendButton;
    TTImageView *userIcon;
}

@property (nonatomic, retain) UIImageView *iconBackground;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UIButton *addFriendButton;
@property (nonatomic, retain) TTImageView *userIcon;

@end
