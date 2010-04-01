//
//  FriendsListTableCellv2.h
//  Kickball
//
//  Created by Shawn Bernard on 3/5/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "KBInstacheckinTableCell.h"

@interface FriendsListTableCellv2 : KBInstacheckinTableCell {
    TTImageView *userIcon;
}

@property (nonatomic, retain) TTImageView *userIcon;

@end
